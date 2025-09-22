%==========================================================================
% Display global figure with detected streaks, closeup views of the streaks
% and best fit with axisymmetric gaussian trail
%
% INPUTS:
%   gray image: gray scale version of the fits file
%   crop_frame_dim: image border to cut (pixel)
%   binary_image: binary segmentation of the fits file
%   cc_props: struct array of streak properties
%   valid_idx: indices of the connected components in the binary image identified as streaks
%   sda_folder: path of the 'streak_detection_astrometry' folder of the
%   current fits file
%   bbox_array: array of streak bounding box props
%   Z_fit_array: cell array of Z_fit arrays from gaussian best fit
%   centroid_pixel_array: array of pixel coords of Gaussian best fit trail centroids
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-02-16
%==========================================================================


function show_streaks(gray_image, crop_frame_dim, binary_image, cc_props, valid_idx, sda_folder, bbox_array, Z_fit_array, centroid_pixel_array)

% Show the current global image
global_fig = figure;
%fontsize(12, "points")
adjusted_image = imadjust(gray_image);
% imagesc(1+crop_frame_dim:4096-crop_frame_dim, 1+crop_frame_dim:4096-crop_frame_dim, adjusted_image);
imagesc(adjusted_image);
colormap gray; axis image; xlabel('pixel x-coordinate'); ylabel('pixel y-coordinate');

% Set up colors of the streak boundaries
boundaries = bwboundaries(binary_image);
colors = lines(length(cc_props));
boundaries = boundaries(valid_idx,1);

hold on

if isempty(cc_props)
    % Save empty image in JPEG format
    set(gca,'YDir','normal');
    print(global_fig, strcat(sda_folder,'/all'), '-djpeg');
else
    for j = 1:length(cc_props)
        boundary = boundaries{j};
        color = colors(j,:);
        plot(boundary(:,2), boundary(:,1), 'Color', color, 'LineWidth', 1);

        % Enumerate connected components
        text(centroid_pixel_array(j,1), centroid_pixel_array(j,2), num2str(j), 'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');

        % Save global image with all the detected streaks in JPEG
        % format
        set(gca,'YDir','normal');
        print(global_fig, strcat(sda_folder,'/all'), '-djpeg');
    end
    hold off

    % Save closeup of each streak
    for j = 1:length(cc_props)
        boundary = boundaries{j};
        color = colors(j,:);

        close_up = imcrop(adjusted_image, bbox_array(j,:));

        % Create new figure object for the j-th streak
        close_up_fig = figure;
        ax1 = axes;
        %fontsize(12, "points")
        imagesc(ax1, bbox_array(j,1)+crop_frame_dim:bbox_array(j,1)+bbox_array(j,3)+crop_frame_dim, bbox_array(j,2)+crop_frame_dim:bbox_array(j,2)+bbox_array(j,4)+crop_frame_dim, close_up);
        colormap(ax1,"gray"); axis image; xlabel('pixel x-coordinate'); ylabel('pixel y-coordinate');

        % Paint the streak's boundary
        hold on
        plot(ax1, boundary(:,2), boundary(:,1), 'Color', color, 'LineWidth', 1);
        
        ax2 = axes;
        [X,Y] = meshgrid( bbox_array(j,1):bbox_array(j,1)+bbox_array(j,3), bbox_array(j,2):bbox_array(j,2)+bbox_array(j,4) );
        Z_fit = reshape(Z_fit_array{j}, size(X));

        contour(ax2, X, Y, Z_fit)
        colormap(ax2, "hot"); axis image;
        hold on
        scatter(ax2, centroid_pixel_array(j,1), centroid_pixel_array(j,2),'red',"filled")

        set(ax2, 'Position', get(ax1, 'Position'), 'Color', 'none', 'XColor', 'none', 'YColor', 'none');

        legend(ax2,'','Gaussian best fit''s centroid')

        hold off

        % Save the cropped image in JPEG format
        set([ax1, ax2], 'YDir', 'Normal');
        print(close_up_fig, strcat(sda_folder,'/streak_', num2str(j)), '-djpeg');
        close(close_up_fig);  % Close the closeup image after saving it

    end
end

close(global_fig) % Close global figure

end