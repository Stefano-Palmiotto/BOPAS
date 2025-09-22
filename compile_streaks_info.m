%==========================================================================
% Compile the information about the streaks in the current fits file in the
% last new row of the 'all_streaks_info' table and in the
% 'streaks_info.txt' file related to the current fits file
%
% INPUTS:
%   fits: name the current fits file
%   all_streaks_info: table which stores all the information about all the 
%   streaks detected in the satellite images
%   cc_props: struct array of the streak properties
%   slope_array: array of the streak slopes (deg)
%   aspect_ratio_array: array of the streak aspect ratios
%   centroid_pixel_array: array of the pixel coords of the best fit
%   centroids
%   centroid_ra_dec_array: array of the topocentric (RA, Dec) coordinates of
%   the streak centroids
%   outputs_folder: path of the astrometry outputs folder
%
% OUTPUTS:
%   all_streaks_info: updated 'all_streaks_info' table
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-02-16
%==========================================================================

function all_streaks_info = compile_streaks_info(fits, all_streaks_info, cc_props, slope_array, aspect_ratio_array,...
    B_fit_array, B_sigma_array, centroid_pixel_array, centroid_ra_dec_array, outputs_folder)

warning('off','MATLAB:table:RowsAddedExistingVars')

if isempty(cc_props)
    % Compile empty row of the 'all_streaks_info' table
    all_streaks_info(end+1,:) = {fits, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN};
else

    for j = 1:length(cc_props)
        
        % FITS file name
        all_streaks_info{end+1,'FITS file name'} = fits;
        
        % Centroid data
        all_streaks_info{end,'Centroid RA (deg)'} = centroid_ra_dec_array(j,1);
        all_streaks_info{end,'Centroid Dec (deg)'} = centroid_ra_dec_array(j,2);

        all_streaks_info{end,'Centroid x (pixel)'} = centroid_pixel_array(j,1);
        all_streaks_info{end,'Centroid y (pixel)'} = centroid_pixel_array(j,2);

        all_streaks_info{end,'1-sigma of centroid RA (deg)'} = B_sigma_array(j,5)*1.78/3600;
        all_streaks_info{end,'1-sigma of centroid Dec (deg)'} = B_sigma_array(j,6)*1.78/3600;
        
        % Geometric features
        all_streaks_info{end,'Area (pixel)'} = cc_props(j).Area;
        all_streaks_info{end,'Major axis length (pixel)'} = cc_props(j).MajorAxisLength;
        all_streaks_info{end,'Minor axis length (pixel)'} = cc_props(j).MinorAxisLength;
        all_streaks_info{end,'Aspect Ratio'} = aspect_ratio_array(j);
        all_streaks_info{end,'Slope (deg)'} = slope_array(j);
        
        % Signal properties
        all_streaks_info{end,'Best fit flux (ADU)'} = B_fit_array(j,2);
        all_streaks_info{end,'SNR'} = B_fit_array(j,2)/sqrt(B_fit_array(j,2)+B_fit_array(j,1)); % SNR = S/sqrt(S+B) (Veres)
    
    end

    % Create text file for the current fits file where to write the
    % information about each streak detected in the image
    write_image_table(all_streaks_info(end-length(cc_props)+1:end,:),...
        strcat(outputs_folder,'/',erase(fits,".fits"),'/streak_detection_astrometry/streaks_info.txt'));

end

end