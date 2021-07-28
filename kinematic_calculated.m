% Provided data: Time, PosZ
% user sets acc, max vel and total dist
% Data can be used to calculate exp values for these parameters
% Exp data should be used for fitting procedure --> more reflective of real
% experiment. User input can be used to check vals are reasonable
% _exp = derived from experimental data
% _set = input set by user, or calculated from user input

% close all
% clear all

% User input settings

acc_set = 1;
vel_set = 0.25;
dist_set = 2.1;

t_acc_set = vel_set/acc_set; % time to reach set velocity
T_dec_set = t_acc_set; % time to decelerate from set velocity
d_acc_set = 0.5*vel_set*t_acc_set; % dist travelled during acceleration
d_dec_set = d_acc_set; % dist travelled during deceleration

d_constVel_set = dist_set - 2*d_acc_set; % distance travelled at constant vel
t_constVel_set = d_constVel_set/vel_set; % time spent at constant vel

d2_set = d_acc_set + d_constVel_set; % dist at which deceleration starts
t2_set = t_acc_set + t_constVel_set; % time at which deceleration starts

tend_set = t2_set + t_acc_set; % time to travel full dist 

% Estimate exp max velocity

dT = mean(diff(Time)); % average difference b/w time points
vel_exp = diff(PosZ)/dT; % velocity curve from simple differencing 

nbins = 150;
[N,edges] = histcounts(vel_exp,nbins); 
[maxCounts, i] = max(N); % find bin with highest number of counts, which should be set constant velocity 
ind = (vel_exp >= edges(i) & vel_exp<= edges(i+1));
vel_max_exp = mean(vel_exp(ind)); % Take the mean velocity of this bin

% Calculate time taken, acceleration and distance travelled to reach max velocity

ind_vmax = (vel_exp>vel_max_exp-0.03 & vel_exp<vel_max_exp+0.03); 
t_acc_exp_i = find(ind_vmax,1); % First index when velocity hits max constant value
t_acc_exp = Time(t_acc_exp_i); % time taken to reach this velocity
d_acc_exp = PosZ(t_acc_exp_i); % distance travelled to reach this velocity

acc_exp = vel_max_exp/t_acc_exp; % average acceleration

if acc_set - 0.2 < acc_exp < acc_set +0.2
    "yes"
else
    "no"
end

% Calculate time taken to reach deceleration and final distance

dist_exp = max(PosZ);

vel_range1 = (vel_exp-vel_max_exp>-0.01 & vel_exp-vel_max_exp<0.01);
t_dec_exp_i = find(vel_range1, 1, 'last');

vel_range2 = (vel_exp>-0.01 & vel_exp<0.01);
skip = round(length(vel_range2)/2);
t_end_exp_i = find(vel_range2(skip+1:end), 1);
t_end_exp_i = t_end_exp_i + skip;

% d_constVel_exp = dist_exp - 2*d_acc_exp;
% t_constVel_exp = d_constVel_exp/vel_max_exp;
% 
% t_dec_exp = t_acc_exp+t_constVel_exp;
% t_dec_exp_i = find(Time-t_dec_exp>0-0.01 & Time-t_dec_exp<0+0.01,1);
% 
% t_end_exp = t_dec_exp + t_acc_exp;
% t_end_exp_i = find(Time-t_end_exp>0-0.01 & Time-t_end_exp<0+0.01,1);
% 
% Determine distance and velocity piecewise polynomials

ft = fittype('m*x + c','independent','x', 'problem', 'c');
f = fit(Time(1:t_acc_exp_i).', vel_exp(1:t_acc_exp_i).',ft, 'StartPoint',acc_exp, 'problem',0);

% Acceleration region polynomials
u1 = [f.m, f.c];
d1 = [0.5*f.m, 0];

% Cross over time one
t1 = vel_max_exp/f.m;


% Constant velocity region polynomials
u2 = [vel_max_exp];
c2 = d1(1)*t1^2 - u2(1)*t1;
d2 = [vel_max_exp, c2];


ft2 = fittype('m*x + c','independent','x');
c3_est = d2(1)*Time(t_dec_exp_i) + c2 - (-acc_exp);
f2 = fit(Time(t_dec_exp_i:t_end_exp_i).', vel_exp(t_dec_exp_i:t_end_exp_i).',ft2, 'StartPoint',[-acc_exp,c3_est]);

u3 = [f2.m, f2.c];



% Cross over time two 
t2 = (u2(1) - u3(2))/u3(1);

% end time
t3 = -f2.c/f2.m;

d3_const = d2(1)*t2 + d2(2) - (0.5*f2.m*(t2^2) + f2.c*t2);
d3 = [0.5*f2.m, f2.c, d3_const];

% plot
figure(1)
hold on
scatter(Time(1:end-1), vel_exp);
% plot(Time(1:t_acc_exp_i), u1(1)*Time(1:t_acc_exp_i)+u1(2), 'LineWidth', 5)
% plot(Time(t_acc_exp_i:t_dec_exp_i), u2(1)*ones(length(Time(t_acc_exp_i:t_dec_exp_i))), 'LineWidth', 5)
% plot(Time(t_dec_exp_i:t_end_exp_i), u3(1)*Time(t_dec_exp_i:t_end_exp_i)+u3(2), 'LineWidth', 5)

plot([0,t1], [0,u1(1)*t1+u1(2)], 'LineWidth', 5)
plot([t1,t2], [u2(1),u2(1)], 'LineWidth', 5)
plot([t2,t3], [u3(1)*t2+u3(2),u3(1)*t3+u3(2)], 'LineWidth', 5)

% Create linspaces for distinct drive regions
npts = 100;
ts1 = linspace(0,t1,npts);
ts2 = linspace(t1,t2,npts);
ts3 = linspace(t2,t3,npts);

u1_vals = u1(1).*ts1+u1(2);
u2_vals = u2(1).*(ts2.^0);
u3_vals = u3(1).*ts3+u3(2);

d1_vals = d1(1).*(ts1.^2);
d2_vals = d2(1).*ts2 + d2(2);
d3_vals = d3(1).*(ts3.^2) + d3(2).*ts3 + d3(3);

figure(2)
hold on
plot(ts1, u1_vals, 'LineWidth', 5)
plot(ts2, u2_vals, 'LineWidth', 5)
plot(ts3, u3_vals, 'LineWidth', 5)

figure(3)
hold on
scatter(Time, PosZ, 'red')
plot(ts1, d1_vals, 'LineWidth', 2)
plot(ts2, d2_vals, 'LineWidth', 2)
plot(ts3, d3_vals, 'LineWidth', 2)




