% Funzione vettoriale per la trasformazione delle coordinate equatoriali 
% da equinozio alla data a J2000.0.
% Algoritmo: D. Boulet, Methods of orbit determination fro microcomputer,
% Willmann-Bell 1991, Cap.2, pag 37.
%
% Input: AR, DEC: vettore coordinate alla data in gradi
% JDin: giurno giuliano dell'epoca alla data
%
% Output: AR2000, DEC2000: coordinate equatoriali al J2000.0 in gradi
%
% Albino Carbognani, INAF-OAS
% Versione del 19 ottobre 2021

function [AR2000, DEC2000] = EQ2EQ2000_B(AR, DEC, JDin)

JDfin=2451545;    % Giorno giuliano per l'epoca di riferimento J2000.0 (1 gennaio 2000 ore 12 UT)

T=(JDin-JDfin)/36525;

M=1.28123227+0.000775867*(T/2)-0.000000077*(T*T/4);
N=0.55675303-0.000237030*(T/2)-0.000000060*(T*T/4);

% Prima interazione
AR1=AR-(M+N*sind(AR).*tand(DEC))*T;
DEC1=DEC-(N*cosd(AR))*T;

AR2=(AR1+AR)/2;
DEC2=(DEC1+DEC)/2;

% Seconda interazione
AR3=AR-(M+N*sind(AR2).*tand(DEC2))*T;
DEC3=DEC-(N*cosd(AR2))*T;

AR4=(AR3+AR)/2;
DEC4=(DEC3+DEC)/2;

% Terza interazione
AR2000=AR-(M+N*sind(AR4).*tand(DEC4))*T;
DEC2000=DEC-(N*cosd(AR4))*T;

end


