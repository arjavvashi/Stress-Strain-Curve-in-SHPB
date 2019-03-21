%Step 0: Clearing Workspace and Command Window before each iteration of this code

clear all
close all
clc

%Step 1: Reading required data from excel file

[file_name,PathName] = uigetfile('*.*','Select The Excel File With Required Data');

promptInc = 'Enter Column Name Housing Incident Strain Values: ';
A = input(promptInc,'s');
promptTra = 'Enter Column Name Housing Transmitted Strain Values: ';
B = input(promptTra,'s');

Incident = xlsread([PathName file_name],'A:A');	                          % Data for the incident pulse
Transmitted = xlsread([PathName file_name],'B:B');	                      % Data for the transmitted pulse

Size = length(Incident);

disp('Press a key to proceed ')  
pause;

%Step 2: Generate required wave-forms critical to our studies

promptInc = 'enter sampling frequency in Hz: ';
freq = input(promptInc);
prompt1 = 'enter 4 for quarter bridge, 2 for half-bridge config.: ';
w = input(prompt1);
prompt2 = 'enter gauge factor of strain gauge: ';
gf = input(prompt2);
prompt3 = 'enter input voltage in volts: ';
Vin = input(prompt3);

for i = 1:Size
    Time(i)=i/freq;
end

plot(Time,Incident);
xlabel('t (in seconds)')
ylabel('Incident strain')

disp('Select initial and final points of incident wave');
[x,y]=ginput(2);
a = ceil((x(2)-x(1))*freq);
b = ceil(x(1)*freq);

for i = 1:a
time(i)=i/(2*10^6);
end


for i = 1:a
inc_wave(i)=Incident(b+i)*w/(gf*Vin);                            
end

plot(time,inc_wave);
xlabel('t (in seconds)')
ylabel('Incident strain')
title('Incident Strain Vs Time')

disp('Press a key to proceed ')  
pause;

plot(Time,Incident);
xlabel('t (in seconds)')
ylabel('Incident strain')

disp('Select initial point of reflected wave');
[x1,y1]=ginput(1);
b1 = ceil(x1*freq);

for i = 1:a
ref_wave(i)=Incident(b1+i)*w/(gf*Vin);
end

plot(time,ref_wave);
xlabel('t (in seconds)')
ylabel('Reflected strain')
title('Reflected Strain Vs Time')

disp('Press a key to proceed ')  
pause;

plot(Time,Transmitted);
xlabel('t (in seconds)')
ylabel('Transmitted strain')

disp('Select initial point of transmitted wave');
[x2,y2]=ginput(1);
b2 = ceil(x2*freq);

for i = 1:a
tra_wave(i)=Transmitted(b1+i)*w/(gf*Vin);
end

plot(time,tra_wave);
xlabel('t (in seconds)')
ylabel('Transmitted strain')
title('Transmitted Strain Vs Time')

disp('Press a key to proceed ')  
pause;

%Step 3: Generate Strain Rate in specimen

prompt4 = 'enter Youngs modulus of bar in GPa: ';
E = input(prompt4);
prompt5 = 'enter density of bar in kg/m3: ';
rho = input(prompt5);
C = sqrt(E*10^9/rho);
prompt6 = 'enter length of specimen in mm: ';
len = input(prompt6);

SR = 2*C.*ref_wave/(len*10^-3);
for i=1:a
    SR_av(i)=mean(SR);
end

plot(time,SR,time,SR_av);
xlabel('t (in seconds)')
ylabel('Sample Strain Rate(1 Wave) (in s^{-1})')
title('Sample Strain Rate (1 Wave) Vs Time')

disp('Press a key to proceed ')  
pause;

SR3W = C.*(inc_wave - ref_wave + tra_wave)/(len*10^-3);
for i=1:a
    SR_av3W(i)=mean(SR3W);
end

plot(time,SR3W,time,SR_av3W);
xlabel('t (in seconds)')
ylabel('Sample Strain Rate(3 Wave) (in s^{-1})')
title('Sample Strain Rate (3 Wave) Vs Time')

disp('Press a key to proceed ')  
pause;
%Step 4: Generate Stress-Strain curves, both true and engineering

prompt7 = 'enter diameter of bar in mm: ';
d_bar = input(prompt7);
prompt8 = 'enter diameter of specimen in mm: ';
d_spec = input(prompt8);

Strain = cumtrapz(time,SR);                               
Stress = (E*10^9)*((d_bar/d_spec)^2).*tra_wave; 

plot(Strain,-Stress);
xlabel('Engineering Strain')
ylabel('Engineering Stress (in Pa)')
title('Engg. Stress (1 Wave) Vs Engg. Strain (1 Wave)')

disp('Press a key to proceed ')  
pause;

Tr_Stress=Stress.*(1+Strain);
Tr_Strain=-log(1+Strain);
plot(Tr_Strain,Tr_Stress);
xlabel('True Strain')
ylabel('True Stress (in Pa)')
title('True Stress (1 Wave) Vs True Strain (1 Wave)')

disp('Press a key to proceed ')  
pause;

Strain3W = cumtrapz(time,SR3W);                               
Stress3W = (E*10^9)*((d_bar/d_spec)^2).*(inc_wave + ref_wave + tra_wave)/2; 

plot(-Strain3W,-Stress3W);
xlabel('Engineering Strain(3 Wave)')
ylabel('Engineering Stress(3 Wave) (in Pa)')
title('Engg. Stress (3 Wave) Vs Engg. Strain (3 Wave)')

disp('Press a key to proceed ')  
pause;

Tr_Stress3W=Stress3W.*(1+Strain3W);
Tr_Strain3W=-log(1+Strain3W);
plot(Tr_Strain3W,Tr_Stress3W);
xlabel('True Strain(3 Wave)')
ylabel('True Stress(3 Wave) (in Pa)')
title('True Stress (3 Wave) Vs True Strain (3 Wave)')

disp('Press a key to proceed ')  
pause;

%Step 5: Generate all previously found plots

figure

subplot(3,3,1)
plot(time,inc_wave);
xlabel('t (in seconds)')
ylabel('Incident strain')
title('Incident Strain Vs Time')

subplot(3,3,2)
plot(time,ref_wave);
xlabel('t (in seconds)')
ylabel('Reflected strain')
title('Reflected Strain Vs Time')

subplot(3,3,3)
plot(time,tra_wave);
xlabel('t (in seconds)')
ylabel('Transmitted strain')
title('Transmitted Strain Vs Time')

subplot(3,3,4)
plot(time,SR,time,SR_av);
xlabel('t (in seconds)')
ylabel('Sample Strain Rate in s^{-1}')
title('Sample Strain Rate (1 Wave) Vs Time')

subplot(3,3,5)
plot(time,SR3W,time,SR_av3W);
xlabel('t (in seconds)')
ylabel('Sample Strain Rate in s^{-1}')
title('Sample Strain Rate (3 Wave) Vs Time')

subplot(3,3,6)
plot(Strain,-Stress);
xlabel('Engineering Strain')
ylabel('Engineering Stress (in Pa)')
title('Engineering Stress (1 Wave) Vs Engineering Strain (1 Wave)')

subplot(3,3,7)
plot(Strain3W,-Stress3W);
xlabel('Engineering Strain')
ylabel('Engineering Stress (in Pa)')
title('Engineering Stress (3 Wave) Vs Engineering Strain (3 Wave)')

subplot(3,3,8)
plot(Tr_Strain,Tr_Stress);
xlabel('True Strain')
ylabel('True Stress (in Pa)')
title('True Stress (1 Wave) Vs True Strain (1 Wave)')

subplot(3,3,9)
plot(Tr_Strain3W,Tr_Stress3W);
xlabel('True Strain')
ylabel('True Stress (in Pa)')
title('True Stress (3 Wave) Vs True Strain (3 Wave)')

disp('Press a key to end')  
pause;

disp('Thank You For Using This Program')  
pause(3.0);