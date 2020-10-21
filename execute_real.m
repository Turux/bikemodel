%This script accepts a GPX file and a Garmin CSV file as an input and
%attempts to predict energy expenditure to then compare prediction with
%real recorded data

%Clears workspace and closes all figures
close all
clear all
clc

% Imports GPX file containing route and elevation
[FileName,PathName] = uigetfile('*.gpx','Select the path file');
filename=fullfile(PathName,FileName);
trk = gpxread(filename, 'FeatureType', 'track');

%Imports Garmin file processed with Garmin2Human for info see:
%https://github.com/Turux/Garmin2Human
[FileName,PathName] = uigetfile('*.csv','Select the Garmin file');
filename=fullfile(PathName,FileName);
garmin = importgarmin(filename);

% Calculates speed, time, distance, and road incline 
trk.Speed=garmin.speed;
trk = computeDistance(trk);
trk.Elevation=movmean(trk.Elevation,90);
trk = incline(trk);
trk.Time = trk.Distance./trk.Speed;

%Plots a map of the route
webmap
wmline(trk)

%Saves to workspace details about the route
Elevation=range(trk.Elevation);
Speed=mean(trk.Speed);
Lenght=sum(trk.Distance)/1000;
LenghtMi=Lenght./1.609;
Segments=mean(trk.Distance);

%Asks user for inputs about the conditions
mh=input('Mass of the Human in Kg: ');
ht=input('Height of the Human in cm: ');
mb=input('Mass of the Bike in Kg: ');
Pb=input('Pressure in Pascal: ');
T=mean(garmin.temperature);
Wh=input('Wind heading in degrees: ');
Ws=input('Wind Speed in m/s: ');
Hu=input('Humidity in %: ');
SA=input('Area facing forward in m2: ');
Crr=input('Coefficent of Rolling Resist: ');
wr=input('Wheel radius in m: ');

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
    = martin(mh,mb,trk.Speed,trk.Distance,T,Pb,Hu,trk.Incline,trk.Heading,SA,Ws,Wh,wr,Crr);
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

%Computes errors
target=mean(garmin.power);
target_error=sem(garmin.power);
err =results.Total-target;
errper=100*(err/target);

%Plots pie-chart for contributions comparision
% figure
% labels={'Rr','Ar','Gr','',''};
% explode=[1 1 0,0,0];
% subplot(2,3,1)
% pie(table2array(results(1,3:end)),explode);
% legend('Rr','Ar','Gr','Ac','Wb', 'Position', ...
%     [0.7276,0.0057,0.1482,0.5833]);
% explode=[1 1 0 1 1];
% subplot(2,3,2)
% pie(table2array(results(2,3:end)),explode);
% subplot(2,3,3)
% pie(table2array(results(3,3:end)),explode);
% subplot(2,3,4)
% pie(table2array(results(4,3:end)),explode);
% subplot(2,3,5)
% pie(table2array(results(5,3:end)),explode);
% annotation('textbox', ...
%     [0.153670634920634,0.946996466431095,0.162500000000001,0.030397105838805] ...
%     , 'String', "Di Prampero")
% annotation('textbox', ...
%     [0.434920634920634,0.946996466431095,0.162500000000001,0.030397105838805] ...
%     , 'String', "Olds")
% annotation('textbox', ...
%     [0.712003968253968,0.946996466431095,0.162500000000001,0.030397105838805] ...
%     , 'String', "Martin")
% annotation('textbox', ...
%     [0.153670634920634,0.46878680800942,0.162500000000001,0.030397105838805] ...
%     , 'String', "Meyer")
% annotation('textbox', ...
%     [0.434920634920634,0.46878680800942,0.162500000000001,0.030397105838805] ...
%     , 'String', "Strava")

%Plots results against real life data
figure('Name','Comparison','Position',[330,412,670,386])
x=categorical(results.Properties.RowNames);
br=barh(x,results.Total);
br.BarWidth=0.6;
hold on
er=errorbar(results.Total,x,results.TotalSEM,'.','horizontal');
er.LineWidth = 1.5;
xline(target,'LineWidth',0.8)
xline(target-target_error,'r--')
xline(target+target_error,'r--')
hold off
legend('Predicted Value','SEM','Recorded Value','SEM')
xlabel('Average Estimated Power(W)')

%Plots route elevation 
% figure
% plot(trk.DistanceCumulative,movmedian(trk.Elevation,30))
% xlabel('Cumulative Distance (m)')
% ylabel('Elevation (m)')

%Plots results
% figure('Name','Comparison','Position',[330,412,670,386])
% x=categorical(results.Properties.RowNames);
% br=barh(x,[results.Rr, results.Ar, results.Gr, results.Ac, results.Wb],'stacked');
% %br.BarWidth=0.6;
% hold on
% er=errorbar(results.Power,x,results.PowerSEM,'.','horizontal');
% er.LineWidth = 1.5;
% hold off
% xlabel('Average Estimated Power(W)')
% legend('Rr','Ar','Gr','Ac','Wb','SEM')

%Clears unused variables
clearvars x er explode issues labels pd1 br newline
