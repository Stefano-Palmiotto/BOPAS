%==========================================================================
% Compute the plate solution residuals for all the images of the current satellite 
% by means of the local installation of Astrometry.net, save their 1-sigma values
% in the row of the table 'plate_sol_res_sigmas' related to the current fits
% file and plot them
%
% INPUTS:
%   RA_cat, Dec_cat, RA_cmp, Dec_cmp: celestial coordinates of catalog and
%   computed stars from plate solution (deg)
%   outputs_folder: astrometry outpus folder of the current satellite
%   fits: name of the current fits file
%   plate_sol_res_sigmas: table of the residual 1-sigma values
%
% OUTPUTS:
%   RA_res, Dec_res: array of RA and Dec residuals from the plate solution
%   of the current fits file
%   plate_sol_res_sigmas: updated table of the residual 1-sigma values
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-01-27
%==========================================================================

function [RA_res, Dec_res, plate_sol_res_sigmas] = plate_sol_res(RA_cat, Dec_cat, RA_cmp, Dec_cmp, outputs_folder, fits, plate_sol_res_sigmas)

% Compute RA and Dec residuals (catalog - computed)
RA_res = (RA_cat - RA_cmp)*3600; % Convert from degrees to arcseconds
Dec_res = (Dec_cat - Dec_cmp)*3600;

% Compile table of residuals 1-sigma values
plate_sol_res_sigmas{end+1,'FITS file name'} = fits;
plate_sol_res_sigmas{end,'RA residuals 1-sigma (arcsec)'} = std(RA_res);
plate_sol_res_sigmas{end,'Dec residuals 1-sigma (arcsec)'} = std(Dec_res);
plate_sol_res_sigmas{end,'Number of stars'} = length(RA_res);
fprintf('   1-sigma of RA residuals from plate solution by Astrometry.net (arcsec): %f\n', std(RA_res))
fprintf('   1-sigma of Dec residual from plate solution by Astrometry.net (arcsec): %f\n', std(Dec_res))
fprintf('   Number of stars used by Astrometry: %d\n', length(RA_res));
disp('  ')

% Plot the residuals
res_fig = figure;
%fontsize(12, "points")
subplot(2,2,1);
scatter(1:length(RA_res), RA_res, 'filled');
hold on
plot(1:length(RA_res), mean(RA_res)*ones(size(RA_res)), 'LineStyle','--','Color','red','LineWidth',1.5);
grid on;
xlabel('Star number');
ylabel('RA residuals (arcsec)');

subplot(2, 2, 2);
histogram(RA_res, 'Normalization', 'pdf', 'Orientation', 'horizontal');
grid on;
xlabel('PDF');

subplot(2,2,3);
scatter(1:length(Dec_res), Dec_res, 'filled');
hold on
plot(1:length(Dec_res), mean(Dec_res)*ones(size(Dec_res)), 'LineStyle','--','Color','red','LineWidth',1.5);
grid on;
xlabel('Star number');
ylabel('Dec residuals (arcsec)');

subplot(2, 2, 4);
histogram(Dec_res, 'Normalization', 'pdf', 'Orientation', 'horizontal');
grid on;
xlabel('PDF');

print(res_fig, strcat(outputs_folder,'/',erase(fits,".fits"),'/plate_solution/ra_dec_residuals'), '-djpeg');
close(res_fig);

end