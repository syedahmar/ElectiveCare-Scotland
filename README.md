## Summary
This is the associated repository for our paper entitled " Impact of COVID-19 pandemic on elective care backlog trends,recovery efforts, and capacity needs to address backlogs in Scotland (2013–2023): a descriptive analysis and modelling study" available at https://www.thelancet.com/journals/lanepe/article/PIIS2666-7762(24)00357-0/fulltext.

## Data
All the data files (except the Matlab format data) are available in the ‘data’ folder. All the original raw data is made available under the under the UK Open Government Licence (https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/). The original raw data downloaded from the Public Health Scotland’s “Stage of Treatment Waiting Times” are:
CompletedWaits_May2024.csv: data on capacity (i.e. cases that are dealt with)
OngoingWaits_May2024.csv: data on pending referrals (i.e. cases that are waiting for treatment)
AdditionsRemovals_May2024.csv: data on additions (i.e. demand) and removals (i.e. capacity)
Distribution_OngoingWaits_May2024.csv: time distribution of pending referrals
Distribution_CompletedWaits_May2024.csv: time distribution of cases dealt with

From these raw data, we derived several datasets using the “ProcessRawData.Rmd”. This allowed us to easily select/filter datasets when analysing them for various strata. We use the dplyr package, a convenient choice for filtering/selecting. We subsequently import this data into Matlab and save it as a Matlab data file (stored with the extension “.mat”). 

## Code Description
GetModelParameters_final.m: This file can be used to learn a new VARX model. You can select whether you want the data overall, or whether you want it stratified by elective type (inpatients; outpatients). We have already saved the optimal models learnt. These are ‘LearnedModel_AR14_Overall’,’ ‘LearnedModel_AR14_Inpatients’, and ‘LearnedModel_AR14_Outpatientspatients’.
HealthcareDisruption_Projections_Scotland_final.m: This is the main file that can be used to plot the existing pending referrals, load the learned model, make projections and then plot them. This file calls the Get_Projections.m file that has the code for iteratively computing the projections.
Plot_OngoingDistribution.m: This file extracts the time distribution of the pending cases and creates a two-panel plot where the upper panel shows the histogram of time distribution, and the lower panel shows the percentage of cases that have been waiting for over 12 weeks.
Plot_CompletedDistribution.m: This file extracts the time distribution of the completed cases and creates a two-panel plot where the upper panel shows the histogram of time distribution, and the lower panel shows the percentage of cases that were seen within 12 weeks.
Get_SummaryStatistics.m: This file extracts various summary statistics for the years of interest (2013, 2019 and 2023).
GetCI_Adjust_Seasonality.R: This file written in R is used to correctly compute the 95% confidence interval for quarterly means.
