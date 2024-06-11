% create distribution plots, a subplot style where the top panel shows the
% distribution as a bar chart and the lower panel shows the percentage of
% cases that have been waiting for over 12 weeks
% Time Distribution Plot - Completed Waits

%% clear workspace, select elective case type and load relevant data
clc;clear all;
CaseType = 'New Outpatient'; % 'Overall' ; 'New Outpatient' ; 'Inpatient/Day case' % choose one of the three types 

if(convertCharsToStrings(CaseType)=='Overall')
    load capacity_dist_overall;
end
if(convertCharsToStrings(CaseType)=='New Outpatient' || convertCharsToStrings(CaseType)=='Inpatient/Day case')
    load capacity_dist_elective;
    capacity_dist = capacity_dist(capacity_dist.PatientType==CaseType,:);
end

% select the date range of interest
IS=1; % corresponds to last quarter of 2012
IE=45; % corresponds to last quarter of 2023
capacity_dist=capacity_dist(IS:IE,:);

%% create data categories for the stacked bar chart

% 0-12 weeks
capacity_dist.c0to12=capacity_dist.LessThan4WeekWait+capacity_dist.X4To8WeekWait +...
    capacity_dist.X8To12WeekWait;
% 12-28 weeks
capacity_dist.c12to28=capacity_dist.X12To16WeekWait+capacity_dist.X16To20WeekWait +...
    capacity_dist.X20To24WeekWait+capacity_dist.X24To28WeekWait;
% 28-40 weeks
capacity_dist.c28to40=capacity_dist.X28To32WeekWait+capacity_dist.X32To36WeekWait +...
    capacity_dist.X36To40WeekWait;
% 40-52 weeks
capacity_dist.c40to52=capacity_dist.X40To44WeekWait+capacity_dist.X44To48WeekWait +...
    capacity_dist.X48To52WeekWait;
% 52-78 weeks
capacity_dist.c52to78=capacity_dist.X52To65WeekWait+capacity_dist.X65To78WeekWait;
% 78+ weeks
capacity_dist.c78toM=capacity_dist.X78To91WeekWait+capacity_dist.X91To104WeekWait +...
    capacity_dist.X104To117WeekWait+capacity_dist.X117To130WeekWait + ...
    capacity_dist.X130To143WeekWait + capacity_dist.X143To156WeekWait;

% let us carry out cubic spline interpolation for the missing data part
 IKnown = [1:18 26:45];
 IUnknown = 19:25;
 int_data = interp1(IKnown,[capacity_dist.c0to12(IKnown) capacity_dist.c12to28(IKnown) ...
     capacity_dist.c28to40(IKnown) capacity_dist.c40to52(IKnown) ...
     capacity_dist.c52to78(IKnown) capacity_dist.c78toM(IKnown)] ...
     ,IUnknown,'spline'); % interpolated data
    
capacity_dist.c0to12(IUnknown) = round(int_data(:,1));
capacity_dist.c12to28(IUnknown) = round(int_data(:,2));
capacity_dist.c28to40(IUnknown) = round(int_data(:,3));
capacity_dist.c40to52(IUnknown) = round(int_data(:,4));
capacity_dist.c52to78(IUnknown) = round(int_data(:,5));
capacity_dist.c78toM(IUnknown) = round(int_data(:,6));

M=1000; % denominator to reduce the number from each
figure,hold on,


subplot(2,1,1);
bar(capacity_dist.date, [capacity_dist.c0to12/M capacity_dist.c12to28/M ...
    capacity_dist.c28to40/M capacity_dist.c40to52/M ...
    capacity_dist.c52to78/M capacity_dist.c78toM/M], 'stacked')
 %colormap('jet'); % doesn't seem to work
 legend('within 12 weeks','12-28 weeks','28-40','40-52','52-78', 'over 78 weeks')
 set (gca(),'FontSize',14)
 grid on
 xticks(capacity_dist.date([1:2:45]));
 xtickformat('MMM-yyyy')
 xtickangle(45)
 ylabel('Number of completed waits in thousands')
 title('Number of completed waits for Outpatients')

subplot(2,1,2)


% let's compute total waits and percentage of waits within 12 weeks
capacity_dist.totalWaits = capacity_dist.c0to12 + capacity_dist.c12to28 + ...
                          capacity_dist.c28to40 + capacity_dist.c40to52 + ...
                          capacity_dist.c52to78 + capacity_dist.c78toM;
capacity_dist.PWithin12Weeks=(capacity_dist.c0to12./capacity_dist.totalWaits)*100;
capacity_dist.POver12Weeks=100-capacity_dist.PWithin12Weeks;

plot(capacity_dist.date,capacity_dist.PWithin12Weeks,'LineWidth',3);
set (gca(),'FontSize',14)
grid on
ylabel('percentage (%) of completed waits that were within 12 weeks')
xticks(capacity_dist.date([1:2:45]));
 xtickformat('MMM-yyyy')
 xtickangle(45)
