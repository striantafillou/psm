%'subject'    'dates'    'date_ids'    'sleep_duration'    'sleep_quality'    'day_type'    'activity'    'stress'   'mood'    'energy'    'focus'

load features;
outcome_var = 'mood';
treatment_var = 'sleep_quality';
fprintf('Effect of %s ', treatment_var)

list_of_conf = {'sleep_duration', 'stress', 'energy', 'focus', 'activity', 'mood'};

fprintf(' on %s\n', sprintf('%s, ',list_of_conf{:}));
%list_of_conf= {'mood'};
prev_conf = true(length(list_of_conf));
prev_conf(1)=false;


figure(1)
plotcorrmatrix([treatment, outcome, conf] , {treatment_var, outcome_var, list_of_conf{:}});%'Energy','Focus', 'Mood','Stress','SlDur', 'SlQual'});

[treatment, outcome, conf] = psm_data(features, treatment_var, outcome_var, list_of_conf, prev_conf);

[nanRows, ~] = find(isnan([treatment outcome conf]));

%fprintf('Removing %d nan rows\n', length(unique(nanRows)));
treatment(nanRows) =[];
outcome(nanRows) =[];
conf(nanRows, :) =[];

figure(1)
plotcorrmatrix([treatment, outcome, conf] , {treatment_var, outcome_var, list_of_conf{:}});%'Energy','Focus', 'Mood','Stress','SlDur', 'SlQual'});

% create dichotomous treatment 
T=treatment>(max(treatment)-min(treatment))/2;

% estimate propensity scores and do matching
[pscores, matchedCaseInds, matchedControlInds] = psm(T, conf);
% figure(11);
% scatter(pscores(matchedCaseInds), pscores(matchedControlInds), '.')

% Plot standardized differences for matched and unmatched samples
fh = figure;
[nSamples, nCovs] = size(conf);
cases = conf(matchedCaseInds, :);
unmatchedControls = conf(setdiff(1:nSamples, matchedCaseInds), :);
matchedControls = conf(matchedControlInds, :);

d_unmatched = standardized_difference(cases, unmatchedControls);
d_matched = standardized_difference(cases, matchedControls);

figure;h = gca;
scatter(d_unmatched, 1:nCovs); hold on;
scatter(d_matched, 1:nCovs); hold on;
plot([0.1 0.1], get(gca, 'ylim'));
h.YTick = 1:nCovs;
h.YTickLabel = list_of_conf;
title('Standardized differences for covariates')
%%


% compute matched differences
Y_control = outcome(matchedControlInds);
Y_case = outcome(matchedCaseInds);
ate = nanmean(Y_case-Y_control);
figure;histogram(Y_case-Y_control);xlabel('Mood(case)-Mood(control)')
[~, pval] = ttest2(Y_control, Y_case);



fprintf('ATE: %.3f, pval:%.3f\n', ate, pval);