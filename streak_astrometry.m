%==========================================================================
% Compute best fit with axisymmetric Gaussian trail and convert pixel
% coordinates of the best fit centroid into topocentric (RA, Dec) coordinates
% by means of the WCS constants stored in the calibrated fits file after
% plate solution
%
% INPUTS:
%   gray_image: gray scale version of the current fits file
%   cc_props: struct array of the streak properties
%   centroid_xy_array: array of the pixel coords of the detected streak centroids
%   slope_array: array of the slopes of the detected streak centroids
%   bbox_array: array of the bounding box properties of the detected streak centroids
%   crop_frame_dim: dimension of the image border to cut (pixel)
%   python_exe: absolute path of the Python executable
%   WCS_fits_path: absolute path of the WCS-calibrated fits
%
% OUTPUTS:
%   B_fits_array: array of the best fit parameters for all the streaks in the image
%   B_sigma_array: array of the 1-sigma uncertianties of the best fit
%   params for all the streaks in the image
%   centroid_pixel_array: array of the pixel coords of the best fit
%   centroids
%   centroid_ra_dec_array: array of the topocentric (RA, Dec) coordinates of
%   the streak centroids
%   Z_fit_array: cell array of the Z_fit arrays (see axisymmetric_Gaussian_best_fit_trail)
%   for all the streaks in the image
%
% Author: Stefano Palmiotto, Alma mater Studiorum - University of Bologna
%
% Version: 2025-02-10
%==========================================================================

function [B_fit_array, B_sigma_array, centroid_pixel_array, centroid_ra_dec_array, Z_fit_array] = streak_astrometry(gray_image, cc_props,...
    centroid_xy_array, slope_array, bbox_array,...
    crop_frame_dim, python_exe, WCS_fits_path)

% Set up output arrays
B_fit_array = zeros(length(cc_props),7);
B_sigma_array = zeros(length(cc_props),7);
centroid_pixel_array = zeros(length(cc_props),2);
centroid_ra_dec_array = zeros(length(cc_props),2);
Z_fit_array = cell(length(cc_props),1);

for j = 1:length(cc_props)

    % Set up the array B of the initial guess values for best fit with axisymmetric Gaussian trail
    B(1) = mean(mean(gray_image)); % Background, ADU
    B(3) = cc_props(j).MajorAxisLength; % Length trail, pixel
    B(4) = 1; % Sigma, pixel
    B(2) = 10*B(3)*B(1); % Estimated Flux, ADU
    B(5) = round(centroid_xy_array(j,1));  % centroid x coordinate, pixel
    B(6) = round(centroid_xy_array(j,2));  % centroid y coordinate, pixel
    B(7) = slope_array(j);  % Slope, deg

    [B_fit, B_sigma, Z_fit] = axisymmetric_Gaussian_best_fit_trail(B, gray_image, bbox_array(j,:));

    if B_fit(4)<0
        disp('  WARNING: Sigma of the best fit trail is negative')
    end

    B_fit_array(j,:) = reshape(B_fit, 1, []);
    B_sigma_array(j,:) = reshape(B_sigma, 1, []);
    Z_fit_array{j} = Z_fit;

    % If the image border has been cut to avoid detection of the
    % TANDEM fits lateral black strip, bring pixel coordinates
    % back to their original value to ensure consistency with
    % the original image during later pocessing
    centroid_pixel_coord = [B_fit(5), B_fit(6)] + crop_frame_dim;
    centroid_pixel_array(j,:) = centroid_pixel_coord;
    
    % Save centroid's pixel coordinates in a .mat file as input for Python
    is_new_folder('./tmp_mat_files')
    save('./tmp_mat_files/CentroidPixelCoord.mat', 'centroid_pixel_coord');

    % Call Python method to compute the centroid's (RA, Dec) coordinates 
    % from pixel coordinates
    command_line = strcat(python_exe," pixel2RADec.py"," ",WCS_fits_path);
    system(command_line);

    load('./tmp_mat_files/CentroidRADecCoord.mat','centroid_ra_dec_coord');
    centroid_ra_dec_array(j,:) = centroid_ra_dec_coord;

end

end