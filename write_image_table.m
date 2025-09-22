%==========================================================================
% Write the rows of the 'all_streaks_info' table related to the
% current fits file into the 'streaks_info.txt' file
%
% INPUTS:
%   T: rows of the 'all_streaks_info' table related to the current fits
%   file
%   path: absolute path of the 'streaks_info.txt' file where to write down
%   all the information about the streaks detected in the current fits
%   file
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-01-27
%==========================================================================

function write_image_table(T, path)

% Save rows into T_mod to change the name of the fits filename with the streak number in the image
T_mod = T;

T_mod.Properties.VariableNames{1} = 'Streak number';

% Number of additional blank spaces after each column
tab_space = 4;

% Minimum column width = 5, but you can change this value as you like
column_widths = max(cellfun(@length, T_mod.Properties.VariableNames), 5) + tab_space;

% Create dynamic format for each column
formatSpecHeader = '';
formatSpecRow = '';
for i = 1:length(column_widths)
    formatSpecHeader = [formatSpecHeader, '%-', num2str(column_widths(i)), 's']; % Formato per l'intestazione
    formatSpecRow = [formatSpecRow, '%-', num2str(column_widths(i)), 's']; % Formato per i dati
end
formatSpecHeader = [formatSpecHeader, '\n']; % Aggiungi un a capo
formatSpecRow = [formatSpecRow, '\n']; % Aggiungi un a capo

% Open the file 'streaks_info.txt'
fid = fopen(path, 'wt+');

% Write table header and divider
fprintf(fid, formatSpecHeader, T_mod.Properties.VariableNames{:});

divider = repmat('_', 1, sum(column_widths));
fprintf(fid, '%s\n', divider);

% Write table data
for i = 1:height(T_mod)

    rowData = cell(1, width(T_mod));

    for j = 1:width(T_mod)
        if isstring(T_mod{i, j}) || ischar(T_mod{i, j}) % Change fits file name with streak number
            rowData{j} = num2str(i);
        elseif isnan(T_mod{i, j}) % Write NaN values
            rowData{j} = 'NaN';
        else
            rowData{j} = num2str(T_mod{i, j}); % Write remaining numeric data
        end
    end

    fprintf(fid, formatSpecRow, rowData{:});

end

% Close text file
fclose(fid);

end