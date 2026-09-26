function results = run_debug_tests()
%RUN_DEBUG_TESTS  Run MT-DEBUG-01..04 and print a one-line summary.
%
%   results = run_debug_tests()
%
%   From the repository root, in MATLAB:   run_debug_tests
%   From a terminal (log for simulation/results/):
%       matlab -batch "addpath('matlab/tests'); run_debug_tests" > simulation/results/2026-09-26_mt_debug.log
%
%   Last line: "MT_RESULT: PASS (k/k tests)" or "MT_RESULT: FAIL (k/n tests)"
%   (same idea as TB_RESULT in the VHDL testbenches, DEC-011).
%
%   Purpose : one-command MATLAB test run for Lab-DEBUG
%   Reqs    : REQ-VER-003, DEC-011; tests MT-DEBUG-01..04
%   Author  : Ömer (omerkutlu1030)
%   AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0007

test_file = fullfile(fileparts(mfilename('fullpath')), 'test_debug.m');
results   = runtests(test_file);
disp(table(results));

passed = nnz([results.Passed]);
if passed == numel(results)
    verdict = 'PASS';
else
    verdict = 'FAIL';
end
fprintf('MT_RESULT: %s (%d/%d tests)\n', verdict, passed, numel(results));
if nargout == 0
    clear results                  % keep the log ending on the MT_RESULT line
end
end
