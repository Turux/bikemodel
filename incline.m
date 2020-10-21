function [trk,incline] = incline(trk)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
ElevationDiff = diff(trk.Elevation);
incline=sind(atand(ElevationDiff./trk.Distance(2:end)));
trk.Incline = [0 incline];
trk.Incline=movmedian(trk.Incline,40);
end

