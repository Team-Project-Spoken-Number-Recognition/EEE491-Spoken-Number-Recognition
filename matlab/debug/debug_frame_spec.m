function spec = debug_frame_spec(N)
%DEBUG_FRAME_SPEC  Constants of the Lab-DEBUG UART frame (single source for all MATLAB code).
%
%   spec = debug_frame_spec()   uses N = 14 (demo ROM, REQ-DEBUG-016)
%   spec = debug_frame_spec(N)  any address width N >= 1
%
%   Fields:
%     N            address width -> 2^N data words per transfer (REQ-DEBUG-004)
%     num_words    2^N
%     start_word   uint32 0x55AACC03 (REQ-DEBUG-005)
%     end_word     uint32 0xAA5503CC (REQ-DEBUG-006)
%     frame_bytes  8 + 4*2^N bytes on the wire (DEC-010)
%     baud_rate    1 000 000 (DEC-005, REQ-DEBUG-009), 8N1
%
%   Purpose : shared constants for the PC side of Lab-DEBUG
%   Reqs    : REQ-DEBUG-004..007, REQ-DEBUG-009, REQ-SW-003
%   Design  : docs/architecture/subsystems/debug.md §10
%   Author  : Ömer (omerkutlu1030)
%   AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0007

if nargin < 1
    N = 14;
end
validateattributes(N, {'numeric'}, {'scalar', 'integer', '>=', 1, '<=', 24}, mfilename, 'N');

spec.N           = double(N);
spec.num_words   = 2^spec.N;
spec.start_word  = uint32(0x55AACC03);
spec.end_word    = uint32(0xAA5503CC);
spec.frame_bytes = 8 + 4 * spec.num_words;
spec.baud_rate   = 1000000;
end
