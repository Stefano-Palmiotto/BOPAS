%==========================================================================
% Write astrometry report in the MPC ADES format
%
% INPUTS:
%   outputs_folder: folder of astrometry outputs
%   norad_ID: NORAD number of the current satellite
%   all_streaks_info: filtered table of information about all the detected
%   streaks
%   plate_sol_res_sigmas: filtered table of 1-sigma values of the RA and
%   Dec residuals from plate solution of the current satellite
%   tm_array: datetime array of streak centroids' time tags
%   exp_time: exposure time (seconds)
%   year, month, day: date of observation
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-03-06
%
% Update for norad_ID_i format on Mar 05, 2025 by Albino Carbognani
%==========================================================================

function write_ADES(outputs_folder, norad_ID, all_streaks_info, plate_sol_res_sigmas, tm_array, exp_time, year, month, day)

%==========================================================================

ZP = 12.3; % zero point of the instrumental magnitude

%==========================================================================

disp('  Compile ADES astrometry report')
disp('  ')

%  Write header metadata
fid = fopen(strcat(outputs_folder,'/ADES_Report_', string(norad_ID),'_',year,month,day,'.txt'),'wt+');

% Delete the progressive number fron norad_ID
parts = split(string(norad_ID), '_'); % Split at '_'
norad_ID = str2double(parts{1}); % Convert to numeric

fprintf(fid, '# version=2017\n');
fprintf(fid, '# observatory\n');
fprintf(fid, '! mpcCode D98\n');
fprintf(fid, '# submitter\n');
fprintf(fid, '! name Name Surname\n');
fprintf(fid, '# observers\n');
fprintf(fid, '! name Name Surname\n');
fprintf(fid, '# measurers\n');
fprintf(fid, '! name Name Surname\n');
fprintf(fid, '# telescope\n');
fprintf(fid, '! design reflector\n');
fprintf(fid, '! aperture 0.35\n');
fprintf(fid, '! fRatio 3.0\n');
fprintf(fid, '! detector CMO\n');
fprintf(fid, '# software\n');
fprintf(fid, '! astrometry Tycho 11.7.1\n');
fprintf(fid, '! photometry Tycho 11.7.1\n');
fprintf(fid, 'permID |provID     |trkSub  |mode|stn |obsTime                  |ra         |dec        |rmsRA|rmsDec|rmsFit|astCat  |mag  |rmsMag|band|photCat |photAp|logSNR|exp |notes|remarks\n');

for j = 1:height(all_streaks_info)
    
    % Compile RA measurement (N.B. the notation '_dec' stands for 'decimal digits', not declination)
    ra = all_streaks_info{j,'Centroid RA (deg)'};
    ra_int = fix(ra);
    ra_dec = fix(1.e6*(ra-ra_int));
    ra_string = strcat(num2str(ra_int,'%03.f'),'.',num2str(ra_dec,'%06.f'));

    % Compile Dec measurement
    dec = all_streaks_info{j,'Centroid Dec (deg)'};
    if dec >= 0
        sign = '+';
    else
        sign = '-';
    end
    dec = abs(dec);
    dec_int = fix(dec);
    dec_dec = fix(1.e6*(dec-dec_int));
    dec_string = strcat(num2str(dec_int,'%02.f'),'.',num2str(dec_dec,'%06.f'));

    % Estimate instrumental mag
    I_mag = ZP - 2.5*log10(all_streaks_info{j,'Best fit flux (ADU)'}/(seconds(exp_time)));
    mag_string = num2str(I_mag,'%02.1f');

    % Estimate SNR ratio of the trail
    SNR = log10(all_streaks_info{j,'SNR'});

    % Compiling satellite name according to the 7-digits MPC format
    sat_name = num2str(str2double(string(norad_ID)),'%07.f');

    % Compute total 1-sigma in RA and Dec, given by the contribution of the 
    % fit with the star catalog when plate solving plus the contribution
    % of the best fit with the gaussian trail 
    % (Assumption: all the measurements are uncorrelated)
    RA_sigma = sqrt((plate_sol_res_sigmas{j,'RA residuals 1-sigma (arcsec)'})^2 + (all_streaks_info{j,'1-sigma of centroid RA (deg)'})^2);
    Dec_sigma = sqrt((plate_sol_res_sigmas{j,'Dec residuals 1-sigma (arcsec)'})^2 + (all_streaks_info{j,'1-sigma of centroid Dec (deg)'})^2);
    
    % Compiling j-th line of the ADES report:
    % fprintf(fid, strcat(sat_name,'|',"           ",'|        | CMO|598 |',...
    %     string(datetime(tm_array(j),'Format','uuuu-MM-dd''T''HH:mm:ss.SSS')),'Z |',...
    %     ra_string," ",'|',sign,dec_string,...
    %     ' |',num2str(RA_sigma,'%1.1f'),  '  |', num2str(Dec_sigma,'%1.1f'),...
    %     '   |', num2str(sqrt(RA_sigma^2+Dec_sigma^2),'%1.1f'),...
    %     '   |  GaiaR2|', mag_string,'  |0.2   |  Vj|  GaiaR2| 8.0  |', num2str(SNR,'%1.1f'),'   |', num2str(seconds(exp_time),'%02.2f'),'|     |\n'));
 fprintf(fid, strcat(sat_name,'|',"           ",'|        | CMO|104 |',...
        string(datetime(tm_array(j),'Format','uuuu-MM-dd''T''HH:mm:ss.SSS')),'Z |',...
        ra_string," ",'|',sign,dec_string,...
        ' |',num2str(RA_sigma,'%1.1f'),  '  |', num2str(Dec_sigma,'%1.1f'),...
        '   |', num2str(sqrt(RA_sigma^2+Dec_sigma^2),'%1.1f'),...
        '   |  GaiaR2|', mag_string,'  |0.2   |  Vj|  GaiaR2| 8.0  |', num2str(SNR,'%1.1f'),'   |', num2str(seconds(exp_time),'%02.2f'),'|     |\n'));

end

fclose(fid);

end