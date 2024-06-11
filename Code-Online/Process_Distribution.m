function output=Process_Distribution(waiting_dist)

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
    
    % let's compute total waits and percentage of waits within 12 weeks
    waiting_dist.totalWaits = waiting_dist.c0to12 + waiting_dist.c12to28 + ...
                          waiting_dist.c28to40 + waiting_dist.c40to52 + ...
                          waiting_dist.c52to78 + waiting_dist.c78toM;
    waiting_dist.PWithin12Weeks=(waiting_dist.c0to12./waiting_dist.totalWaits)*100;
    waiting_dist.POver12Weeks=100-waiting_dist.PWithin12Weeks;
    waiting_dist.POver52Weeks=((waiting_dist.c52to78+waiting_dist.c78toM)./waiting_dist.totalWaits).*100;
    % return the processed waiting_dist
    output = waiting_dist;
 end