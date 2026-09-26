function results = hw_debug_session(port, log_file)
%HW_DEBUG_SESSION  Guided hardware tests HW-DEBUG-03, -04 and -05 on the Basys-3 (TEST_PLAN §3).
%
%   results = hw_debug_session("COM4")
%   results = hw_debug_session("COM4", "docs/verification/2026-09-26_hw_debug_session.log")
%
%   Precondition: the board runs top_debug_demo.bit (LD6 on) and no other program holds the COM
%   port. The current MATLAB folder does not matter: all paths are relative to this file.
%
%   The session has 14 steps. For every step the console says what to press; then the function
%   waits (up to 120 s) for the first byte, reads the rest of the frame, and classifies it:
%     PASS       65 544 bytes, start/end word correct, all 16 384 words equal to the COE
%     TRUNCATED  fewer bytes (expected only in HW-DEBUG-05a: reset during the transfer)
%     FAIL       wrong length (other steps), wrong start/end word or mismatching words
%   After each frame it waits 2 s and counts EXTRA bytes (a second, unwanted transfer).
%   The transfer time is measured from the first to the last byte on the PC (≈ 0.66 s expected;
%   FTDI USB latency adds a few ms).
%
%   Steps
%     1-10  HW-DEBUG-03   press BTNU once, normally                       -> PASS, 0 extra
%     11    HW-DEBUG-04a  press BTNU and HOLD it ~2 s (longer than a transfer), then release
%                                                                         -> PASS, 0 extra
%     12    HW-DEBUG-04b  press BTNU, then press it 3-4 more times while LD6 is off
%                                                                         -> PASS, 0 extra
%     13    HW-DEBUG-05a  press BTNU, then press BTNC (reset) while LD6 is off
%                                                                         -> TRUNCATED, LD6 on again
%     14    HW-DEBUG-05b  press BTNU once                                 -> PASS (clean after reset)
%
%   Purpose : hardware verification of Lab-DEBUG (REQ-DEBUG-012/013/017, REQ-PERF-002, REQ-IF-007)
%   Author  : Eren (eeerenbuyukbas)
%   AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0012

repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));   % <repo>/matlab/tests/this.m
if nargin < 2 || strlength(string(log_file)) == 0
    log_file = fullfile(repo_root, 'docs', 'verification', ...
        sprintf('%s_hw_debug_session.log', string(datetime('now'), 'yyyy-MM-dd')));
end
addpath(fullfile(repo_root, 'matlab', 'debug'));

N        = 14;
spec     = debug_frame_spec(N);
expected = read_coe(fullfile(repo_root, 'fpga', 'ip', 'debug_rom.coe'));

steps = {
    'HW-DEBUG-03', 'press BTNU once',                                              'PASS'
    'HW-DEBUG-03', 'press BTNU once',                                              'PASS'
    'HW-DEBUG-03', 'press BTNU once',                                              'PASS'
    'HW-DEBUG-03', 'press BTNU once',                                              'PASS'
    'HW-DEBUG-03', 'press BTNU once',                                              'PASS'
    'HW-DEBUG-03', 'press BTNU once',                                              'PASS'
    'HW-DEBUG-03', 'press BTNU once',                                              'PASS'
    'HW-DEBUG-03', 'press BTNU once',                                              'PASS'
    'HW-DEBUG-03', 'press BTNU once',                                              'PASS'
    'HW-DEBUG-03', 'press BTNU once',                                              'PASS'
    'HW-DEBUG-04a', 'press BTNU and HOLD it ~2 s, then release',                    'PASS'
    'HW-DEBUG-04b', 'press BTNU, then press it 3-4 more times while LD6 is off',    'PASS'
    'HW-DEBUG-05a', 'press BTNU, then press BTNC (reset) while LD6 is off',         'TRUNCATED'
    'HW-DEBUG-05b', 'press BTNU once (after the reset)',                            'PASS'
};

if isfile(log_file)
    delete(log_file);
end
diary(log_file);
cleanup_diary = onCleanup(@() diary('off'));

fprintf('# Hardware session log — HW-DEBUG-03/04/05 (TEST_PLAN §3)\n');
fprintf('# Date      : %s\n', string(datetime('now'), 'yyyy-MM-dd HH:mm'));
fprintf('# Board     : Basys-3, bitstream top_debug_demo.bit (N = 14, 1 000 000 baud)\n');
fprintf('# MATLAB    : %s\n', version);
fprintf('# Port      : %s\n#\n', port);

dev = serialport(port, spec.baud_rate, 'DataBits', 8, 'Parity', 'none', ...
    'StopBits', 1, 'FlowControl', 'none', 'Timeout', 120);
cleanup_port = onCleanup(@() delete(dev));
old_warn = warning('off', 'all');
cleanup_warn = onCleanup(@() warning(old_warn));
flush(dev);

n = size(steps, 1);
results = struct('step', cell(n, 1), 'test', [], 'verdict', [], 'expected_verdict', [], ...
    'bytes', [], 'mismatches', [], 'extra_bytes', [], 'transfer_s', [], 'ok', []);

for i = 1:n
    fprintf('\n>>> Step %2d/%d  [%s]  %s\n', i, n, steps{i, 1}, upper(steps{i, 2}));
    dev.Timeout = 120;
    first = read(dev, 1, 'uint8');                       % waits for the button press
    if isempty(first)
        fprintf('    no byte within 120 s\n');
        bytes = uint8([]);  dt = NaN;
    else
        t0 = tic;
        dev.Timeout = 2;                                 % a full frame needs ~0.66 s
        rest  = read(dev, spec.frame_bytes - 1, 'uint8');
        dt    = toc(t0);
        bytes = uint8([first, rest]).';
    end

    mism = NaN;
    if numel(bytes) == spec.frame_bytes
        try
            words = decode_debug_frame(bytes, N);
            mism  = nnz(words ~= expected);
            if mism == 0
                verdict = 'PASS';
            else
                verdict = 'FAIL';
            end
        catch err
            verdict = 'FAIL';
            fprintf('    decode error: %s\n', err.message);
        end
    elseif isempty(bytes)
        verdict = 'NO DATA';
    else
        verdict = 'TRUNCATED';
    end

    pause(2);                                            % unwanted second transfer?
    extra = dev.NumBytesAvailable;
    flush(dev);

    ok = strcmp(verdict, steps{i, 3}) && extra == 0;
    results(i) = struct('step', i, 'test', steps{i, 1}, 'verdict', verdict, ...
        'expected_verdict', steps{i, 3}, 'bytes', numel(bytes), 'mismatches', mism, ...
        'extra_bytes', extra, 'transfer_s', dt, 'ok', ok);
    fprintf('    %-12s step %2d: %-9s (expected %-9s) bytes=%5d mismatches=%s extra=%d transfer=%.3f s  => %s\n', ...
        steps{i, 1}, i, verdict, steps{i, 3}, numel(bytes), num2str(mism), extra, dt, ...
        ternary(ok, 'OK', 'NOT OK'));
end

n_ok = nnz([results.ok]);
t    = [results([results.ok] & strcmp({results.verdict}, 'PASS')).transfer_s];
fprintf('\n# Transfer time (PASS steps): min %.3f s, mean %.3f s, max %.3f s (n = %d)\n', ...
    min(t), mean(t), max(t), numel(t));
fprintf('HW_RESULT: %s (%d/%d steps as expected)\n', ternary(n_ok == n, 'PASS', 'FAIL'), n_ok, n);
end

function out = ternary(cond, a, b)
if cond
    out = a;
else
    out = b;
end
end
