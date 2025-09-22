BOPAS README
---------------------

BOPAS (Bologna Observatory Pipeline for Astrometry of Satellites) depends on:

1. any release of MATLABⓇ since 2019b along with the Image Processing Toolbox
2. Astrometry.net
3. Python 3 with Astropy package 

---------------------

BOPAS performs 3 main tasks:

1. sort raw FITS files of the observation campaigns into the right folders of the form 'yyyy-MM-dd/NORAD ID/raw_fits',
   where NORAD ID is the 5-digits NORAD catalog number of the satellite
2. automated plate solution of raw FITS files by Astrometry.net
3. streak detection and astrometry

You can switch on or off each of these options from 'settings.txt'

---------------------

Ephemeris are used to detect the sought GEO satellite in case there are GEO satellites
close to each other in all the frames. Ephemeris are computed using the target's TLE
at the observing date, which must be saved in a folder named 'yyyy-mm-dd', where yyyy
is the year, mm is the month and dd is the day of the observing campaign.
This folder must be saved then in a parent folder whose absolute path is to be specified in the settings.

---------------------

Before running 'BOPAS.m', make sure to fulfill the following instructions:

- if it doesn't exist, create a folder where to save the raw FITS files
- if it doesn't exist, create a folder where to save the outputs of the BOPAS run
- specify your settings in 'settings.txt'
- set the parameters at the beginning of the following functions:
    1. binary_segmentation.m
    2. filter_table_rows.m  
    3. plate_solution.m
    4. rolling_shutter_correction.m
    5. streak_detection.m
    6. write_ADES.m

---------------------

The hierarchy of the BOPAS outputs folder, from top to bottom, is as follows:

1. folders 'yyyy-MM-dd', where yyyy is the year number, MM the 2-digits month number and dd the 2-digits day of the month number
2. folders 'xxxxx' where 'xxxxx' is the NORAD catalog number of the satellite
3. folders 'raw-fits', 'WCS_fits'and 'astrometry_outputs', along with the file 'DISCOS_data.txt' containing mass and average cross section retrieved
   from the ESA DISCOS API
4. inside 'astrometry_outputs', there is a folder for each fits file processed with the same name as the respective fits file,
   the text file 'plate_sol_res_sigmas.txt' containing a table of 1-sigma values of the plate solution residuals for each image along with the number of stars
   used by Astrometry.Net to compute the plate solution, and the final products of the astrometry, that is, the astrometry reports in the MPC-80-columns, ADES
   and CCSDS TDM format and the plots of topocentric RA and Dec vs. MJD and number of observations as well as the plot of OD reisiduals
5. each folder named as the respective fits file contains the folders 'plate_solution' and 'streak_detection_astrometry',
   containing, for that fits file, the plate solution plots and the streak detection and astrometry plots along with the streak data in 'streaks_info.txt'

---------------------

Authors: Stefano Palmiotto, Alma Mater Studiorum - University of Bologna
		 e-mail: stefano.palmiotto@unibo.it
		 
		 Albino Carbognani, INAF-OAS
		 e-mail: albino.carbognani@inaf.it