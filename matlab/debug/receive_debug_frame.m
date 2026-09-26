function [words, bytes] = receive_debug_frame(port, N, timeout_s)
%RECEIVE_DEBUG_FRAME  Receive one Lab-DEBUG transfer from the Basys-3 USB-UART.
%
%   [words, bytes] = receive_debug_frame(port)
%   [words, bytes] = receive_debug_frame(port, N, timeout_s)
%
%   port      : COM port of the Basys-3 FT2232HQ, e.g. "COM5" (see
%               serialportlist("available") or Device Manager -> Ports)
%   N         : address width, default 14 -> 65 544 bytes
%   timeout_s : seconds to wait for the whole transfer INCLUDING the time until
%               START is pressed, default 20
%
%   Opens the port at 1 000 000 baud 8N1 (DEC-005), discards old bytes, waits
%   for the user to press START, reads exactly 8 + 4*2^N bytes (DEC-010) and
%   decodes them with DECODE_DEBUG_FRAME. A short stream (timeout, reset during
%   the transfer) raises debug:frameLength with the received byte count.
%
%   Purpose : MATLAB receiver for Lab-DEBUG (hardware tests HW-DEBUG-02..05)
%   Reqs    : REQ-SW-001, REQ-SW-003, REQ-DEBUG-015, REQ-DEBUG-017
%   Author  : Ömer (omerkutlu1030)
%   AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0007

if nargin < 2 || isempty(N)
    N = 14;
end
if nargin < 3 || isempty(timeout_s)
    timeout_s = 20;
end
spec = debug_frame_spec(N);

dev = serialport(port, spec.baud_rate, 'DataBits', 8, 'Parity', 'none', ...
    'StopBits', 1, 'FlowControl', 'none', 'Timeout', timeout_s);
closer = onCleanup(@() delete(dev));             % always release the COM port
flush(dev);                                      % drop bytes from earlier transfers

fprintf('Listening on %s at %d baud for %d bytes. Press START on the board (timeout %g s)...\n', ...
    port, spec.baud_rate, spec.frame_bytes, timeout_s);
t0 = tic;
% On timeout, serialport returns the bytes received so far and prints a
% warning; the length check in decode_debug_frame reports it as an error instead.
old_warn = warning('off', 'all');
restore  = onCleanup(@() warning(old_warn));
bytes = uint8(read(dev, spec.frame_bytes, 'uint8')).';
clear restore
fprintf('Received %d bytes in %.2f s (includes the wait for START).\n', numel(bytes), toc(t0));

words = decode_debug_frame(bytes, N);
end
