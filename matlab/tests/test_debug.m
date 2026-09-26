function tests = test_debug
%TEST_DEBUG  MATLAB tests MT-DEBUG-01..04 for the PC side of Lab-DEBUG (TEST_PLAN §2).
%
%   Run from the repository root:
%       results = runtests('matlab/tests/test_debug.m')
%
%   No hardware and no Vivado needed. The FPGA byte stream is modelled by
%   ENCODE_FRAME below (MSB byte first, REQ-DEBUG-007).
%
%   Purpose : verify COE generator, COE reader, frame decoder and compare
%   Reqs    : REQ-DEBUG-015, REQ-DEBUG-016, REQ-SW-003, DEC-010
%   Author  : Ömer (omerkutlu1030)
%   AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0007
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
testCase.TestData.repo_root = repo_root;
testCase.TestData.old_path  = addpath(fullfile(repo_root, 'matlab', 'debug'));
end

function teardownOnce(testCase)
path(testCase.TestData.old_path);
end

%% MT-DEBUG-01 — decode a synthetic byte vector ------------------------------
function test_MT_DEBUG_01_hand_written_frame(testCase)
% Written by hand from the manual's frame table, independent of ENCODE_FRAME.
bytes = uint8([0x55 0xAA 0xCC 0x03, ...
               0x12 0x34 0x56 0x78, ...   % address 0
               0x9A 0xBC 0xDE 0xF0, ...   % address 1
               0xAA 0x55 0x03 0xCC]);
words = decode_debug_frame(bytes, 1);
verifyEqual(testCase, words, uint32([0x12345678; 0x9ABCDEF0]));
end

function test_MT_DEBUG_01_random_words(testCase)
N = 6;
rng(491);                                          % reproducible
source = uint32(randi([0, double(intmax('uint32'))], 2^N, 1));
verifyEqual(testCase, decode_debug_frame(encode_frame(source), N), source);
end

function test_MT_DEBUG_01_full_size_N14(testCase)
source = generate_debug_coe([], 14);
bytes  = encode_frame(source);
verifyEqual(testCase, numel(bytes), 65544);       % REQ-PERF-002 frame size
verifyEqual(testCase, decode_debug_frame(bytes), source);
end

%% MT-DEBUG-02 — delimiter values inside the payload ---------------------------
function test_MT_DEBUG_02_delimiters_in_payload(testCase)
N = 3;
source = generate_debug_coe([], N);
spec   = debug_frame_spec(N);
% The pattern really contains both delimiters, also right before the end word.
verifyEqual(testCase, source([2 3 8]), [spec.start_word; spec.end_word; spec.end_word]);
words = decode_debug_frame(encode_frame(source), N);
verifyEqual(testCase, numel(words), 2^N);          % no truncation
verifyEqual(testCase, words, source);
end

function test_MT_DEBUG_02_payload_all_delimiters(testCase)
N = 3;
spec   = debug_frame_spec(N);
source = repmat([spec.end_word; spec.start_word], 2^N / 2, 1);
verifyEqual(testCase, decode_debug_frame(encode_frame(source), N), source);
end

%% MT-DEBUG-03 — corrupted header / short stream --------------------------------
function test_MT_DEBUG_03_short_stream(testCase)
bytes = encode_frame(generate_debug_coe([], 3));
verifyError(testCase, @() decode_debug_frame(bytes(1:end-1), 3), 'debug:frameLength');
verifyError(testCase, @() decode_debug_frame(bytes(1:20), 3),    'debug:frameLength');
verifyError(testCase, @() decode_debug_frame(uint8([]), 3),      'debug:frameLength');
end

function test_MT_DEBUG_03_long_stream(testCase)
bytes = encode_frame(generate_debug_coe([], 3));
verifyError(testCase, @() decode_debug_frame([bytes; uint8(0)], 3), 'debug:frameLength');
end

function test_MT_DEBUG_03_bad_start_word(testCase)
bytes = encode_frame(generate_debug_coe([], 3));
bytes(2) = 0xAB;
verifyError(testCase, @() decode_debug_frame(bytes, 3), 'debug:badStartWord');
end

function test_MT_DEBUG_03_bad_end_word(testCase)
bytes = encode_frame(generate_debug_coe([], 3));
bytes(end) = 0x00;
verifyError(testCase, @() decode_debug_frame(bytes, 3), 'debug:badEndWord');
end

function test_MT_DEBUG_03_lost_byte_in_middle(testCase)
% One byte lost mid-transfer and the frame padded back to full length:
% everything after the loss shifts, so the end word must fail.
bytes = encode_frame(generate_debug_coe([], 3));
bytes = [bytes(1:10); bytes(12:end); uint8(0xCC)];
verifyError(testCase, @() decode_debug_frame(bytes, 3), 'debug:badEndWord');
end

%% MT-DEBUG-04 — COE round trip --------------------------------------------------
function test_MT_DEBUG_04_coe_round_trip(testCase)
file  = [tempname, '.coe'];
clean = onCleanup(@() delete(file));
words = generate_debug_coe(file, 14);
verifyEqual(testCase, numel(words), 16384);
verifyEqual(testCase, read_coe(file), words);
end

function test_MT_DEBUG_04_coe_format(testCase)
% Same layout as the manual's example (DBG §3): radix line, vector line,
% one 8-digit hex word per line, commas, final semicolon.
file  = [tempname, '.coe'];
clean = onCleanup(@() delete(file));
generate_debug_coe(file, 3);
lines = splitlines(strtrim(fileread(file)));
verifyEqual(testCase, lines{1}, 'MEMORY_INITIALIZATION_RADIX=16;');
verifyEqual(testCase, lines{2}, 'MEMORY_INITIALIZATION_VECTOR=');
verifyEqual(testCase, numel(lines), 2 + 8);
verifyTrue(testCase, all(~cellfun(@isempty, regexp(lines(3:end-1), '^[0-9A-F]{8},$', 'once'))));
verifyEqual(testCase, lines{end}, 'AA5503CC;');
end

function test_MT_DEBUG_04_committed_coe_is_current(testCase)
% The ROM file in the repository must equal what the generator produces.
file = fullfile(testCase.TestData.repo_root, 'fpga', 'ip', 'debug_rom.coe');
verifyEqual(testCase, read_coe(file), generate_debug_coe([], 14));
end

%% compare_with_coe (demo check) ------------------------------------------------
function test_compare_reports_mismatch(testCase)
expected = generate_debug_coe([], 3);
received = expected;
received(6) = uint32(0xDEADBEEF);                  % address 5
result = compare_with_coe(received, expected);
verifyFalse(testCase, result.pass);
verifyEqual(testCase, result.num_mismatch, 1);
verifyEqual(testCase, result.mismatch_addr, 5);
verifyEqual(testCase, result.actual, uint32(0xDEADBEEF));
verifyTrue(testCase, compare_with_coe(expected, expected).pass);
end

function test_pattern_default_words(testCase)
% Default word = [address | NOT address], e.g. address 5 -> 0005FFFA.
words = generate_debug_coe([], 14);
verifyEqual(testCase, words(1),  uint32(0x0000FFFF));
verifyEqual(testCase, words(6),  uint32(0x0005FFFA));
verifyEqual(testCase, words(4),  uint32(0));          % address 3
verifyEqual(testCase, words(5),  uint32(0xFFFFFFFF)); % address 4
end

%% helper: model of the FPGA byte stream -----------------------------------------
function bytes = encode_frame(words)
spec = debug_frame_spec();
all_words = [spec.start_word; uint32(words(:)); spec.end_word];
b = [bitshift(all_words, -24), ...
     bitand(bitshift(all_words, -16), 255), ...
     bitand(bitshift(all_words, -8),  255), ...
     bitand(all_words, 255)].';                    % MSB byte first
bytes = uint8(b(:));
end
