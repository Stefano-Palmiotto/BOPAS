%==========================================================================
% Plot topocentric RA and Dec measurements vs. MJD and observation number
%
% INPUTS:
%   mjd_array: array of streak centroids' time tags as MJD
%   all_streaks_info: filtered table of information about all the detected
%   streaks
%   norad_ID: NORAD number of the current satellite
%   outputs_folder: folder of astrometry outputs
%   year, month, day: strings of year, month and day numbers
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of bologna
%
% Version: 2025-01-27
%==========================================================================

function RADec_vs_MJD_N(mjd_array, all_streaks_info, norad_ID, outputs_folder, year, month, day)

disp('  Plot RA and DEC vs MJD/observation number')

figure('WindowState', 'maximized');
subplot(2,1,1)
plot(mjd_array,all_streaks_info{:,'Centroid RA (deg)'},'--o','Color',"#0072BD",'MarkerEdgeColor',"#0072BD",'MarkerFaceColor',"#0072BD")
xlabel('MJD'); ylabel('Topocentric RA')
grid on
subplot(2,1,2)
plot(mjd_array,all_streaks_info{:,'Centroid Dec (deg)'},'--o','Color',"#D95319",'MarkerEdgeColor',"#D95319",'MarkerFaceColor',"#D95319")
xlabel('MJD'); ylabel('Topocentric Dec')
grid on

sgtitle(strcat("Date: ",year,'-',month,'-',day,"; Norad: ", string(norad_ID)))

disp('  Save plot 1 as JPEG')
saveas(gcf, strcat(outputs_folder,'/RA_Dec_vs_MJD'), 'jpeg')

figure('WindowState', 'maximized');
subplot(2,1,1)
plot(all_streaks_info{:,'Centroid RA (deg)'},'--o','Color',"#D95319",'MarkerEdgeColor',"#D95319",'MarkerFaceColor',"#D95319")
ylabel('Topocentric RA'); xlabel('Observation number')
grid on
subplot(2,1,2)
plot(all_streaks_info{:,'Centroid Dec (deg)'},'--o','Color',"#D95319",'MarkerEdgeColor',"#D95319",'MarkerFaceColor',"#D95319")
xlabel('Observation number'); ylabel('Topocentric Dec')
grid on

sgtitle(strcat("Date: ",year,'-',month,'-',day,"; Norad: ", string(norad_ID)))

disp('  Save plot 2 as JPEG')
saveas(gcf, strcat(outputs_folder,'/RA_Dec_vs_number'), 'jpeg')
disp('  ')

end