%==========================================================================
% Perform binary segmentation of the current fits file
%
% INPUTS:
%   satellite_folder: path of the current satellite folder
%   fits: name of the current fits file
%
% OUTPUTS:
%   binary_image: binary segmentation of the fits file
%   crop_frame_dim: image border to cut (pixel)
%   gray_image: gray scale version of the fits file
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-02-17
%==========================================================================

function [binary_image, crop_frame_dim, gray_image] = binary_segmentation(satellite_folder,fits)

%==========================================================================

crop_frame_dim = 0; % image border to cut (pixel)

%==========================================================================

% Read current .fits file
raw_image = abs(fitsread(strcat(satellite_folder,'/WCS_fits/',fits)));

% Cut frame of external pixels to avoid detection of the black strip 
% at the border of the TANDEM .fits when the background is pretty
% bright (for instance, in case of full Moon)
% raw_image = raw_image(crop_frame_dim+1:end-crop_frame_dim,crop_frame_dim+1:end-crop_frame_dim);

% Generate gray scale image
gray_image = mat2gray(raw_image);

% figure
% imagesc(imadjust(gray_image));
% set(gca, 'YDir', 'Normal')
% colormap gray; axis image; xlabel('pixel x-coordinate'); ylabel('pixel y-coordinate');
% print(gcf, strcat('./raw'), '-djpeg', '-r300');

% Image binary segmentation with adaptive thresholding
% filtered_image = imbilatfilt(gray_image); % Edge-preserving bilateral filtering to speed up the adaptive thresholding
filtered_image = imgaussfilt(gray_image,1); % Edge-preserving bilateral filtering to speed up the adaptive thresholding

% figure
% imagesc(imadjust(filtered_image));
% set(gca, 'YDir', 'Normal')
% colormap gray; axis image; xlabel('pixel x-coordinate'); ylabel('pixel y-coordinate');
% print(gcf, strcat('./filt'), '-djpeg', '-r300');

binary_image = imbinarize(filtered_image,'adaptive');

% Remove connected objects on border and fill holes in the
% connected components due to CMOS sensor saturation
binary_image = imclearborder(binary_image);
binary_image = imfill(binary_image,'holes');

% figure
% imagesc(binary_image);
% set(gca, 'YDir', 'Normal')
% colormap gray; axis image; xlabel('pixel x-coordinate'); ylabel('pixel y-coordinate');
% print(gcf, strcat('./binary'), '-djpeg', '-r300');


end