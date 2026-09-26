function words = read_coe(filename)
%READ_COE  Read a Vivado COE memory file into a uint32 column.
%
%   words = read_coe(filename)
%
%   words(k+1) is the content of memory address k. Supports radix 2, 10 and 16
%   and COE comment lines (starting with ';'). Used to compare received data
%   with the ROM content and for the COE round-trip test.
%
%   Purpose : reference data for the Lab-DEBUG demo check
%   Reqs    : REQ-DEBUG-017; test MT-DEBUG-04
%   Author  : Ömer (omerkutlu1030)
%   AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0007

if ~isfile(filename)
    error('debug:coeRead', 'COE file "%s" not found.', filename);
end
lines = splitlines(fileread(filename));
lines = lines(~startsWith(strtrim(lines), ';'));      % drop comment lines
text  = strjoin(lines, newline);

radix_tok = regexpi(text, 'memory_initialization_radix\s*=\s*(\d+)\s*;', 'tokens', 'once');
vec_tok   = regexpi(text, 'memory_initialization_vector\s*=([^;]*);', 'tokens', 'once');
if isempty(radix_tok) || isempty(vec_tok)
    error('debug:coeRead', '"%s" is not a valid COE file (radix or vector missing).', filename);
end
radix  = str2double(radix_tok{1});
values = regexp(vec_tok{1}, '[^\s,]+', 'match').';

switch radix
    case 16
        numbers = hex2dec(values);
    case 10
        numbers = str2double(values);
    case 2
        numbers = bin2dec(values);
    otherwise
        error('debug:coeRead', 'Unsupported COE radix %d.', radix);
end
if any(isnan(numbers)) || any(numbers < 0 | numbers > double(intmax('uint32')))
    error('debug:coeRead', '"%s" contains values that are not 32-bit unsigned numbers.', filename);
end
words = uint32(numbers);
end
