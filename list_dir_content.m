%==========================================================================
% List all the contents present in the input folder.
%
% INPUTS:
%   directory: absolute path of the input directory
%
% OUTPUTS:
%   list = string array of the names of the contents of the input
%   directory
%
% Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
%
% Version: 2025-01-27
%==========================================================================

function list = list_dir_content(directory)

list = strtrim( string( ls(directory) ) );
list(strcmp(list, ".")) = [];
list(strcmp(list, "..")) = [];

end