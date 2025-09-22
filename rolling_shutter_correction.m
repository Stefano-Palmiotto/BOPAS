%==========================================================================
% Correct the mean exposure time associated with each streak centroid for
% the camera's rolling shutter
%
% INPUTS:
%   satellite_folder: path of the current satellite folder
%   all_streak_info: table of info about all the right detected streaks
%
% OUTPUTS:
%   tm_array: datetime array of corrected mean exposure times (time tags of the 
%   streak centroids, format: 'yyyy-MM-dd HH:mm:ss.SSSS')
%   mjd_array: array of corrected mean exposure times converted to MJD
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-02-11
%==========================================================================

function [tm_array, mjd_array, exp_time] = rolling_shutter_correction(satellite_folder, all_streaks_info)

%==========================================================================

mu = 20.65e-6; % rolling shutter line period (seconds)

%==========================================================================

disp('  Correct streak centroids'' time tags for rolling shutter')
disp('  ')

tm_array = [];

for j = 1:height(all_streaks_info)

    fits_name = char(all_streaks_info{j,'FITS file name'});

    fits_header = fitsinfo(strcat(satellite_folder,'/WCS_fits/',fits_name));

    % ti = datetime(fits_header.PrimaryData.Keywords{20,2}, 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSS');
    ti = datetime(fits_header.PrimaryData.Keywords{8,2}, 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSS');

    exp_time = seconds(str2double(fits_header.PrimaryData.Keywords{17,2}));

    % Global shutter mean time computation (before correction for rolling shutter)
    tm_array = [tm_array; ti + exp_time/2];
    
    ym = all_streaks_info{j,'Centroid y (pixel)'};
    camera_ID = fits_name(18:19);
    if strcmp(camera_ID,'T1') || strcmp(camera_ID,'T2')
        tm_array(end) = tm_array(end) + seconds((4095-ym)*mu);
    else
        tm_array(end) = tm_array(end) + seconds(ym*mu);
    end

end

mjd_array = juliandate(tm_array)-2400000.5;

end