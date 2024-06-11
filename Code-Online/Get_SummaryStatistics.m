% Extract the quarterly reported data for waiting and capacity
clc; clear all;

CaseType = 'Overall'; % 'Overall' ; 'New Outpatient' ; 'Inpatient/Day case' % choose one of the three types 

if(convertCharsToStrings(CaseType)=='Overall')
    load waiting_dist_overall;
    load capacity_dist_overall;
end
if(convertCharsToStrings(CaseType)=='New Outpatient' || convertCharsToStrings(CaseType)=='Inpatient/Day case')
    load waiting_dist_elective;
    load capacity_dist_elective;
    waiting_dist = waiting_dist(waiting_dist.PatientType==CaseType,:);
    capacity_dist = capacity_dist(capacity_dist.PatientType==CaseType,:);
end





waiting_dist = Process_Distribution(waiting_dist);
capacity_dist =  Process_Distribution(capacity_dist);
% get the quarterly time-series for the waiting list
I_2013 = 2:5; % indices for 2013
I_2019 = 26:29; % incides for 2019
I_2023 = 42:45; % incides for 2023
SI = [I_2013 I_2019 I_2023]; % all indices of interest


% get stats for waiting
disp(['Mean Waiting, 2013: ',num2str(round(mean(waiting_dist.totalWaits(I_2013))))]);
disp(['Mean Waiting, 2019: ',num2str(round(mean(waiting_dist.totalWaits(I_2019))))]);
disp(['Mean Waiting, 2023: ',num2str(round(mean(waiting_dist.totalWaits(I_2023))))]);
pc_2013_2019 = calculate_percentage_change(mean(waiting_dist.totalWaits(I_2013)),mean(waiting_dist.totalWaits(I_2019)));
pc_2019_2023 = calculate_percentage_change(mean(waiting_dist.totalWaits(I_2019)),mean(waiting_dist.totalWaits(I_2023)));
disp(['Percentage Change in Waiting from 2013 to 2019: ',num2str(pc_2013_2019)]);
disp(['Percentage Change in Waiting from 2019 to 2023: ',num2str(pc_2019_2023)]);



% get stats for capacity
disp(['Mean Capacity, 2013: ',num2str(round(mean(capacity_dist.totalWaits(I_2013))))]);
disp(['Mean Capacity, 2019: ',num2str(round(mean(capacity_dist.totalWaits(I_2019))))]);
disp(['Mean Capacity, 2023: ',num2str(round(mean(capacity_dist.totalWaits(I_2023))))]);
pc_2013_2019 = calculate_percentage_change(mean(capacity_dist.totalWaits(I_2013)),mean(capacity_dist.totalWaits(I_2019)));
pc_2019_2023 = calculate_percentage_change(mean(capacity_dist.totalWaits(I_2019)),mean(capacity_dist.totalWaits(I_2023)));
disp(['Percentage Change in Capacity from 2013 to 2019: ',num2str(pc_2013_2019)]);
disp(['Percentage Change in Capacity from 2019 to 2023: ',num2str(pc_2019_2023)]);


%% let us now pass data into R for computing the 95% CI
%waiting_dist.totalWaits(SI)
%capacity_dist.totalWaits(SI)


%% Get the total waiting , total waiting > 12 Weeks, and total waiting > 52 weeks#
% total waiting
disp(['Total Waits end of 2013: ',num2str(waiting_dist.totalWaits(I_2013(end)))]);
disp(['Total Waits end of 2019: ',num2str(waiting_dist.totalWaits(I_2019(end)))]);
disp(['Total Waits end of 2023: ',num2str(waiting_dist.totalWaits(I_2023(end)))]);

% waiting > 12 weeks
waiting_dist.cOver12Weeks = waiting_dist.totalWaits-waiting_dist.c0to12;
disp(['Total Waits >12 Weeks, end of 2013: ',num2str(waiting_dist.cOver12Weeks(I_2013(end)))]);
disp(['Total Waits >12 Weeks, end of 2019: ',num2str(waiting_dist.cOver12Weeks(I_2019(end)))]);
disp(['Total Waits >12 Weeks, end of 2023: ',num2str(waiting_dist.cOver12Weeks(I_2023(end)))]);

disp(['Proportion of Waits >12 Weeks, end of 2013: ',num2str(waiting_dist.POver12Weeks(I_2013(end)))]);
disp(['Proportion of Waits >12 Weeks, end of 2019: ',num2str(waiting_dist.POver12Weeks(I_2019(end)))]);
disp(['Proportion of Waits >12 Weeks, end of 2023: ',num2str(waiting_dist.POver12Weeks(I_2023(end)))]);

% waiting over 52 weeks
waiting_dist.cOver52Weeks = waiting_dist.c52to78+waiting_dist.c78toM;
disp(['Total Waits >52 Weeks, end of 2013: ',num2str(waiting_dist.cOver52Weeks(I_2013(end)))]);
disp(['Total Waits >52 Weeks, end of 2019: ',num2str(waiting_dist.cOver52Weeks(I_2019(end)))]);
disp(['Total Waits >52 Weeks, end of 2023: ',num2str(waiting_dist.cOver52Weeks(I_2023(end)))]);

disp(['Proportion of Waits >52 Weeks, end of 2013: ',num2str(waiting_dist.POver52Weeks(I_2013(end)))]);
disp(['Proportion of Waits >52 Weeks, end of 2019: ',num2str(waiting_dist.POver52Weeks(I_2019(end)))]);
disp(['Proportion of Waits >52 Weeks, end of 2023: ',num2str(waiting_dist.POver52Weeks(I_2023(end)))]);

