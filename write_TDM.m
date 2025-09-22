%==========================================================================
% Write Tracking Data Message (TDM) in the CCSDS format
%
% INPUTS:
%   outputs_folder: folder of astrometry outputs
%   norad_ID: NORAD number of the current satellite
%   all_streaks_info: filtered table of information about all the detected
%   streaks
%   tm_array: datetime array of streak centroids' time tags
%   exp_time: exposure time (seconds)
%   year, month, day: date of observation
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-03-05
%
% Update for norad_ID_i format on Mar 05, 2025 by Albino Carbognani
%==========================================================================

function write_TDM(outputs_folder, norad_ID, all_streaks_info, tm_array, year, month, day)

disp('  Compile TDM')
disp('  ')

% String array of epochs reported in the TDM
TDM_epochs = string(datetime(tm_array, 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS'));
TDM_date=string(datetime(tm_array(1), 'Format', 'uuuuMMdd'));

fid = fopen(strcat(outputs_folder,'/TDM_', string(norad_ID), '_',TDM_date,'_',year,month,day,'.txt'),'wt+');
numStr = regexp(norad_ID, '\d+', 'match'); % Extract numeric parts
norad_ID = str2double(numStr{1}); % Convert to numeric

fprintf(fid,'CCSDS_TDM_VERS = 1.0\n');
fprintf(fid,'   \n');
fprintf(fid,'CREATION_DATE = %s\n',string(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss.SSS')));
fprintf(fid,'ORIGINATOR = INAF-OAS \n');
fprintf(fid,'   \n');
fprintf(fid,'META_START   \n');
fprintf(fid,'TIME_SYSTEM = UTC \n');
fprintf(fid,'START_TIME = %s \n',TDM_epochs(1));
fprintf(fid,'STOP_TIME = %s \n',TDM_epochs(end));
fprintf(fid,'PARTICIPANT_1 = IT_CASSINI_TANDEM \n');
fprintf(fid,'PARTICIPANT_2 = %s \n', string(norad_ID));
fprintf(fid,'MODE = SEQUENTIAL \n');
fprintf(fid,'PATH = 2,1 \n');
fprintf(fid,'ANGLE_TYPE = RADEC \n');
fprintf(fid,'REFERENCE_FRAME = EME2000 \n');
fprintf(fid,'   \n');
fprintf(fid,'META_STOP \n');
fprintf(fid,'   \n');
fprintf(fid,'DATA_START \n');
fprintf(fid,'   \n');

for j = 1:height(all_streaks_info)
    
    ra = all_streaks_info{j,'Centroid RA (deg)'};

    dec = all_streaks_info{j,'Centroid Dec (deg)'};
    if dec >= 0
        sign = '+';
    else
        sign = '-';
    end
    dec = abs(dec);
    dec_int = fix(dec);
    dec_dec = fix(1.e4*(dec-dec_int));
    dec_string = strcat(num2str(dec_int,'%02.f'),'.',num2str(dec_dec,'%04.f'));

    fprintf(fid,'ANGLE_1 = %s %s \n', TDM_epochs(j), num2str(ra,'%.4f'));
    fprintf(fid,'ANGLE_2 = %s %s%s \n',TDM_epochs(j), sign, dec_string);
    fprintf(fid,'   \n');

end

fprintf(fid,'   \n');
fprintf(fid,'DATA_STOP \n');

fclose(fid);

end