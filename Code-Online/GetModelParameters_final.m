%% Description
% Author: Syed Ahmar Shah
% ahmar.shah@ed.ac.uk
% updated for Scottish Data
% This script can be used to find the paramaters of the autoregressive
% model that will then be used for the projections for the healthcare
% disruption work
%updated on 4 June 2024
%% clear workspace and load data
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

%% Let us resample waiting data to make it quaterly, and collect all the data
% resample
ID=3:3:138;
Waiting_sel = Waiting(ID,:);

% collect all data in a variable called data
IS=2:45; % this will allow data from January 1 2013 to December 31, 2023 to be used
data.Waiting = Waiting_sel.NumberWaiting(IS);
data.Capacity = Additions.Removals(IS);
data.Demand = Additions.Additions(IS);
%% create a full model (Model_F) 
Mdl_F = varm(1,4); % one time-series, all AR terms up to lag of 4 (lag 4 corresponds to account for any seasonal effect)
Mdl_F.Constant=NaN; 
Mdl_F.Trend=0;
Mdl_F.Beta=[NaN NaN];
% instantiate a model with only 1-6 and 12th lag terms
Mdl_F.AR(2:4)={0}; % this step ensures that AR(2:3) are excluded
[Mdl_F_Est Mdl_F_SE Mdl_F_LogL, Mdl_F_E] = estimate(Mdl_F,data.Waiting,X=[data.Capacity data.Demand]);
sqrt(Mdl_F_Est.Covariance)
summarize(Mdl_F_Est)
%std(Mdl_F_E)

% save the model (uncomment the following lines if you need to generate a
% new model
EstMdl = Mdl_F_Est;
%save LearnedModel_AR14_Overall EstMdl