%'subject'    'dates'    'date_ids'    'sleep_duration'    'sleep_quality'    'day_type'    'activity'    'stress'   'mood'    'energy'    'focus'

load features;
outcome_var = 'mood';
treatment_var = 'sleep_quality';

list_of_conf = {'sleep_duration', 'mood'};
prev_conf = true(length(list_of_conf));
prev_conf(1)=false;



[treatment, outcome, conf] = psm_data(features, treatment_var, outcome_var, list_of_conf, prev_conf);

[nanRows, ~] = find(isnan([treatment outcome conf]));

fprintf('Removing %d nan rows\n', length(unique(nanRows)));
treatment(nanRows) =[];
outcome(nanRows) =[];
conf(nanRows, :) =[];

figure(1)
plotcorrmatrix([treatment, outcome, conf] , {treatment_var, outcome_var, list_of_conf{:}});%'Energy','Focus', 'Mood','Stress','SlDur', 'SlQual'});

% create dichotomous treatment 
T=treatment>4;

% estimate propensity scores and do matching
[pscores, matchedCaseInds, matchedControlInds] = psm(T, conf);
figure(11);
scatter(pscores(matchedCaseInds), pscores(matchedControlInds), '.')
% MISSING: Estimate covariance balance in matched samples.

% compute matched differences
Y_control = outcome(matchedControlInds);
Y_case = outcome(matchedCaseInds);
ate = nanmean(Y_case-Y_control);
figure;histogram(Y_case-Y_control);xlabel('Mood(case)-Mood(control)')
[~, pval] = ttest2(Y_control, Y_case);



fprintf('ATE: %.3f, pval:%.3f\n', ate, pval);