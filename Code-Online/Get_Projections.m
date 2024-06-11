%% Let's collect all variables and use x for exogenous variables and y for the response variable
if(convertCharsToStrings(CaseType)=='Inpatient/Day case')
    load LearnedModel_AR14_Inpatients;
end

if(convertCharsToStrings(CaseType)=='New Outpatient')
    load LearnedModel_AR14_Outpatients;
end

if(convertCharsToStrings(CaseType)=='Overall')
    load LearnedModel_AR14_Overall;
end

phi_1=EstMdl.AR{1}; % AR(1) part component;
phi_4=EstMdl.AR{4}; % AR(4) part component
beta_demand = EstMdl.Beta(2);
beta_treated = EstMdl.Beta(1);
model_constant = EstMdl.Constant;
error_std =  sqrt(EstMdl.Covariance);
error_term = randn(length(y_treated)+4,1).*sqrt(EstMdl.Covariance);

% Quarterly Demand (overall)
x_demand = [Additions.Additions(end-3:end); y_demand_future]; % from n = 1 to n = 16 (n=1:4 corresponds to pre-projections period)
% Quarterly Treated (Capacity)
x_treated = [Additions.Removals(end-3:end);  y_treated]; % from n=1 to n=16 (n=1:4 corresponds to pre-proejctions period)


for n=1:(length(x_future_index))
    
    y_waiting(n+4,1) = phi_1*y_waiting(n+3)+beta_demand*x_demand(n+4)+...
    beta_treated*x_treated(n+4) +model_constant + phi_4*y_waiting(n)+error_term(n+4);
end