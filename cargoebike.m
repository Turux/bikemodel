close all
clear all
clc

[FileName,PathName] = uigetfile('*.gpx','Select the GPX file');
filename=fullfile(PathName,FileName);
trk = gpxread(filename, 'FeatureType', 'track');
[FileName,PathName] = uigetfile('*.csv','Select the Garmin file');
filename=fullfile(PathName,FileName);
garmin = importgarmin(filename);
current_flag=input('Is there a current clamp reading? ');
if current_flag
    [FileName,PathName] = uigetfile('*.csv','Select the Current file');
    filename=fullfile(PathName,FileName);
    currentclamp = importcurrent(filename);
    currentclamp.Date=currentclamp.Date+timeofday(currentclamp.Time);
    test=figure;
    ax1=subplot(3,1,1);
    plot(garmin.date, garmin.speed)
    title('Speed (m/s)')
    ax2=subplot(3,1,2);
    plot(garmin.date,garmin.power)
    title('Power (W)')
    ax3=subplot(3,1,3);
    plot(currentclamp.Date,currentclamp.Reading)
    title('Motor Current (A)')
    linkaxes([ax1,ax2,ax3],'x')
    sec_diff=input('Difference in seconds? ');
    currentclamp.newdate=currentclamp.Date+seconds(sec_diff);
    close(test)
end
clear filename FileName Pathname PathName sec_diff test ax1 ax2 ax3

figure
ax1=subplot(3+current_flag,1,1);
plot(garmin.date,garmin.altitude)
title('Elevation (m)')
ax2=subplot(3+current_flag,1,2);
plot(garmin.date, garmin.speed)
yline(6.944444444)
title('Speed (m/s)')
ax3=subplot(3+current_flag,1,3);
plot(garmin.date,garmin.power)
title('Human Power (W)')
if current_flag
    ax4=subplot(4,1,4);
    plot(currentclamp.newdate,currentclamp.Reading)
    title('eBike Motor Current (A)')
    linkaxes([ax1,ax2,ax3,ax4],'x')
    clear ax4
else
    linkaxes([ax1,ax2,ax3],'x')
end

clear ax1 ax2 ax3 ans current_flag

figure('Name','Speed vs Current','Position',[330,412,670,386])
yyaxis left
plot(garmin.date,garmin.speed)
ylabel('Speed (m/s)')
yline(6.666667,'-','Cut-off Speed')
yyaxis right
plot(currentclamp.newdate,currentclamp.Reading)
ylabel('Current (A)')
ylim([0 25])
xlabel('Time')

figure('Name','Power vs Current','Position',[330,412,670,386])
yyaxis left
plot(garmin.date,garmin.power)
ylabel('Power (W)')
yyaxis right
plot(currentclamp.newdate,currentclamp.Reading)
ylabel('Current (A)')
xlabel('Time')
