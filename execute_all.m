%This script accept a GPX file as an input and attempts to predict energy
%expenditure

%Clears workspace and closes all figures
close all
clear all
clc

% Imports GPX file containing route and elevation and asks for a folder save
% location
[FileName,PathName] = uigetfile('*.gpx','Select the path file');
folder_save = uigetdir('/','Where do you want to save the results?');
filename=fullfile(PathName,FileName);
trk = gpxread(filename, 'FeatureType', 'track');

%Calculates speed and road incline
trk = computeDistance(trk);
trk.Elevation=movmean(trk.Elevation,90);
trk = incline(trk);

%Automatically removes points distanced less than 0.1 m and recomputes
%distance and incline
issues= find(trk.Distance<.1);
trk(issues)=[];
trk = computeDistance(trk);
trk = incline(trk);

%Plots a map of the route
webmap
wmline(trk)

%Plots route elevation 
% figure
% plot(trk.DistanceCumulative,movmedian(trk.Elevation,30))
% xlabel('Cumulative Distance (m)')
% ylabel('Elevation (m)')

%Imports Speed Probability Density Function and predicts a speed profile
load('SpeedPD.mat')
speed=(random(speedPDF,[1,length(trk)]));
speed=movmedian(speed,80);
speed=movmean(speed,10);
trk.Speed=speed;
clearvars speed filename FileName PathName 

%Calculates time
trk.Time = trk.Distance./trk.Speed;

%Saves to workspace details about the route
Elevation=range(trk.Elevation);
Speed=mean(trk.Speed);
SpeedSTD=std(trk.Speed);
LenghtM=sum(trk.Distance);
LenghtKm=LenghtM/1000;
LenghtMi=LenghtKm./1.609;
SegmentsNo=length(trk.Distance);
SegmentsLenghtM=mean(trk.Distance);
Heading=mean(trk.Heading);

%Asks user for inputs about the conditions
mh=input('Mass of the Human in Kg: ');
ht=input('Height of the Human in cm: ');
mb=input('Mass of the Bike in Kg: ');
Pb=input('Pressure in Pascal: ');
T=input('Temperature in Celsius: ');
Wh=input('Wind heading in degrees: ');
Ws=input('Wind Speed in m/s: ');
Hu=input('Humidity in %: ');
SA=input('Area facing forward in m2: ');
Crr=input('Coefficent of Rolling Resist: ');
WheelRadius=input('Wheel radius in m: ');

%Prepares predictions
DiPrampero=table;
Olds=table;
Martin=table;
Meyer=table;
Strava=table;

%Computes predictions
[DiPrampero.Total,DiPrampero.Rr,DiPrampero.Ar,DiPrampero.Gr] ...
    = prampero13(mh+mb,trk.Speed, Pb,T,SA,Ws,trk.Incline,trk.Heading,Wh,Crr);
[Olds.Total,Olds.Rr,Olds.Ar,Olds.Gr,Olds.Ac] ...
    = olds93(mh,ht,mb,trk.Speed,trk.Distance,T,Hu,Pb,trk.Incline,trk.Heading,Ws,Wh,Crr);
[Martin.Total,Martin.Ar,Martin.Rr,Martin.Wb,Martin.Gr,Martin.Ac] ...
    = martin(mh,mb,trk.Speed,trk.Distance,T,Pb,Hu,trk.Incline,trk.Heading,SA,Ws,Wh,WheelRadius,Crr);
[Meyer.Total,Meyer.Rr,Meyer.Ar,Meyer.Gr] ...
    = meyer(mh,mb,trk.Speed,T,Pb,Hu,trk.Incline,trk.Heading,SA,Ws,Wh,Crr);
[Strava.Total,Strava.Rr,Strava.Ar,Strava.Gr,Strava.Ac] ...
    = strava(mh,mb,trk.Speed,trk.Distance,T,Pb,Hu,trk.Incline,SA,Crr);

DiPrampero.Power=subplus(DiPrampero.Total);
Olds.Power=subplus(Olds.Total);
Martin.Power=subplus(Martin.Total);
Meyer.Power=subplus(Meyer.Total);
Strava.Power=subplus(Strava.Total);

results=buildtable(DiPrampero.Total,DiPrampero.Rr,DiPrampero.Ar,DiPrampero.Gr,0,0);
newline=buildtable(Olds.Total,Olds.Rr,Olds.Ar,Olds.Gr,Olds.Ac,0);
results=[results;newline];
newline=buildtable(Martin.Total,Martin.Rr,Martin.Ar,Martin.Gr,Martin.Ac,Martin.Wb);
results=[results;newline];
newline=buildtable(Meyer.Total,Meyer.Rr,Meyer.Ar,Meyer.Gr,0,0);
results=[results;newline];
newline=buildtable(Strava.Total,Strava.Rr,Strava.Ar,Strava.Gr,Strava.Ac,0);
results=[results;newline];
results.Properties.RowNames={'DiPrampero' 'Olds' 'Martin' 'Meyer' 'Strava'};

%Plots results
figure('Name','Comparison','Position',[330,412,670,386])
x=categorical(results.Properties.RowNames);
br=barh(x,[results.Rr, results.Ar, results.Gr, results.Ac, results.Wb],'stacked');
hold on
er=errorbar(results.Power,x,results.PowerSEM,'.','horizontal');
er.LineWidth = 1.5;
hold off
xlabel('Average Estimated Power(W)')
legend('Rr','Ar','Gr','Ac','Wb','SEM')

%Clears unused variables from workspace
clearvars x er explode labels pd1 br newline

%Saves results
save(fullfile(folder_save,'results.mat'))
