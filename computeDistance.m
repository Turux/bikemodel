function [trk,distanceSector,distanceCumulative] = computeDistance(trk)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

e = wgs84Ellipsoid;
[distanceSector,heading] = distance(trk.Latitude(1:end-1), trk.Longitude(1:end-1), trk.Latitude(2:end), trk.Longitude(2:end), e);
distanceCumulative = cumsum(distanceSector);
trk.Distance = [0 distanceSector];
trk.DistanceCumulative = [0 distanceCumulative];
trk.Heading=heading;
end

