% create distribution plots, a subplot style where the top panel shows the
% distribution as a bar chart and the lower panel shows the percentage of
% cases that have been waiting for over 12 weeks
% Time Distribution Plot - Ongoing Waits

%% clear workspace, select elective case type and load relevant data
clc;clear all;
CaseType = 'Inpatient/Day case'; % 'Overall' ; 'New Outpatient' ; 'Inpatient/Day case' % choose one of the three types 

if(convertCharsToStrings(CaseType)=='Overall')
    load waiting_dist_overall;
end
if(convertCharsToStrings(CaseType)=='New Outpatient' || convertCharsToStrings(CaseType)=='Inpatient/Day case')
    load waiting_dist_elective;
    waiting_dist = waiting_dist(waiting_dist.PatientType==CaseType,:);
end

% select the date range of interest
IS=1; % corresponds to last quarter of 2012
IE=45; % corresponds to last quarter of 2023
waiting_dist=waiting_dist(IS:IE,:);
%% create data categories for the stacked bar chart

% 0-12 weeks
waiting_dist.c0to12=waiting_dist.LessThan4WeekWait+waiting_dist.X4To8WeekWait +...
    waiting_dist.X8To12WeekWait;
% 12-28 weeks
waiting_dist.c12to28=waiting_dist.X12To16WeekWait+waiting_dist.X16To20WeekWait +...
    waiting_dist.X20To24WeekWait+waiting_dist.X24To28WeekWait;
% 28-40 weeks
waiting_dist.c28to40=waiting_dist.X28To32WeekWait+waiting_dist.X32To36WeekWait +...
    waiting_dist.X36To40WeekWait;
% 40-52 weeks
waiting_dist.c40to52=waiting_dist.X40To44WeekWait+waiting_dist.X44To48WeekWait +...
    waiting_dist.X48To52WeekWait;
% 52-78 weeks
waiting_dist.c52to78=waiting_dist.X52To65WeekWait+waiting_dist.X65To78WeekWait;
% 78+ weeks
waiting_dist.c78toM=waiting_dist.X78To91WeekWait+waiting_dist.X91To104WeekWait +...
    waiting_dist.X104To117WeekWait+waiting_dist.X117To130WeekWait + ...
    waiting_dist.X130To143WeekWait + waiting_dist.X143To156WeekWait;

% let us carry out cubic spline interpolation for the missing data part
IKnown = find(~isnan(waiting_dist.LessThan4WeekWait));
IUnknown = find(isnan(waiting_dist.LessThan4WeekWait));
int_data = interp1(IKnown,[waiting_dist.c0to12(IKnown) waiting_dist.c12to28(IKnown) ...
     waiting_dist.c28to40(IKnown) waiting_dist.c40to52(IKnown) ...
     waiting_dist.c52to78(IKnown) waiting_dist.c78toM(IKnown)] ...
     ,IUnknown,'spline'); % interpolated data
    
waiting_dist.c0to12(IUnknown) = round(int_data(:,1));
waiting_dist.c12to28(IUnknown) = round(int_data(:,2));
waiting_dist.c28to40(IUnknown) = round(int_data(:,3));
waiting_dist.c40to52(IUnknown) = round(int_data(:,4));
waiting_dist.c52to78(IUnknown) = round(int_data(:,5));
waiting_dist.c78toM(IUnknown) = round(int_data(:,6));




M=1000; % denominator to reduce the number from each
figure,hold on,


subplot(2,1,1);
bar(waiting_dist.date, [waiting_dist.c0to12/M waiting_dist.c12to28/M ...
    waiting_dist.c28to40/M waiting_dist.c40to52/M ...
    waiting_dist.c52to78/M waiting_dist.c78toM/M], 'stacked')
 %colormap('jet'); % doesn't seem to work
 legend('within 12 weeks','12-28 weeks','28-40','40-52','52-78', 'over 78 weeks')
 set (gca(),'FontSize',14)
 grid on
 xticks(waiting_dist.date(IS:2:length(waiting_dist.date)));
 xtickformat('MMM-yyyy')
 xtickangle(45)
 ylabel('Number of on-going waits in thousands')
 title('Number of on-going waits for outpatients')

subplot(2,1,2)


% let's compute total waits and percentage of waits within 12 weeks
waiting_dist.totalWaits = waiting_dist.c0to12 + waiting_dist.c12to28 + ...
                          waiting_dist.c28to40 + waiting_dist.c40to52 + ...
                          waiting_dist.c52to78 + waiting_dist.c78toM;
waiting_dist.PWithin12Weeks=(waiting_dist.c0to12./waiting_dist.totalWaits)*100;
waiting_dist.POver12Weeks=100-waiting_dist.PWithin12Weeks;

plot(waiting_dist.date,waiting_dist.POver12Weeks,'LineWidth',3);
set (gca(),'FontSize',14)
grid on
ylabel('percentage (%) of waits over 12 weeks')
xticks(waiting_dist.date(1:2:length(waiting_dist.date)));
 xtickformat('MMM-yyyy')
 xtickangle(45)
