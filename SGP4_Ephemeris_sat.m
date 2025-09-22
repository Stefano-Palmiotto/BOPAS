% Compute ephemeris J2000 of a satellite from a TLE using SGP4 propagation model
%
% SGP4 scripts from:
% Meysam Mahooti (2021). SGP4 (https://www.mathworks.com/matlabcentral/fileexchange/62013-sgp4), 
% MATLAB Central File Exchange. Retrieved November 11, 2021.
%
% INPUT
% temp_tle = path e file che contiene il TLE del satellite
% Lat = latitudine osservatore (gradi)
% Long = longitudine osservatore (gradi)
% h = quota osservatore (metri)
% MJD_Ephemeris = giorno giuliano modificato per cui si vuole l'effemeride
%
% OUTPUT
% AR = AR topocentrico J2000 del satellite (gradi)
% DEC = Declinazione topocentrica J2000 del satellite (gradi)
%
% Albino Carbognani, OAS
% Version Mar 07, 2025

function [AR, DEC]=SGP4_Ephemeris_sat(temp_tle, Lat, Long, h, MJD_Ephemeris)

format long g

% Observer's input
C=180/pi;                                                  % Conversione gradi-radianti
Lat_O = Lat/C;                                             % Latitudine geografica (o geodetica) osservatore (radianti)
Long_O = Long/C;                                           % Longitudine geografica (o geodetica) osservatore (radianti)
h_O = h;                                                   % Quota osservatore (m)
Lat_geo = (geod2geoc(C*Lat_O, h_O, 'WGS84'))/C;            % Latitudine geocentrica della stazione (radianti)
R_O = geocradius(C*Lat_geo, 'WGS84');                      % Raggio geocentrico della stazione (m)

global const
SAT_Const

ge = 398600.8; % Earth gravitational constant
TWOPI = 2*pi;
MINUTES_PER_DAY = 1440;
MINUTES_PER_DAY_SQUARED = (MINUTES_PER_DAY * MINUTES_PER_DAY);
MINUTES_PER_DAY_CUBED = (MINUTES_PER_DAY * MINUTES_PER_DAY_SQUARED);

% TLE file name
fname=temp_tle;

% Open the TLE file and read TLE elements
fid = fopen(fname, 'r');

% 19-32	04236.56031392	Element Set Epoch (UTC)
% 3-7	25544	Satellite Catalog Number
% 9-16	51.6335	Orbit Inclination (degrees)
% 18-25	344.7760	Right Ascension of Ascending Node (degrees)
% 27-33	0007976	Eccentricity (decimal point assumed)
% 35-42	126.2523	Argument of Perigee (degrees)
% 44-51	325.9359	Mean Anomaly (degrees)
% 53-63	15.70406856	Mean Motion (revolutions/day)
% 64-68	32890	Revolution Number at Epoch

% read first line
tline = fgetl(fid);
tline = fgetl(fid);
Cnum = tline(3:7);      			        % Catalog Number (NORAD)
SC   = tline(8);					        % Security Classification
ID   = tline(10:17);			            % Identification Number
year = str2num(tline(19:20));               % Year
doy  = str2num(tline(21:32));               % Day of year
epoch = str2num(tline(19:32));              % Epoch
TD1   = str2num(tline(34:43));              % first time derivative
TD2   = str2num(tline(45:50));              % 2nd Time Derivative
ExTD2 = tline(51:52);                       % Exponent of 2nd Time Derivative
BStar = str2num(tline(54:59));              % Bstar/drag Term
ExBStar = str2num(tline(60:61));            % Exponent of Bstar/drag Term
BStar = BStar*1e-5*10^ExBStar;
Etype = tline(63);                          % Ephemeris Type
Enum  = str2num(tline(65:end));             % Element Number

% read second line
tline = fgetl(fid);
i = str2num(tline(9:16));                   % Orbit Inclination (degrees)
raan = str2num(tline(18:25));               % Right Ascension of Ascending Node (degrees)
e = str2num(strcat('0.',tline(27:33)));     % Eccentricity
omega = str2num(tline(35:42));              % Argument of Perigee (degrees)
M = str2num(tline(44:51));                  % Mean Anomaly (degrees)
no = str2num(tline(53:63));                 % Mean Motion
a = ( ge/(no*2*pi/86400)^2 )^(1/3);         % semi major axis (m)
rNo = str2num(tline(65:end));               % Revolution Number at Epoch

fclose(fid);

satdata.epoch = epoch;
satdata.norad_number = Cnum;
satdata.bulletin_number = ID;
satdata.classification = SC; % almost always 'U'
satdata.revolution_number = rNo;
satdata.ephemeris_type = Etype;
satdata.xmo = M * (pi/180);
satdata.xnodeo = raan * (pi/180);
satdata.omegao = omega * (pi/180);
satdata.xincl = i * (pi/180);
satdata.eo = e;
satdata.xno = no * TWOPI / MINUTES_PER_DAY;
satdata.xndt2o = TD1 * 1e-8 * TWOPI / MINUTES_PER_DAY_SQUARED;
satdata.xndd6o = TD2 * TWOPI / MINUTES_PER_DAY_CUBED;
satdata.bstar = BStar;

% Compute TLE epoch in MJD
if (year < 57)
    year = year + 2000;
else
    year = year + 1900;
end

[mon,day,hr,minute,sec] = days2mdh(year,doy);
MJD_Epoch = Mjday(year,mon,day,hr,minute,sec);

% Compute amount of time in which you are going to propagate satellite's state vector forward (+) or backward (-) [minutes] 
tsince = (MJD_Ephemeris-MJD_Epoch)*1440; 

[rteme, vteme] = sgp4(tsince, satdata); % True equator mean equinox (TEME) coordinate system

% read Earth orientation parameters
fid = fopen('eop19620101.txt','r');
%  ----------------------------------------------------------------------------------------------------
% |  Date    MJD      x         y       UT1-UTC      LOD       dPsi    dEpsilon     dX        dY    DAT
% |(0h UTC)           "         "          s          s          "        "          "         "     s 
%  ----------------------------------------------------------------------------------------------------
eopdata = fscanf(fid,'%i %d %d %i %f %f %f %f %f %f %f %f %i',[13 inf]);
fclose(fid);

% Compute MJD and JD of observing time
MJD_UTC = MJD_Epoch+tsince/1440;
JD_UTC = MJD_UTC+2400000.5;

% Earth Orientation Parameters
[x_pole,y_pole,UT1_UTC,LOD,dpsi,deps,dx_pole,dy_pole,TAI_UTC] = IERS(eopdata,MJD_UTC,'l');
[UT1_TAI,UTC_GPS,UT1_GPS,TT_UTC,GPS_UTC] = timediff(UT1_UTC,TAI_UTC);
MJD_UT1 = MJD_UTC + UT1_UTC/86400;
MJD_TT  = MJD_UTC + TT_UTC/86400;
T = (MJD_TT-const.MJD_J2000)/36525;

% Earth-centered inertial (ECI) coordinate system (origins at the center of mass of Earth and do not rotate with respect to the stars)
[reci, veci] = teme2eci(rteme,vteme,T,dpsi,deps);                                       

% Earth-centered Earth-fixed (ECEF) coordinate system (remain fixed with respect to Earth's surface in its rotation)
[recef,vecef] = teme2ecef(rteme,vteme,T,MJD_UT1+2400000.5,LOD,x_pole,y_pole,0);

% True of date (TOD) coordinate system
[rtod, vtod] = ecef2tod(recef,vecef,T,MJD_UT1+2400000.5,LOD,x_pole,y_pole,0,dpsi,deps); 

% Compute mean geocentric equatorial coordinates to date
rho=sqrt(rteme(1)^2+rteme(2)^2+rteme(3)^2);
delta_data_g=asin(rteme(3)/rho);
alfa_data_g=atan2(rteme(2),rteme(1));

% Riduzione di AR geocentrica in radianti fra 0 e 2 pi greco
alfa_data_g = zero2pi(alfa_data_g);

% Compute sideral time (radiants)
TS_O = Long_O + (JD2GMST(JD_UTC))/C;

% Coordinate rettangolari geocentriche dell'osservatore (km)
XO=((R_O+h_O)*cos(Lat_geo)*cos(TS_O))/1000;
YO=((R_O+h_O)*cos(Lat_geo)*sin(TS_O))/1000;
ZO=((R_O+h_O)*sin(Lat_geo))/1000;

% Coordinate rettangolari topocentriche del satellite
XS_top=rteme(1)-XO;
YS_top=rteme(2)-YO;
ZS_top=rteme(3)-ZO;

% Compute mean topocentric equatorial coordinates to date
rho_S_top=sqrt(XS_top^2+YS_top^2+ZS_top^2);
delta_data_t=asin(ZS_top/rho_S_top);
alfa_data_t=atan2(YS_top,XS_top);

% Riduzione di AR topocentrica in radianti fra 0 e 2 pi greco
alfa_data_t = zero2pi(alfa_data_t);

AR=C*alfa_data_t;
DEC=C*delta_data_t;

% Conversion from data to J2000 equinox
[AR, DEC] = EQ2EQ2000_B(AR, DEC, JD_UTC);

end