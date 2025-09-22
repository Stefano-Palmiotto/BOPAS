%==========================================================================
% Best least square fit of a streak with an axisymmetric Gaussian trail 
% (Veres et al, PASP, 2012)
%
% INPUTS:
%   B(1): guess background image (ADU) 
%   B(2): guess flux trail (ADU)
%   B(3): guess length trail (pixel)
%   B(4): guess sigma of the trail (pixel)
%   B(5): guess x center of the trail (pixel)
%   B(6): guess y center of the trail (pixel)
%   B(7): guess inclination trail (deg)
%   gray_image: gray scale version of the current fits file
%   bbox_array: array of the streak's bounding box properties
%
% OUTPUTS:
%   B_fit: same as B but with least square fit of the parameters
%   B_sigma: array of 1-sigma values of the estimated B parameters
%   Z_fit: best fit height profile (ADU) of the trail (pixel)
%
% Authors:
% Albino Carbognani, INAF-OAS 
% Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version:  2025-02-10
%==========================================================================

function [B_fit, B_sigma, Z_fit] = axisymmetric_Gaussian_best_fit_trail(B, gray_image, bbox_array)

% Crop the box in the image where the streak is located
Z = gray_image( bbox_array(2):bbox_array(2)+bbox_array(4), bbox_array(1):bbox_array(1)+bbox_array(3) );
[X,Y] = meshgrid( bbox_array(1):bbox_array(1)+bbox_array(3), bbox_array(2):bbox_array(2)+bbox_array(4) );
     
% Extract X and Y arrays from meshgrid
XY = [X(:),Y(:)];

% Function of the axisymmetric Gaussian trail (Veres et al, PASP, 2012)
surfit = @(B, XY)  B(1)+((B(2)/(2*B(3)*B(4)*sqrt(2*pi))))...
    .*(exp(-(((XY(:,1)-B(5))*sind(B(7))+(XY(:,2)-B(6))*cosd(B(7))).^2)/(2*B(4)*B(4))))...
    .*(erf(((XY(:,1)-B(5))*cosd(B(7))-(XY(:,2)-B(6))*sind(B(7))+B(3)/2)/(sqrt(2)*B(4)))...
    -erf(((XY(:,1)-B(5))*cosd(B(7))-(XY(:,2)-B(6))*sind(B(7))-B(3)/2)/(sqrt(2)*B(4))));

% The Levenberg-Marquardt algorithm does not handle bound constraints
lb = [];
ub = [];
B0 = [B(1), B(2), B(3), B(4), B(5), B(6), B(7)]; % initial guess for coefficient values

%Reshape the grid of Z values into a 1-d array
Z_reshaped = Z(:);

% Non linear least squares fit with Levenberg-Marquardt algorithm
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt','Display','off');
[B_fit, ~, residuals, ~, ~, ~, jacobian] = lsqcurvefit(surfit, B0, XY, Z_reshaped, lb, ub, options);
Z_fit = surfit(B_fit, XY);

% Uncertainty analysis: function nlparci(beta,r,"Jacobian",J) returns the 
% 95% confidence intervals ci for the nonlinear least-squares parameter estimates beta
ci = nlparci(B_fit, residuals,'jacobian',jacobian);
% Standard deviation of the B_fit parameters
B_sigma = (ci(:,2) - ci(:,1))/1.96;

% Aggiungere test chi-quadro di Veres?

end