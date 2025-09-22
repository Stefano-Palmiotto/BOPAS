%==========================================================================
% Compute the plate solution for all the images of the current satellite 
% by means of the local installation of Astrometry.net
%
% INPUTS:
%   corr_file: binary .corr file provided by the plate solution of the
%   current fits file
%
% OUTPUTS:
%   x_cat, y_cat, RA_cat, Dec_cat: pixel and celestial coordinates of the
%   catalog stars used to compute the plate solution (pixel, deg)
%   x_cmp, y_cmp, RA_cmp, Dec_cmp: pixel and celestial coordinates of the previous stars
%   using the plate solution computed by Astrometry (pixel, deg)
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-01-27
%==========================================================================

function [x_cat,y_cat,RA_cat,Dec_cat,x_cmp,y_cmp,RA_cmp,Dec_cmp] = read_corr_file(corr_file)

corr_content = fitsread(corr_file, 'binarytable');

x_cat = corr_content{5};
y_cat = corr_content{6};
RA_cat = corr_content{7};
Dec_cat = corr_content{8};

x_cmp = corr_content{1};
y_cmp = corr_content{2};
RA_cmp = corr_content{3};
Dec_cmp = corr_content{4};

end