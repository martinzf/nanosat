clear;clf;clc;

% RW response data
list = load('rw_data.mat');
fns = fieldnames(list);
for i = 1:length(fns)
    series = list.(fns{i});
    x = series{1}.Values.Data;
    tps(:,i) = double(reshape(x,[length(x),1]));
    pwm(:,i) = series{2}.Values.Data;
end
% Averages
tps = mean(tps,2);
pwm = mean(pwm,2);

% Plotting
n = length(tps)-1;
plot(pwm(2:n/4),tps(2:n/4),'b' ...
    ,pwm(n/4:n/2),tps(n/4:n/2),'r' ...
    ,pwm(n/2:3*n/4),tps(n/2:3*n/4),'b' ...
    ,pwm(3*n/4:n),tps(3*n/4:n),'r')
title('PWM-TPS curve')
xlabel('PWM')
ylabel('TPS')
legend('Acceleration','Deceleration','Location','northwest')
xlim([-255,255])

% Data smoothing
figure()
tps_smooth = movmean(tps(2:end),20);
plot(pwm(2:n/4),tps_smooth(2:n/4),'b' ...
    ,pwm(n/4:n/2),tps_smooth(n/4:n/2),'r' ...
    ,pwm(n/2:3*n/4),tps_smooth(n/2:3*n/4),'b' ...
    ,pwm(3*n/4:n),tps_smooth(3*n/4:n),'r')
title('PWM-TPS curve movmean')
xlabel('PWM')
ylabel('TPS')
legend('Acceleration','Deceleration','Location','northwest')
xlim([-255,255])
ylim([-3600,3600])

% Acceleration
figure()
d = 3; % Polynomial fit degree

pwm_neg = pwm(2:n/4);
tps_neg = tps_smooth(2:n/4);
idx_neg = tps_neg < -15;
pwm_neg = pwm_neg(idx_neg);
tps_neg = tps_neg(idx_neg);
p_neg_a = polyfit(tps_neg,pwm_neg,d);

pwm_pos = pwm(n/2:3*n/4);
tps_pos = tps_smooth(n/2:3*n/4);
idx_pos = tps_pos > 15;
pwm_pos = pwm_pos(idx_pos);
tps_pos = tps_pos(idx_pos);
p_pos_a = polyfit(tps_pos,pwm_pos,d);

plot(tps_neg,pwm_neg,'r' ...
    ,linspace(-3500,0,100),polyval(p_neg_a,linspace(-3500,0,100)),'b' ...
    ,tps_pos,pwm_pos,'r' ...
    ,linspace(0,3300,100),polyval(p_pos_a,linspace(0,3300,100)),'b' ...
    ,[0,0],[p_neg_a(end),p_pos_a(end)],'g' ...
    ,0,p_neg_a(end),'.k' ...
    ,0,p_pos_a(end),'.k')
title('Acceleration response fitting')
xlabel('TPS')
ylabel('PWM')
legend('Data','Fit','','','No response','Location','northwest')

% Deceleration
figure()
d = 2; % Polynomial fit degree

pwm_neg = pwm(n/4:n/2);
tps_neg = tps_smooth(n/4:n/2);
idx_neg = tps_neg < -5;
pwm_neg = pwm_neg(idx_neg);
tps_neg = tps_neg(idx_neg);
p_neg_d = polyfit(tps_neg,pwm_neg,d);

pwm_pos = pwm(3*n/4:n);
tps_pos = tps_smooth(3*n/4:n);
idx_pos = tps_pos > 5;
pwm_pos = pwm_pos(idx_pos);
tps_pos = tps_pos(idx_pos);
p_pos_d = polyfit(tps_pos,pwm_pos,d);

plot(tps_neg,pwm_neg,'r' ...
    ,linspace(-3500,0,100),polyval(p_neg_d,linspace(-3500,0,100)),'b' ...
    ,tps_pos,pwm_pos,'r' ...
    ,linspace(0,3300,100),polyval(p_pos_d,linspace(0,3300,100)),'b' ...
    ,[0,0],[p_neg_d(end),p_pos_d(end)],'g' ...
    ,0,p_neg_d(end),'.k' ...
    ,0,p_pos_d(end),'.k')
title('Deceleration response fitting')
xlabel('TPS')
ylabel('PWM')
legend('Data','Fit','','','No response','Location','northwest')