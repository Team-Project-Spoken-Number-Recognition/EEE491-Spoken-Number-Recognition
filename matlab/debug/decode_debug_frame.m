function words = decode_debug_frame(bytes, N)
%DECODE_DEBUG_FRAME  Turn the Lab-DEBUG byte stream into 32-bit words.
%
%   words = decode_debug_frame(bytes)      N = 14
%   words = decode_debug_frame(bytes, N)
%
%   bytes : the complete received stream, exactly 8 + 4*2^N values 0..255
%   words : 2^N x 1 uint32, words(k+1) = memory address k
%
%   Frame (REQ-DEBUG-005..007, TA Q-02):
%     55 AA CC 03 | 4 bytes per word, most-significant byte first | AA 55 03 CC
%
%   The frame is identified by its fixed length (DEC-010, REQ-SW-003): the
%   start and end words are only CHECKED, never searched for, because the data
%   itself may contain the values 55AACC03 / AA5503CC.
%
%   Errors (never returns partial or shifted data):
%     debug:frameLength   wrong number of bytes (e.g. reset during transfer)
%     debug:badStartWord  first 4 bytes are not 55 AA CC 03
%     debug:badEndWord    last 4 bytes are not AA 55 03 CC
%
%   Purpose : PC-side decoding for Lab-DEBUG
%   Reqs    : REQ-DEBUG-015, REQ-SW-003, DEC-010; tests MT-DEBUG-01..03
%   Author  : Ömer (omerkutlu1030)
%   AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0007

if nargin < 2
    N = 14;
end
spec  = debug_frame_spec(N);
bytes = double(bytes(:));

if numel(bytes) ~= spec.frame_bytes
    error('debug:frameLength', ...
        'Received %d bytes, expected %d (8 + 4*2^%d). Transfer incomplete or N wrong.', ...
        numel(bytes), spec.frame_bytes, spec.N);
end
if any(bytes < 0 | bytes > 255 | bytes ~= round(bytes))
    error('debug:frameLength', 'Input is not a byte stream (values must be integers 0..255).');
end

all_words = bytes_to_words(bytes);          % start word, 2^N data words, end word

if all_words(1) ~= spec.start_word
    error('debug:badStartWord', 'Start word is %08X, expected %08X.', ...
        all_words(1), spec.start_word);
end
if all_words(end) ~= spec.end_word
    error('debug:badEndWord', 'End word is %08X, expected %08X.', ...
        all_words(end), spec.end_word);
end
words = all_words(2:end-1);
end

function words = bytes_to_words(bytes)
% Concatenate every 4 bytes, first byte = bits 31..24 (MSB first).
% Doubles hold integers up to 2^53 exactly, so the sum is exact.
b     = reshape(bytes, 4, []);
words = uint32(b(1, :) * 2^24 + b(2, :) * 2^16 + b(3, :) * 2^8 + b(4, :)).';
end
