%==========================================================================
% Compute the plate solution for all the images of the current satellite 
% by means of the local installation of Astrometry.net
%
% INPUTS:
%   satellite_folder: absolute path of the current satellite folder
%   fits: name of the current fits file
%   astrometry_exe: absolute path of the local Astrometry.Net executable
%
% Authors: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%          Albino Carbognani, INAF-OAS
%
% Version: 2025-01-27
%==========================================================================

function plate_solution(satellite_folder, fits, astrometry_exe)

%==========================================================================

% Setup parameters of the Astrometry executable
poly_deg = 3; % degree of the WCS polynomial
L = 1.76;
H = 1.79;

%==========================================================================

astrometry = strcat(astrometry_exe,' --login -c "/usr/bin/solve-field -p -O -C cancel --crpix-center -z 2 -u arcsecperpix -L'," ",num2str(L)," ",'-H'," ",num2str(H)," ",'-t'," ",num2str(poly_deg));
input_raw_file = strcat(satellite_folder, '/raw_fits/', fits);
output_wcs_file = strcat(satellite_folder, '/WCS_fits/', fits);
command_line = strcat(astrometry, " ", input_raw_file, " -N ", output_wcs_file);
system(command_line);

end