#=================================================================================
# 'pixel_to_WCS.py' extracts the WCS keys from the current WCS-calibrated FITS image, 
# then loads the pixel coordinates of the gaussian best fit trail's centroid and 
# converts them into topocentric (RA, Dec) coordinates
#
# INPUTS: 
#   absolute path of the current WCS-calibrated .fits file
#
# OUTPUTS: 
#   topocentric (RA, Dec) coordinates in degrees of the gaussian best fit trail's centroid
#
# Author: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
# 
# Version: 2025-01-27
#=================================================================================

import argparse
from astropy.io import fits
from astropy.wcs import WCS
import scipy.io
import numpy as np

def pixel2RADec(fits_path):

    # Read .fits file header and extract WCS keys
    fits_header = fits.getheader(fits_path)
    w = WCS(fits_header)
    
    # Load from matlab workspace the array storing (x,y) pixel coordinates 
    # of the gaussian best fit trail's centroid
    matrix = scipy.io.loadmat("./tmp_mat_files/CentroidPixelCoord.mat")
    centroid_pixel_coord = matrix["centroid_pixel_coord"]
    
    # Convert from pixel to (RA, Dec) coordinates
    ra, dec = w.all_pix2world(centroid_pixel_coord[0,0], centroid_pixel_coord[0,1], 1)

    # Export (RA,DEC) coordinates to Matlab Workspace
    np_array = np.array([ra,dec])
    scipy.io.savemat('./tmp_mat_files/CentroidRADecCoord.mat', {'centroid_ra_dec_coord': np_array})

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description="Compute (RA, Dec) coordinates from pixel coordinates")
    parser.add_argument("fits_path", type=str, help="absolute path of the current WCS-calibrated fits file")
 
    args = parser.parse_args()
 
pixel2RADec(args.fits_path)