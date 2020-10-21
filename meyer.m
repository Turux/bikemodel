function [Ptot,Prr,Pw,Pg,Pa] = meyer(mh,mb,v,T,P,H,G,h,A,Ws,Wh,Crr)
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
Gtemp=asind(G);

ro=air_density(T,H,P);
mtot=mh+mb;

Prr=Crr*mtot*g*cosd(Gtemp).*v;
Prr=Prr';

Wh = ones(1,length(h))*Wh;
teta=angdiff(deg2rad(h),deg2rad(Wh));
Va = (Ws*cos(teta));

Pw=0.5*ro*((-v+Va).^2)*Cd*A.*v;
Pw=Pw';

Pg=mtot*g.*G.*v;
Pg=Pg';


Ptot=Prr+Pw+Pg;
end

