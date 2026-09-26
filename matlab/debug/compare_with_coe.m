function result = compare_with_coe(received, expected, max_listed)
%COMPARE_WITH_COE  Compare received words with the ROM content and report mismatches.
%
%   result = compare_with_coe(received, expected)
%   result = compare_with_coe(received, expected, max_listed)
%
%   received, expected : uint32 vectors of equal length (index k+1 = address k)
%   max_listed         : how many mismatching addresses to print, default 10
%
%   result.pass           true when every word matches (HW-DEBUG-02 criterion)
%   result.num_words      number of compared words
%   result.num_mismatch   number of differing words
%   result.mismatch_addr  0-based addresses that differ
%   result.expected / result.actual   values at those addresses
%
%   Purpose : verify the ROM dump on the PC (demo: 0 mismatches)
%   Reqs    : REQ-DEBUG-017; tests HW-DEBUG-02, HW-DEBUG-03
%   Author  : Ömer (omerkutlu1030)
%   AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0007

if nargin < 3
    max_listed = 10;
end
received = uint32(received(:));
expected = uint32(expected(:));
if numel(received) ~= numel(expected)
    error('debug:compareLength', 'Received %d words but the reference has %d.', ...
        numel(received), numel(expected));
end

bad = find(received ~= expected);
result.pass          = isempty(bad);
result.num_words     = numel(expected);
result.num_mismatch  = numel(bad);
result.mismatch_addr = bad - 1;
result.expected      = expected(bad);
result.actual        = received(bad);

if result.pass
    fprintf('PASS: %d/%d words match.\n', result.num_words, result.num_words);
else
    fprintf('FAIL: %d of %d words differ.\n', result.num_mismatch, result.num_words);
    for i = 1:min(max_listed, numel(bad))
        fprintf('  addr %5d (0x%04X): expected %08X, received %08X\n', ...
            result.mismatch_addr(i), result.mismatch_addr(i), result.expected(i), result.actual(i));
    end
end
end
