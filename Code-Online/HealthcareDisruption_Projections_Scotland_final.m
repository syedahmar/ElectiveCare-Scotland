%% Description
% Author: Syed Ahmar Shah
% ahmar.shah@ed.ac.uk
% May 2, 2024
% This script can be used to investigate the extent of healthcare disruption, and create projections on the number of people who are waiting for elective treatment in hospitals
% The model is learned separately (GetModelParameters_final) and in this script, it is loaded separately 
% capacity increase variable in line # 101
% location of plot is chosen in line # 48 (comment out line 47)
%% clear workspace, select elective case type and load relevant data
clc;clear all;
CaseType = 'Overall'; % 'Overall' ; 'New Outpatient' ; 'Inpatient/Day case' % choose one of the three types 

if(convertCharsToStrings(CaseType)=='Overall')
    load Waiting_Overall;
    load Additions_Overall;
end
if(convertCharsToStrings(CaseType)=='New Outpatient' || convertCharsToStrings(CaseType)=='Inpatient/Day case')
    load WaitingSelected;
    load AdditionsSelected;
    Waiting = Waiting(Waiting.PatientType==CaseType,:);
    Additions = Additions(Additions.PatientType==CaseType,:);
end

% remove the additional data points corresponding to the first quarter of
% 2024
Waiting(136:end,:)=[];
Additions(46,:)=[];

%% let us plot the waiting times figure with error estimates for counterfactuals
%%%%%%%%%%%%%%% Waiting Time %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pre-pandemic indices for waiting
pre_w_start=4; % corresponds to January 31, 2012
pre_w_end=87; % corresponds to December 31, 2019
I_W_Pre=(pre_w_start:pre_w_end); % indices to use for dataframe
x_W_Pre=1:length(I_W_Pre); % x_time to use for model fitting

% remove the rows where the data is missing
idx=(~isnan(Waiting.NumberWaiting(I_W_Pre)));
I_W_Pre=I_W_Pre(idx);
x_W_Pre=x_W_Pre(idx);
% create a linear model for waiting list
[model_WaitingList, error_WaitingList]=polyfit(x_W_Pre,Waiting.NumberWaiting(I_W_Pre),1);


% plot the waiting list and the associated model
figure, hold on;
%subplot(2,3,1),hold on,
DT=1000;
plot(Waiting.date(I_W_Pre),Waiting.NumberWaiting(I_W_Pre)/DT,'o');
% pre-pandemic
y_est_pre = polyval(model_WaitingList,x_W_Pre);
plot(Waiting.date(I_W_Pre),y_est_pre/DT,'-b','LineWidth',3);

% format the figure
cF=gca();
set(cF,'FontSize',18);
cF.YAxis.Exponent=0;
grid on;

% counterfactual (if pre-pandemic trend had continued)
post_start=88; % January 1, 2020
post_end=135; % December 31, 2023
I_W_post=post_start:post_end;
x_W_post=(1:length(I_W_post))+x_W_Pre(end);
[y_est_post, y_est_post_error]= polyval(model_WaitingList,x_W_post,error_WaitingList);
plot(Waiting.date(I_W_post),y_est_post/DT,'-g','LineWidth',3);

% actual waiting list during the pandemic
plot(Waiting.date(I_W_post),Waiting.NumberWaiting(I_W_post)/DT,'-r','LineWidth',3);

legend('monthly waiting (raw data, pre-pandemic)','monthly waiting (modelled, pre-pandemic)','projected monthly waiting (if no pandemic)','actual monthly waiting during pandemic')
set(gca(),'FontSize',16)
xlabel('Year');
%ylabel('Total Number of People Waiting (in Thousands)')
%title('Elective Case Type: Outpatients')

%% Set up Projections time-series and make assumptions about system demand/capacity (monthly)

% create future time vector

t_2024 = datetime(2024,3:3:12,30);
t_2025 = datetime(2025,3:3:12,30);
t_2026 = datetime(2026,3:3:12,30);
x_future_quarters=[t_2024'; t_2025'; t_2026'];

index_current = size(Waiting.date,1); % index number of current time-series
x_future_index=(index_current+1):(index_current+size(x_future_quarters,1));
x_future_index=x_future_index';

% quarterly demand
recent_quarterly_demand = round(mean(Additions.Additions(end-3:end)));
y_demand_future = ones(length(x_future_index),1)*recent_quarterly_demand;

% quarterly capacity
y_treated_start_mean = round(mean(Additions.Removals(end-3:end)));
y_treated_start_std = round(std(Additions.Removals(end-3:end)));
%y_treated_start_lower = y_treated_start_mean - 1*y_treated_start_std;
%y_treated_start_upper = y_treated_start_mean + 1*y_treated_start_std;

percent_increase=30; % percent increase in system capacity compared to what has been observed until recorded data

y_treated_start=y_treated_start_mean; 
y_treated_end = y_treated_start + y_treated_start*percent_increase/100;
y_treated=linspace(y_treated_start,y_treated_end,length(x_future_index));
y_treated=round(y_treated');

% TW (total waiting)
TW_Pre=Waiting.NumberWaiting(end-3:end); %from n=-3 to n=0, assume that the total waiting is whatever the value at the end from the pandemic period is
y_waiting=[TW_Pre; zeros(length(x_future_index),1)]; % from n -3 to 12 (12 quarters corresponding to 36 months of projections)

%% simulate projections

% get percentiles for all estimates
num_sim = 1000; % number of simulations
y_waiting_global=zeros(num_sim,12);
for kl=1:num_sim
    disp(['Processing loop number: ',num2str(kl)]);
    Get_Projections
    y_waiting_global(kl,:)=y_waiting(5:end)';
end

%% plotting

plot(x_future_quarters, prctile(y_waiting_global(:,1:end)./DT,50,1),'-k','LineWidth',3)
plot(x_future_quarters, prctile(y_waiting_global(:,1:end)./DT,2.5,1),'--k','LineWidth',1.5,'HandleVisibility','off')
plot(x_future_quarters, prctile(y_waiting_global(:,1:end)./DT,97.5,1),'--k','LineWidth',1.5,'HandleVisibility','off')

%% let us extend the counterfactual to cover the projection period as well
t_new = 136:3:136+35;
y_est_proj= polyval(model_WaitingList,t_new);
plot(x_future_quarters,y_est_proj/DT,'-g','LineWidth',3);

%% get the peak value and the quarter when that happens
[IV ID]=max(round(prctile(y_waiting_global(:,1:end),50,1)));
[IV, ID]=max(round(prctile(y_waiting_global(:,1:end),50,1)));disp(['Peak Value: ',num2str(IV),' ,Peak Quarter: ',datestr(x_future_quarters(ID))]);

