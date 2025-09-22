%==========================================================================
% Manipulate some arrays about streak properties to simplify later processing
%
% INPUTS:
%   cc_props: struct array of the streak properties
%
% OUTPUTS:
%   slope_array: array of the adjusted streak slopes (deg), so that they
%   range in [0,180] deg
%   centroid_xy_array: reshaped array of the streak centroid's pixel
%   coordinates, so that the x coords are in column 1 and the y coord are
%   in column 2
%   bbox_array: reshaped array of the bounding box properties (bottom-left corner
%   and size) of each streak
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-02-10
%==========================================================================

function [slope_array, centroid_xy_array, bbox_array] = edit_props_arrays(cc_props, gray_image)

% Shift the slopes so that they range in the [0,180] deg interval
slope_array = [cc_props.Orientation]';
%slope_array(slope_array>0) = 180 - slope_array(slope_array>0);
%slope_array(slope_array<0) = abs(slope_array(slope_array<0));
slope_array(slope_array<0) = slope_array(slope_array<0) + 180;

% Reshape the centroid_xy_array as a Nx2 array
centroid_xy_array = reshape([cc_props.Centroid],2,[])';

% Reshape bounding box array as a Nx4 array
bbox_array = reshape([cc_props.BoundingBox],4,[])';
bbox_array = round(bbox_array);

% Enlarge the bounding box
enlarge_pixels = 30;
bbox_array(:,1:2) = bbox_array(:,1:2) - enlarge_pixels;
bbox_array(:,3:4) = bbox_array(:,3:4) + 2*enlarge_pixels;

% Ensure the bounding box does not exceed image boundaries
bbox_array(:,1) = max(bbox_array(:,1), 1);
bbox_array(:,2) = max(bbox_array(:,2), 1);
bbox_array(:,3) = min(bbox_array(:,3), size(gray_image, 2) - bbox_array(:,1));
bbox_array(:,4) = min(bbox_array(:,4), size(gray_image, 1) - bbox_array(:,2));

end