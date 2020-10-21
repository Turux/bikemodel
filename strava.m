function [Ptot,Prr,Pw,Pg,Pa] = strava(mh,mb,v,d,T,P,H,G,A,Crr)
%STRAVA Summary of this function goes here
%   Detailed explanation goes here
%   mh: weight of the human (kg)
%   mb: weight of the bicycle (kg)
%   v: ground velocity (m/s)
%   T: temperature in (K)
%   P: barometric pressure (Torr)
%   H: Percentage of humidity
%   G: road inclination in decimal
%   A: Area facing frontwards (m^2)


Cd=0.9;
g=9.8131;
t=d./v;


ro=air_density(T,H,P);
mtot=mh+mb;

Prr=Crr*mtot*g.*v;
Prr=Prr';

Pw=0.5*ro*v.^3*Cd*A;
Pw=Pw';

Pg=mtot*g.*G.*v;
Pg=Pg';

a=[0 diff(v)];
a=a./t;

Pa=mtot.*a.*v;
Pa=Pa';

Ptot=Prr+Pw+Pg+Pa;
end

