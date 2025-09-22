%==========================================================================
% Filter out empty rows and  keep the rows of 'plate_sol_res_sigmas' with
% same fits file name as in 'all_streaks_info'. Then, filter out extra rows
% related to streaks of other satellites using a median slope filter.
%
% For GEO satellites, before the median slope filter, there is an ephemeris filter
% to delete the other GEO satellites eventually present in the images with the same
% slope of the target, and that can not deleted using the median slope filter.
%
% INPUTS:
%   plate_sol_res_sigmas: table with 1-sigmas of RA and Dec residuals from
%   plate solution
%   all_streaks_info: table with information about all the streaks detected
%   in all the images of the current satellite
%   satellite_folder: path of the current satellite folder
%   norad_ID: norad identifier of the satellite
%
% OUTPUTS:
%   the same tables, but empty and extra rows are filtered out
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Added the ephemeris filter for GEO satellites on March 12, 2025 (AC, INAF-OAS)
% Requested extra functions:
% 1-download_tle  
% 2-classifySatelliteFromTLE
% 3-SGP4_Ephemeris_sat with the folder SST_SGP4
%
% Version: 2025-03-12
%==========================================================================

function [plate_sol_res_sigmas, all_streaks_info] = filter_table_rows(plate_sol_res_sigmas, all_streaks_info, satellite_folder, norad_ID,...
    TLE2Eph_folder, year, month, day)

%==========================================================================

slope_threshold = 5; % deg
ephem_threshold = 400; % arcsec

%==========================================================================

all_nan_idx = [];

% Delete empty rows with NaN values
for j = 1:height(all_streaks_info)
    
    if isnan(all_streaks_info{j,'Centroid x (pixel)'})
        fits_name = all_streaks_info{j,'FITS file name'};
        all_nan_idx = [all_nan_idx, j];
        plate_sol_res_sigmas( strcmp(plate_sol_res_sigmas.('FITS file name'), fits_name), : ) = [];
    end
end

all_streaks_info(all_nan_idx,:) = [];

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Ephemeris filter for GEO satellite %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parts = split(string(norad_ID), '_'); % Split at '_'
norad_ID = parts{1}; % String norad number

orbitType = download_tle(strcat(TLE2Eph_folder,'/',year,'-',month,'-',day), norad_ID);

% Determine if the satellite is a GEO
tf = strcmp(orbitType,'GEO');

if tf==1
   % Compute MJD for streaks with rolling shutter correction
   [~, mjd_array,~] = rolling_shutter_correction(satellite_folder, all_streaks_info);

   % Position of TLE file
   temp_tle=strcat(satellite_folder, '\TLE_', norad_ID, '.txt');

   RA=[]; DEC=[];

   % Compute ephemeris from TLE, J2000, deg
   disp(strcat('Compute ephemeris for GEO NORAD'," ", norad_ID))

   for k=1:length(mjd_array)

      [RA(k), DEC(k)]=SGP4_Ephemeris_sat(temp_tle, 44.2591667, 11.334444, 785.000, mjd_array(k));

   end

   % Observed positions, deg
   RA0=all_streaks_info.('Centroid RA (deg)');
   DEC0=all_streaks_info.('Centroid Dec (deg)');

   % Compute difference observed-computed, arcsec
   O_C=3600*sqrt(((RA'-RA0).*cosd(DEC0)).^2+(DEC'-DEC0).^2);

   % Apply ephemeris filter to delete extra lines
   all_streaks_info(O_C > ephem_threshold,:) = [];

else
   disp(strcat('Satellite NORAD'," ", norad_ID," ",'is not a GEO, skip ephemeris filter'))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% median slope filter satellite %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute median slope value
median_slope = median(all_streaks_info.('Slope (deg)'));
fprintf('  Median slope of the streak: %f deg\n', median_slope)

% Apply slope filter to delete extra lines
all_streaks_info(abs(all_streaks_info.('Slope (deg)')-median_slope)>slope_threshold,:) = [];

end