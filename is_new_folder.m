%==========================================================================
% Check if the folder specified by the input variable 'folder_path' exists.
% If not, the function creates that folder.
%
% INPUTS:
%   folder_path: absolute path of the folder
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-01-27
%==========================================================================

function is_new_folder(folder_path)

if ~isfolder(folder_path)
    mkdir(folder_path)
end

end