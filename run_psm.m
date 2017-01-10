clear;close all;
load('features', 'extendedFeatures');load subjects;
outcome_var = 'mood';
treatment_var = 'sleep_quality';
depressed=false;

fprintf('-------------------------------------------------------------\n');
if depressed    
    extendedFeatures(~depressedSubjects) =[];
    fprintf('On depressed subjects\n');
else
    fprintf('On all subjects\n');
end
fprintf('Effect of %s on %s given\n', treatment_var, outcome_var);



list_of_conf = {'sleep_duration', 'prev_stress', 'prev_energy', 'prev_focus', 'prev_mood'};

fprintf('\t  %s %s\n', sprintf('%s, ',list_of_conf{1:end-1}), list_of_conf{end});
%list_of_conf= {'mood'};
prev_conf = false(length(list_of_conf));


[treatment, outcome, conf] = psm_data_extended(extendedFeatures, treatment_var, outcome_var, list_of_conf, prev_conf);

[nanRows, ~] = find(isnan([treatment outcome conf]));

%fprintf('Removing %d nan rows\n', length(unique(nanRows)));
treatment(nanRows) =[];
outcome(nanRows) =[];
conf(nanRows, :) =[];

figure;
plotcorrmatrix([treatment, outcome, conf] , {treatment_var, outcome_var, list_of_conf{:}});%'Energy','Focus', 'Mood','Stress','SlDur', 'SlQual'});

% create dichotomous treatment 
T=treatment>(max(treatment)-min(treatment))/2;

% estimate propensity scores and do matching
[pscores, matchedCaseInds, matchedControlInds] = psm(T, conf);
% figure(11);
% scatter(pscores(matchedCaseInds), pscores(matchedControlInds), '.')

% Plot standardized differences for matched and unmatched samples
[nSamples, nCovs] = size(conf);
cases = conf(matchedCaseInds, :);
unmatchedControls = conf(setdiff(1:nSamples, matchedCaseInds), :);
matchedControls = conf(matchedControlInds, :);

d_unmatched = standardized_difference(cases, unmatchedControls);
d_matched = standardized_difference(cases, matchedControls);

figure;h = gca;
scatter(abs(d_unmatched), 1:nCovs); hold on;
scatter(abs(d_matched), 1:nCovs); hold on;
plot([0.1 0.1], get(gca, 'ylim'));
h.YTick = 1:nCovs;
h.YTickLabel = list_of_conf;h.TickLabelInterpreter ='none';
legend('unmatched', 'matched');
title('Standardized differences for covariates')%

% compute unmatched differences
Y_control_um = outcome(setdiff(1:nSamples, matchedCaseInds));
Y_case = outcome(matchedCaseInds);
ate_um = nanmean(Y_case)-nanmean(Y_control_um);
cd_um = cohend(Y_case, Y_control_um);
[~, pval_um] = ttest2(Y_control_um, Y_case);
fprintf('UNMATCHED ATE: %.3f, CE: %.3f  pval:%.3f\n', ate_um, cd_um,  pval_um);


% compute matched differences
Y_control = outcome(matchedControlInds);
Y_case = outcome(matchedCaseInds);
ate = nanmean(Y_case)-nanmean(Y_control);
cd = cohend(Y_case, Y_control);

% plot matched differences
[yc,xc]= ksdensity(Y_case); [yct,xct]= ksdensity(Y_control); [yuct,xuct] = ksdensity(Y_control_um);
figure;hold all;
plot(xuct, yuct, 'g');plot(xct, yct, 'b');plot(xc, yc, 'r');
plot([mean(Y_case) mean(Y_case)], get(gca, 'ylim'), 'r');plot([mean(Y_control) mean(Y_control)], get(gca, 'ylim'), 'b');plot([mean(Y_control_um) mean(Y_control_um)], get(gca, 'ylim'), 'g');
legend({'unmatched controls', 'matched controls', 'cases'}, 'location', 'NorthWest');
[~, pval] = ttest2(Y_control, Y_case);

fprintf('MATCHED ATE: %.3f, CE: %.3f  pval:%.3f\n', ate, cd,  pval);

% 
% 
% figure
% corr_dur_qual = nan(208, 1);
% all_sleep= [];
% for i=1:nSubjects
%     tmp = features{i};if isempty(tmp);continue;end
%     hold on;
%     scatter(tmp{:, 'sleep_quality'}, tmp{:, 'sleep_duration'}, '.');
%     all_sleep = [all_sleep;tmp{:, {'sleep_quality', 'sleep_duration'}}];
%     xlabel('sleep_quality');
%     ylabel('sleep_duration');
%     title(['subject ' num2str(i)]);
%     corr_dur_qual(i) = corr(tmp{:, 'sleep_quality'}, tmp{:, 'sleep_duration'}, 'rows', 'pairwise');
% end
