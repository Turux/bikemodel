function [W,Rr,D,Ri] = prampero13(P,s, Pb,T,SA,w,i,h,wh,Crr)
%PRAMPERO Summary of this function goes here
%   Detailed explanation goes here
%   P: overall weight in kg
%   s: ground speed in m/s
%   Pb: barometric pressure in Pa
%   T: temperature in Celsius
%   SA: body surface in m^2
%   w: wind speed in m/s
%   i: road inclination in decimal
%   h: heading
%   wh: wind heading

T=T+273.16;
Pb=Pb./133.322;
g=9.8131;
SA=1.8;
Crr=Crr*g;

wh = ones(1,length(h))*wh;
teta=angdiff(deg2rad(h),deg2rad(wh));
v = -s+(w*cos(teta));
Rr= ((Crr)*P.*s);
D=((4.1e-2)*(Pb/T)*SA*(v.^2).*s);
Ri=(g*P*i.*s);
Rr=Rr';
D=D';
Ri=Ri';
W = Rr+D+Ri;

end

