function [P,Pat,Prr,Pwb,Ppe,Pke] = martin(mh,mb,v,d,T,P,H,G,h,A,Ws,Wh,wr,Crr)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


Cd=0.9;
g=9.8131;
ro=air_density(T,H,P);
mtot=mh+mb;
I=0.14;
Fw=0.0044;
t=d./v;


Wh = ones(1,length(h))*Wh;
teta=angdiff(deg2rad(Wh),deg2rad(h));
Va = -v+(Ws*cos(teta));

Pad=0.5*ro*Cd*A.*(Va.^2).*v;
Pwr=0.5*ro*Fw.*(Va.^2).*v;

Pad=Pad';
Pwr=Pwr';

Pat=Pad+Pwr;

Gtemp=asind(G);

Prr=v.*cosd(Gtemp)*Crr*mtot*g;
Prr=Prr';

Pwb=(v.*(91+8.7.*v)).*(10^-3);
Pwb=Pwb';

Ppe=v*mtot*g.*G;
Ppe=Ppe';

a=[0 diff(v)];
a=a./t;

Pke=((mtot+(I/(wr^2))).*v.*a);
Pke=Pke';

P=Pat+Prr+Pwb+Ppe+Pke;

end

