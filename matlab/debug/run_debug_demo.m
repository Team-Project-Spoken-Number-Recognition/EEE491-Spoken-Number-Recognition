function result = run_debug_demo(port, coe_file, N)
%RUN_DEBUG_DEMO  Lab-DEBUG demo: receive the ROM from the Basys-3 and check it against the COE.
%
%   result = run_debug_demo(port)                  uses fpga/ip/debug_rom.coe, N = 14
%   result = run_debug_demo(port, coe_file, N)
%
%   Example (demo, HW-DEBUG-02):
%       serialportlist("available")        % find the Basys-3 port
%       result = run_debug_demo("COM5");   % then press START on the board
%
%   Prints PASS when all 2^N words equal the COE content; returns the
%   COMPARE_WITH_COE result plus result.words (received data).
%
%   Purpose : one-command demo for Lab-DEBUG
%   Reqs    : REQ-DEBUG-015, REQ-DEBUG-017, REQ-SW-001; tests HW-DEBUG-02..05
%   Author  : Ömer (omerkutlu1030)
%   AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0007

if nargin < 2 || isempty(coe_file)
    repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    coe_file  = fullfile(repo_root, 'fpga', 'ip', 'debug_rom.coe');
end
if nargin < 3 || isempty(N)
    N = 14;
end

expected = read_coe(coe_file);
if numel(expected) ~= 2^N
    error('debug:compareLength', 'COE has %d words but N = %d needs %d.', numel(expected), N, 2^N);
end

words  = receive_debug_frame(port, N);
result = compare_with_coe(words, expected);
result.words = words;
end
