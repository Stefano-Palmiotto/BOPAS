function [orbitType]=classifySatelliteFromTLE(tleFilename)
    % Reads a TLE file, extracts the semi-major axis, and classifies the orbit.
    %
    % Input:
    %   tleFilename : String with the filename containing the TLE.
    % Output:
    % orbitType: LEO, MEO or GEO (string)
        
    % Earth's radius in km
    Re = 6378.137; % Equatorial radius of Earth (km)
    
    % Read TLE file
    fid = fopen(tleFilename, 'r');
    if fid == -1
        error('Cannot open TLE file.');
    end
    nameLine = fgetl(fid);  % Line 0 (Satellite name, optional)
    line1 = fgetl(fid);     % Line 1 of TLE
    line2 = fgetl(fid);     % Line 2 of TLE
    fclose(fid);

    % Extract mean motion (n) from TLE (Line 2, columns 53-63)
    meanMotion = str2double(line2(53:63)); % Revolutions per day

    % Convert mean motion to semi-major axis (km)
    mu = 398600.4418; % Earth's gravitational parameter (km^3/s^2)
    n_rad = meanMotion * 2 * pi / 86400; % Convert rev/day to rad/s
    a = (mu / n_rad^2)^(1/3); % Semi-major axis (km)

    % Compute perigee altitude
    altitude = a - Re; % Altitude above Earth's surface (km)

    % Classify orbit
    if altitude < 2000
        orbitType = 'LEO';
        % Time increment to compute ephemeris
    elseif altitude < 35786
        orbitType = 'MEO';
        % Time increment to compute ephemeris    
    else
        orbitType = 'GEO';
        % Time increment to compute ephemeris        
    end

    % Display results
    fprintf('Satellite Semi-Major Axis: %.2f km\n', a);
    fprintf('Altitude above Earth: %.2f km\n', altitude);
    fprintf('Orbit Classification: %s\n', orbitType);
end
