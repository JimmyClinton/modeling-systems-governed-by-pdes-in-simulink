%% cooling fan
tauFan = 0.2192;
%% load digitized data
V2RPM = readmatrix('RPMvsV.csv');
RPM2CFM = readmatrix('CFMvsRPM.csv');
%% conversion constants
CFM2CMS = 0.00047194745; % CFM to cubic meters per second