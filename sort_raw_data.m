%==========================================================================
% File sorting script: get all the fits images in the raw data folder, 
% create the folders yyyy-MM-dd/NORAD ID/raw_fits and move the fits images 
% from the raw data folder in the right folders, ready to be processed
%
% INPUTS:
%    raw_data_folder = abolute path of the raw data folder
%    global_outputs_folder = absolute path of the mini-BASP outputs folder
%
% Author: Albino Carbognani, INAF-OAS
%
% Version: 2025-03-05
%==========================================================================

function sort_raw_data(raw_data_folder, global_outputs_folder)

disp('Sorting raw data:')

% List the fits files in the raw data folder, if it exists, otherwise it exits the execution
if isfolder(raw_data_folder)
    disp('  List all the fits files in the raw data folder')
    fits_list = list_dir_content(raw_data_folder);
else
    disp('  The raw data folder you have specified does not exist.')
    disp('  Make sure to create it and/or to specify its correct absolsute path in ''settings.txt''')
    return
end

if isempty(fits_list)
    disp('  The raw data folder is empty. Sorting the raw data is not possible')
    return
else 
    fprintf('  Proceed to sort the %u images in the raw data folder', length(fits_list));
end

for j = 1:length(fits_list)
    
    % Extract metadata from current fits header to build the name of the raw fits
    % folder where it will be stored
    fits_header = fitsinfo(strcat(raw_data_folder,'/',fits_list{j}));
    ti = datetime(fits_header.PrimaryData.Keywords{20,2});
    [Y,M,d] = ymd(ti); % Year, month and day of the image
    norad_ID = fits_header.PrimaryData.Keywords{23,2}; % Satellite's NORAD number
    
    raw_image_folder = strcat(global_outputs_folder,'/',num2str(Y),'-',num2str(M,'%02.f'),'-',num2str(d,'%02.f'),'/',norad_ID,'/raw_fits');

    % If it doesn't exist, make the raw fits folder where to store the
    % current fits file
    is_new_folder(raw_image_folder);
    
    % Move raw fits file from raw data folder into its new raw fits folder
    movefile(strcat(raw_data_folder,'/',fits_list{j}), raw_image_folder);

end

disp('  All the raw fits files have been sorted in the right folders')
disp('   ')

end