function [P,Prr,Pra,Pgrade,Pacc] = olds93(mh,ht,mb,v,d,T,H,P,G,h,Ws,Wh,Crr)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


g=9.8131;
Crr=Crr*g;
mtot=mh+mb;


BSA=(mh^.425)*(ht^.725)*0.007184;
CFa=BSA/(1.77);

CFp=air_density(T,H,P);
t=d./v;
Wh = ones(1,length(h))*Wh;
teta=angdiff(deg2rad(h),deg2rad(Wh));
Va = (Ws*cos(teta));
a=[0 diff(v)];
Gtemp=asind(G);

Prr=Crr.*cosd(Gtemp)*(mtot).*v;
Prr=Prr';

Pra=0.19*CFp*CFa.*((-v+Va).^2).*v;
Pra=Pra';

Pgrade=mtot*g.*G.*v;
Pgrade=Pgrade';

a=[0 diff(v)];
a=a./t;

Pacc=(mtot.*v.*a)+(0.19*CFp*CFa.*(Va+(v+Va)).*a);
Pacc=Pacc';
P=Prr+Pra+Pgrade+Pacc;

end

