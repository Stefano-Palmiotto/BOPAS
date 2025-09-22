%==========================================================================
% BOPAS main
%
% Authors: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%          Albino Carbognani, INAF-OAS
%
% Version: 2025-07-26
%==========================================================================

%==========================================================================
% INITIAL SET UP OPERATIONS 
%==========================================================================

% Operations on the Matlab environment
clc % Clear Command Window
% clear % Clear Workspace
warning('off','MATLAB:table:RowsAddedExistingVars')

% Display title
disp('===========================================================')
disp('                         BOPAS                             ')
disp(' Bologna Observatory Pipeline for Astrometry of Satellites ')
disp('                                                           ')
disp('                  Version: 2025-07-26                      ')
disp('===========================================================')
disp('  ')

% Read settings
disp('Read settings')
disp('  ')

settings = regexp( fileread('./settings.txt') ,'\$+', 'split' );

raw_data_folder = strtrim(settings{5});
global_outputs_folder = strtrim(settings{8});
astrometry_exe = strtrim(settings{11});
python_exe = strtrim(settings{14});
TLE2Eph_folder = strtrim(settings{17});

year = strtrim(settings{20});
month = strtrim(settings{23});
day = strtrim(settings{26});

sort_option = str2double(settings{29});
plate_sol_option = str2double(settings{32});
streak_option = str2double(settings{35});

% Sort raw fits files in the right structure folders
if sort_option == 1
   sort_raw_data(raw_data_folder, global_outputs_folder)
end

% Display the date of the observations to process
disp('------------------------------------------------------')
disp('  ')
fprintf('Date of observation: %s-%s-%s\n',year,month,day);
disp('  ')
disp('------------------------------------------------------')
disp('  ')

% List all the satellites observed on the selected date
disp('List NORAD numbers of the observed satellites')

date_folder = strcat(global_outputs_folder,'/',year,'-',month,'-',day);
if ~isfolder(date_folder)
    disp('WARNING: the raw fits file are not sorted in the right folders. Quit the run')
    return
end

norad_list = list_dir_content(date_folder);
if isempty(norad_list)
    disp('WARNING: there are zero satellite folders. Quit the run')
    return
end

disp('  ')

%==========================================================================
% ASTROMETRY OF THE OBSERVED SATELLITES
%==========================================================================

for i = 1:length(norad_list)

    norad_ID = norad_list(i);
    
    % Display current satellite's NORAD number
    disp('------------------------------------------------------')
    disp('  ')
    disp(strcat('NORAD'," ",norad_ID));
    disp('  ')
    
    %======================================================================
    % SET UP FOLDERS
    %======================================================================

    disp('  Set up all the folders')
    disp('  ')

    % Define absolute path of the folder of the current satellite.
    % This folder will contain raw fits, calibrated fits and astrometry outputs
    satellite_folder = strcat(date_folder,'/',norad_ID);
    
    % Define absolute path of the WCS-calibrated fits folder in the current satellite
    % folder. If it doesn't exist, the folder is created
    wcs_folder = strcat(satellite_folder, '/WCS_fits');
    is_new_folder(wcs_folder);

    % Define absolute path of the astrometry outputs folder in the current
    % satellite folder. If it doesn't exist, the folder is created
    outputs_folder = strcat(satellite_folder, '/astrometry_outputs');
    is_new_folder(outputs_folder);

    % If they do not exist, create the subfolders of the astrometry outputs
    % folder
    fits_list = list_dir_content(strcat(satellite_folder,'/raw_fits/*.fits'));
  
    for j = 1:length(fits_list)
        fits_name = erase(fits_list(j), ".fits");

        is_new_folder(strcat(outputs_folder,'/',fits_name))
        is_new_folder(strcat(outputs_folder,'/',fits_name,'/plate_solution'))
        is_new_folder(strcat(outputs_folder,'/',fits_name,'/streak_detection_astrometry'))
    end

    %======================================================================
    % PLATE SOLUTION
    %======================================================================

    % You have to compute the plate solution the first time, then you can 
    % switch the plate solution option as you like in 'settings.txt'
    if plate_sol_option == 1
        
        % Create the table 'plate_sol_res_sigmas' in which to write down, line by
        % line, the 1-sigma of RA and Dec residuals of each plate-solved
        % image of the current satellite
        table_variables = ["FITS file name", "string";...
            "RA residuals 1-sigma (arcsec)", "double";...
            "Dec residuals 1-sigma (arcsec)", "double";...
            "Number of stars", "uint64"];

        plate_sol_res_sigmas = table('Size', [0, length(table_variables)],...
            'VariableNames', table_variables(:,1),...
            'VariableTypes', table_variables(:,2));

        disp('  Start plate solving')
        disp('  ')

        for j = 1:length(fits_list)
            fits = fits_list(j);

            disp(strcat('  Compute plate solution of the raw file', " ", fits));
            disp('  ')
            plate_solution(satellite_folder, fits, astrometry_exe)
            
            disp('  Make uncertainty analysis of the plate solution');
            
            try
                [x_cat,y_cat,RA_cat,Dec_cat,x_cmp,y_cmp,RA_cmp,Dec_cmp] = read_corr_file(strcat(satellite_folder,'/raw_fits/',erase(fits,".fits"),'.corr'));
                [RA_res, Dec_res, plate_sol_res_sigmas] = plate_sol_res(RA_cat, Dec_cat, RA_cmp, Dec_cmp, outputs_folder, fits, plate_sol_res_sigmas);
            catch
                disp('  Astrometry didn''t find enough stars for the selected polynomial order. Move to next FITS file')
                continue
            end
      
            disp('  ')

        end
        
        % Show median values of residuals' 1-sigmas
        fprintf('   Median 1-sigma of RA residuals from plate solve by Astrometry.net (arcsec): %f\n', median(plate_sol_res_sigmas{:,'RA residuals 1-sigma (arcsec)'}))
        fprintf('   Median 1-sigma of Dec residuals from plate solve by Astrometry.net (arcsec): %f\n', median(plate_sol_res_sigmas{:,'Dec residuals 1-sigma (arcsec)'}))
        disp('  ')

        % save as a text file the 'plate_sol_res_sigmas' table
        writetable(plate_sol_res_sigmas, strcat(outputs_folder,'/plate_sol_res_sigmas.txt'), 'Delimiter', '\t')
    end

    %======================================================================
    % AUTOMATED DETECTION AND ASTROMETRY OF STREAKS
    %======================================================================
    if streak_option == 1

        if ~isfile(strcat(outputs_folder,'/plate_sol_res_sigmas.txt'))
            disp('  WARNING: none of the FITS files has been plate solved yet. Move to next satellite')
            disp('  ')
            continue
        end

        disp('  Start streak detection and astrometry of calibrated FITS files')
        disp('  ')

        % Create the table 'all_streaks_info' in which to write down, line by
        % line, the information relative to all the streaks detected in the images of
        % the current satellite
        table_variables = ["FITS file name", "string";...
            "Centroid x (pixel)", "double";...
            "Centroid y (pixel)", "double";...
            "Centroid RA (deg)", "double";...
            "Centroid Dec (deg)", "double";...
            "1-sigma of centroid RA (deg)", "double";...
            "1-sigma of centroid Dec (deg)", "double";...
            "Area (pixel)", "double";...
            "Major axis length (pixel)", "double";...
            "Minor axis length (pixel)", "double";...
            "Aspect Ratio", "double";...
            "Slope (deg)", "double";...
            "Best fit flux (ADU)", "double";...
            "SNR", "double"];

        all_streaks_info = table('Size', [0, length(table_variables)],...
            'VariableNames', table_variables(:,1),...
            'VariableTypes', table_variables(:,2));
        
        tic
        for j = 1:length(fits_list)
            fits = fits_list(j);

            disp(strcat('   Processing file', " ", fits));

            % try
                [binary_image, crop_frame_dim, gray_image] = binary_segmentation(satellite_folder, fits);
    
                [valid_idx, cc_props, aspect_ratio_array] = streak_detection(binary_image);
    
                [slope_array, centroid_xy_array, bbox_array] = edit_props_arrays(cc_props, gray_image);
    
                [B_fit_array, B_sigma_array, centroid_pixel_array, centroid_ra_dec_array, Z_fit_array] = streak_astrometry(gray_image, cc_props,...
                    centroid_xy_array, slope_array, bbox_array,...
                    crop_frame_dim, python_exe, strcat(satellite_folder,'/WCS_fits/',fits));
    
                all_streaks_info = compile_streaks_info(fits, all_streaks_info, cc_props, slope_array, aspect_ratio_array,...
                    B_fit_array, B_sigma_array, centroid_pixel_array, centroid_ra_dec_array, outputs_folder);
                
                sda_folder = strcat(outputs_folder,'/',erase(fits,".fits"),'/streak_detection_astrometry');
                show_streaks(gray_image, crop_frame_dim, binary_image, cc_props,...
                    valid_idx, sda_folder, bbox_array, Z_fit_array, centroid_pixel_array)
            % catch
            %     disp('  The plate solution for this FITS file doesn''t exist. Move to next FITS file')
            %     continue
            % end
        end
        toc
        
        disp('  ')
        disp('  Streak detection and astrometry are complete')
        disp('  ')


        %==================================================================
        % ASTROMETRY REPORTS
        %==================================================================

        % Read 'plate_sol_res_sigmas.txt' as a table
        plate_sol_res_sigmas = readtable(strcat(outputs_folder,'/plate_sol_res_sigmas.txt'), 'Delimiter', '\t', 'PreserveVariableNames', 1);%'VariableNamingRule', 'preserve');
        
        % Filter tables
        [plate_sol_res_sigmas, all_streaks_info] = filter_table_rows(plate_sol_res_sigmas, all_streaks_info, satellite_folder, norad_ID, TLE2Eph_folder, year, month, day);

        if height(all_streaks_info) > height(plate_sol_res_sigmas)
            disp('  WARNING: there are still extra satellite in all_streaks_info table. Move to next satellite')
            disp('  ')
            continue
        end

        fprintf('  Detected streaks of NORAD %s in %d images out of %d. Rate of success: %.2f%% \n', norad_ID, height(all_streaks_info), length(fits_list), height(all_streaks_info)/length(fits_list)*100)
        disp('  ')

        if isempty(all_streaks_info)
            disp('  Zero detected streaks in the images. Move to next satellite')
            disp('  ')
            continue
        end
        
        % Correct for rolling shutter
        disp('  Correct for rolling shutter')
        disp('  ')
        [tm_array, mjd_array, exp_time] = rolling_shutter_correction(satellite_folder, all_streaks_info);
        
        % Compile astrometry reports
        disp('  Compile astrometry reports')
        disp('  ')
        write_MPC_80_col(outputs_folder, norad_ID, all_streaks_info, tm_array, exp_time)
        write_ADES(outputs_folder, norad_ID, all_streaks_info, plate_sol_res_sigmas, tm_array, exp_time, year, month, day)
        write_TDM(outputs_folder, norad_ID, all_streaks_info, tm_array, year, month, day)
        
        % Plot RA and Dec vs. MJD  and observation number
        RADec_vs_MJD_N(mjd_array, all_streaks_info, norad_ID, outputs_folder, year, month, day)
        
    end

end

disp('  ')
disp('------------------------------------------------------')
disp('  ')
disp('Done!')
disp('  ')

fclose all;