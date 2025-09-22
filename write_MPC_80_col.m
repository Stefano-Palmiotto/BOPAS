function write_MPC_80_col(outputs_folder, norad_ID, all_streaks_info, tm_array, exp_time)
%==========================================================================
% Write astrometry report in the old MPC-80-column format
%
% INPUTS:
%   outputs_folder: folder of astrometry outputs
%   norad_ID: NORAD number of the current satellite
%   all_streaks_info: filtered table of information about all the detected
%   streaks
%   tm_array: datetime array of streak centroids' time tags
%   exp_time: exposure time (seconds)
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-03-06
%
% Update for norad_ID_i format on Mar 05, 2025 by Albino Carbognani
%==========================================================================

disp('  Compile MPC-80-column astrometry report')
disp('  ')

% Write header metadata
fid = fopen(strcat(outputs_folder,'/MPC_80_col_Report_', string(norad_ID),'.txt'),'wt+');

% Delete the progressive number fron norad_ID
parts = split(norad_ID, '_'); % Split at '_'
norad_ID = str2double(parts{1}); % Convert to numeric

fprintf(fid, 'COD 598 \n');
fprintf(fid, 'CON Name Surname \n');
fprintf(fid, 'OBS Name Surname \n');
fprintf(fid, 'MEA Name Surname \n');
fprintf(fid, 'TEL Reflector 0.35m + CCD \n');
fprintf(fid, 'ACK MPCReport file updated %s \n', datetime('now'));
fprintf(fid, 'AC2 e-mail address \n');
fprintf(fid, 'NET GaiaDR2 \n');
fprintf(fid, 'COM coord epoch 2000, astrometric observations to analize with find_orb \n');

for j = 1:height(all_streaks_info)

    % Time tag string
    date_time_string = strcat('CK',char(datetime(tm_array(j),'Format','yyMMdd:HHmmssSSS')));
    
    % Compile RA measurement (N.B. the notation '_dec' stands for 'decimal digits', not declination)
    ra = all_streaks_info{j,'Centroid RA (deg)'};
    ra_int = fix(ra);
    ra_dec = fix(1.e4*(ra-ra_int));
    ra_string = strcat(num2str(ra_int,'%03.f'),'.',num2str(ra_dec,'%04.f'));

    % Compile Dec measurement
    dec = all_streaks_info{j,'Centroid Dec (deg)'};
    if dec >= 0
        sign = '+';
    else
        sign = '-';
    end
    dec = abs(dec);
    dec_int = fix(dec);
    dec_dec = fix(1.e5*(dec-dec_int));
    dec_string = strcat(num2str(dec_int,'%02.f'),'.',num2str(dec_dec,'%05.f'));

    % Estimate instrumental mag
    I_mag = 12.3 - 2.5*log10(all_streaks_info{j,'Best fit flux (ADU)'}/(seconds(exp_time)));
    mag_string = num2str(I_mag,'%02.1f');

    % Compiling satellite name according to the 7-digits MPC format
    sat_name = num2str(str2double(string(norad_ID)),'%07.f');

    % Compiling j-th line in the data section of the MPC-80-column report
    fprintf(fid, '     %s  %s%s    %s%s            %s%s      %s\n', sat_name, date_time_string, ra_string, sign, dec_string, mag_string, ' G', '598');
end

fclose(fid);

end