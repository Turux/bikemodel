function [results] = buildtable(T,Rr,Ar,Gr,Ac,Wb)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

T=subplus(T);
T(isinf(T))=[];
T(isnan(T))=[];
RrAbs=abs(Rr);
ArAbs=abs(Ar);
GrAbs=abs(Gr);
Ac(isinf(Ac))=[];
AcAbs=abs(Ac);
WbAbs=abs(Wb);
AbsTotal=RrAbs+ArAbs+GrAbs+AcAbs+WbAbs;

results=table;
results.Total = nanmean(T);
results.TotalSEM=sem(T);
RrRatio=RrAbs./AbsTotal;
results.RrRatio=nanmean(RrRatio);
ArRatio=ArAbs./AbsTotal;
results.ArRatio=nanmean(ArRatio);
GrRatio=GrAbs./AbsTotal;
results.GrRatio=nanmean(GrRatio);
AcRatio=AcAbs./AbsTotal;
results.AcRatio=nanmean(AcRatio);
WbRatio=WbAbs./AbsTotal;
results.WbRatio=nanmean(WbRatio);

RrPos=subplus(Rr);
ArPos=subplus(Ar);
GrPos=subplus(Gr);
AcPos=subplus(Ac);
WbPos=subplus(Wb);

results.Rr = nanmean(RrPos);
results.Ar = nanmean(ArPos);
results.Gr = nanmean(GrPos);
results.Ac = nanmean(AcPos);
results.Wb = nanmean(WbPos);
Power=RrPos+ArPos+GrPos+AcPos+WbPos;
results.Power=mean(Power);
results.PowerSEM=sem(Power);

end

