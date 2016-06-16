function c = csv2cell(filename, varargin)

% c = csv2cell(filename, <sep>, <prot>, <row>, <col>, <makenum>, <progress>)
% Read a csv file into a cell array.  Empty cells will be returned as an
% empty string within the cell.  Numbers will be converted to doubles.
%
% filename - the file to read
% sep      - (optional) the separator, default: ','
% prot     - (optional) the protector for strings with commas, default: '"'
% row      - (optional) the row number to start reading, default: 1
% col      - (optional) the column number to start reading, default: 1
% makenum  - (optional) convert the cells to numbers instead of text as is
%            possible, default: 1
% progress - (optional) show the progress down the file.  If set above 0,
%            it will display a message of the number of lines that it has
%            read and an approximate percentage that it has completed
%            through the file, default: 1000.
%
% c - the cell array of the data from the csv file.
%
% WARNING: If str2num returns nonempty, the cell is converted to a number,
% and this can have unintended consequences when there is text like '5-1'
% in the cell.

%%%%%
% Constants
%%%%%

% how much more than estimated should we pre-allocate if the file is large?
preallocationpercent = 1.05;
% when should we start pre-allocating?
preallocationlines = 1000;
% when should we allow re-pre-allocating?
preallocationlinesagain = 5000;

%%%%%
% Process input arguements
%%%%%

if (length(varargin) < 1)
    sep = ',';
elseif isempty(varargin{1})
    sep = ',';
else
    sep = varargin{1};
end
if (length(varargin) < 2)
    prot = '"';
elseif isempty(varargin{2})
    prot = '"';
else
    prot = varargin{2};
end
if (length(varargin) < 3)
    row = 1;
elseif isempty(varargin{3})
    row = 1;
else
    row = varargin{3};
end
if (length(varargin) < 4)
    col = 1;
elseif isempty(varargin{4})
    col = 1;
else
    col = varargin{4};
end
if (length(varargin) < 5)
    makenum = 1;
elseif isempty(varargin{5})
    makenum = 1;
else
    makenum = varargin{5};
end
if (length(varargin) < 6)
    progress = 1000;
elseif isempty(varargin{6})
    progress = 1000;
else
    progress = varargin{6};
end

if (length(sep) ~= 1)
    error('The separator must be one character long')
elseif (length(prot) > 1)
    error('The protector must be 0 or 1 character long')
end

%%%%%
% Do Stuff
%%%%%

% determine the file info
finfo = dir(filename);
bytesprocessed = 0;
lasttime = cputime;

% read in the file
[fid, errmsg] = fopen(filename);
if (fid == -1)
    error('Unable to open %s: %s', filename, errmsg);
end

thistext(1,1:10000) = ' ';
i = 0;
c = {};
while 1
    % read in all lines of the file
    i = i + 1;
    txt = fgetl(fid);
    if (~ischar(txt))
        fclose(fid);
        % remove additional pre-allocated lines if necessary
        if ((i-1) < size(c,1))
            %fprintf('Removing lines %g to %g.\n', i, size(c,1));
            c = c(1:(i-1),:);
        end
        return
    end

    % process the line's contents
    thiscol = 1;
    protected = 0;
    j = 0;
    writenow = 0;
    ttidx = 0;
    while j < length(txt)
        j = j + 1;
        if (protected && strcmp(txt(j), prot))
            if (length(txt) > j)
                if strcmp(txt(j+1), prot)
                    % check the next character to see if the protection
                    % character is supposed to be in there
                    j = j + 1;
                    ttidx = ttidx + 1;
                    thistext(ttidx) = txt(j);
                elseif strcmp(txt(j+1), sep)
                    protected = 0;
                    writenow = 1;
                    j = j + 1;
                else
                    error('Unprotection of a string in the middle of cell (%g, %g)', i, thiscol);
                end
            else
                protected = 0;
                writenow = 1;
            end
        elseif strcmp(txt(j), prot)
            % an unprotected protection character
            if (ttidx > 0)
                error('Unprotected protection character in cell (%g,%g)', i, thiscol);
            end
            protected = 1;
        elseif (protected && strcmp(txt(j), sep))
            % this is a protected separator, leave it in
            ttidx = ttidx + 1;
            thistext(ttidx) = txt(j);
        elseif strcmp(txt(j), sep)
            % an unprotected separator
            writenow = 1;
        elseif (j == length(txt))
            % the last character on the line
            if protected
                warning('Unterminated protection at the end of row %g (continuing, but this is an ill-formed file)', i)
            end
            ttidx = ttidx + 1;
            thistext(ttidx) = txt(j);
            writenow = 1;
        else
            % a regular character
            ttidx = ttidx + 1;
            thistext(ttidx)= txt(j);
        end

        % write the data to the array
        if writenow
            thiscell = thistext(1:ttidx);
            if ((i >= row) && (thiscol >= col))
                if makenum
                    % find out if this could be numeric before trying to
                    % run str2num.
                    couldbenumeric = all(ismember(strtrim(thiscell), '1234567890eE+-ijIJ.'));
                    if couldbenumeric
                        numeric = str2double(thiscell);
                        if isempty(numeric) || isnan(numeric)
                            c{i,thiscol} = thiscell;
                        else
                            c{i,thiscol} = numeric;
                        end
                    else
                        c{i,thiscol} = thiscell;
                    end
                else
                    c{i,thiscol} = thiscell;
                end
            end
            thiscol = thiscol + 1;
            writenow = 0;
            ttidx = 0;
        end
    end

    bytesprocessed = bytesprocessed + length(txt) + 2;
    percentdone = 100*bytesprocessed/finfo.bytes;
    % pre-allocate space if this turns out to be a large file
    if (((i == preallocationlines) && (percentdone < 20)) || ...
            ((i == size(c,2)) && (i > preallocationlinesagain)))
        c = [c;cell(floor(preallocationpercent*i/(percentdone/100)), ...
            size(c,2))];
    end

    if progress
        % FIXME- can we determine the length of the line separator instead
        % of assuming \r\n?
        if (0 == mod(i, progress))
            fprintf('Line %g processed, %g%% through the file, %g seconds used for this set.\n', ...
                i, percentdone, cputime-lasttime);
            lasttime = cputime;
        end
    end
end