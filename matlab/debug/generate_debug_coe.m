function words = generate_debug_coe(filename, N)
%GENERATE_DEBUG_COE  Write the Lab-DEBUG test pattern as a Vivado COE file.
%
%   words = generate_debug_coe(filename)      N = 14 (16 384 x 32-bit demo ROM)
%   words = generate_debug_coe(filename, N)   2^N words, 3 <= N <= 16
%   words = generate_debug_coe([], N)         only return the pattern, write no file
%
%   Returns the 2^N x 1 uint32 column that was written; words(k+1) is the
%   content of ROM address k.
%
%   Test pattern (chosen so that transfer errors are visible at a glance):
%     default   address k -> [k (16 bit) | NOT k (16 bit)], e.g. k = 5 -> 0005FFFA.
%               A word at the wrong position or with swapped bytes no longer
%               matches its own address.
%     addr 1    55AACC03   start word inside the payload  (DEC-010)
%     addr 2    AA5503CC   end word inside the payload    (DEC-010)
%     addr 3    00000000   all zeros
%     addr 4    FFFFFFFF   all ones
%     addr last-1  55AACC03
%     addr last    AA5503CC   directly before the real end word: the receiver
%                             must not stop early (REQ-SW-003)
%
%   File format (Block Memory Generator, manual DBG §3):
%     MEMORY_INITIALIZATION_RADIX=16;
%     MEMORY_INITIALIZATION_VECTOR=
%     0000FFFF,
%     ...
%     AA5503CC;
%
%   Purpose : ROM content for the Lab-DEBUG demo (demo ROM, N = 14)
%   Reqs    : REQ-DEBUG-016, REQ-DEBUG-017, DEC-010; test MT-DEBUG-02, MT-DEBUG-04
%   Author  : Ömer (omerkutlu1030)
%   AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0007

if nargin < 2
    N = 14;
end
% N <= 16 so that "k | NOT k" fits into 16 + 16 bits; N >= 3 so that the
% special addresses 1..4 and last-1..last are all different.
validateattributes(N, {'numeric'}, {'scalar', 'integer', '>=', 3, '<=', 16}, mfilename, 'N');
spec = debug_frame_spec(N);

k     = uint32(0:spec.num_words - 1).';
words = bitor(bitshift(k, 16), bitand(bitcmp(k), uint32(0xFFFF)));

last = spec.num_words - 1;                        % highest address
special_addr  = [1; 2; 3; 4; last - 1; last];
special_value = [spec.start_word; spec.end_word; uint32(0); uint32(0xFFFFFFFF); ...
                 spec.start_word; spec.end_word];
words(special_addr + 1) = special_value;          % +1: MATLAB indices start at 1

if isempty(filename)
    return
end

out_dir = fileparts(filename);
if ~isempty(out_dir) && ~isfolder(out_dir)
    mkdir(out_dir);
end
fid = fopen(filename, 'w');
if fid < 0
    error('debug:coeWrite', 'Cannot open "%s" for writing.', filename);
end
closer = onCleanup(@() fclose(fid));

fprintf(fid, 'MEMORY_INITIALIZATION_RADIX=16;\n');
fprintf(fid, 'MEMORY_INITIALIZATION_VECTOR=\n');
fprintf(fid, '%08X,\n', words(1:end-1));
fprintf(fid, '%08X;\n', words(end));
end
