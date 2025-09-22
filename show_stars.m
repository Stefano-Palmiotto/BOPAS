%==========================================================================
% Display and save in the 'plate_solution' folder of the current fits file
% the global image highlighting the catalog stars used by Astrometry
% to compute the plate solution (red) vs. the same stars whose position has been
% computed by Astrometry using the plate solution (yellow)
%
% INPUTS:
%   x_cat, y_cat, x_cmp, y_cmp: pixel coords of the catalog and computed stars
%   from the plate solution (pixel)
%   satellite_folder: path of the current satellite folder
%   fits: name of the current fits file
%   outputs_folder: path of the current satellite's outputs folder
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-01-27
%==========================================================================

function show_stars(satellite_folder, fits, outputs_folder, x_cat, y_cat, x_cmp, y_cmp)

% Read current .fits file
raw_image = abs(fitsread(strcat(satellite_folder,'/raw_fits/',fits)));
gray_image = mat2gray(raw_image);
adjusted_image = imadjust(gray_image);

% Print raw image with catalog and computed stars
stars_fig = figure;
%fontsize(12, "points")
imagesc(adjusted_image); colormap gray; axis image; xlabel('pixel x-coordinate'); ylabel('pixel y-coordinate');

hold on
for j = 1:length(x_cat)
    scatter(x_cat,y_cat,'red','*')
    scatter(x_cmp, y_cmp,'yellow','*')
    if x_cat(j) >= size (adjusted_image, 2)
        text(x_cat(j)-35, y_cat(j), num2str(j), 'Color','yellow', 'FontSize', 12, 'FontWeight', 'bold');
    else
        text(x_cat(j)+25, y_cat(j), num2str(j), 'Color','yellow', 'FontSize', 12, 'FontWeight', 'bold');        
    end
end

legend('Catalog stars', 'Computed stars')

set(gca,'YDir','normal');
print(stars_fig, strcat(outputs_folder,'/',erase(fits,".fits"),'/plate_solution/cat_vs_cmp_stars'), '-djpeg');

close(stars_fig)
end