%==========================================================================
% Detect all the connected components in the binary image and filter out 
% those ones that do not fulfill the desired geometrical features imposed 
% by the threshold parameters, that is, that are not streaks
%
% INPUTS:
%   binary_image: binary segmentation of the current fits file
%
% OUTPUTS:
%   valid_idx: logical array of indices of the detected connected
%   components in the binary image identified as streaks
%   cc_props: struct array of the properties of the filtered connected components
%   aspect_ratio_array: array of the aspect ratio of the the filtered connected components
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-01-27
%==========================================================================

function [valid_idx, cc_props, aspect_ratio_array] = streak_detection(binary_image)

% Threshold parameters to filter out the undesired connected components
% detected in the images
min_area = 300; % minimum area (pixels)
min_aspect_ratio = 4; % minimum aspect ratio (major axis / minor axis)

%==========================================================================

% Detect connected components
cc = bwconncomp(binary_image);

% Retrieve properties of the detected connected components
cc_props = regionprops(cc, 'Centroid', 'Area', 'Orientation', 'PixelList', 'MinorAxisLength', 'MajorAxisLength', 'BoundingBox');
aspect_ratio_array = ([cc_props.MajorAxisLength]./[cc_props.MinorAxisLength])';

% Filter the connected components on the basis of minimum area and
% minimum aspect ratio. What should remain are the streaks.
valid_idx = ([cc_props.Area]' >= min_area) & (aspect_ratio_array >= min_aspect_ratio);
cc_props = cc_props(valid_idx);
aspect_ratio_array = aspect_ratio_array(valid_idx);

end