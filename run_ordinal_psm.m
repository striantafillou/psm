clear;close all;
load('features', 'allExtendedFeatures*');load subjects;
addpath('psm_functions');
% remove nans
[nanRows,~] = find(isnan(allExtendedFeatures{:, :}));allExtendedFeatures(nanRows, :)= []; 
[nanRowsNorm, ~] = find(isnan(allExtendedFeaturesNorm{:, :})); allExtendedFeaturesNorm(nanRowsNorm, :)= [];
% % Effect of sleep_quality on mood;
fprintf('Removing %d rows with nan values\n', length(unique(nanRows)));

graph =true;
figDir = 'figs';
treatment_var = 'sleep_quality';
outcome_var = 'mood';
list_of_conf = { 'sleep_duration', 'prev_stress', 'prev_energy', 'prev_focus', 'prev_mood','prev_activity',  'day_type', 'prev_day_type'};
% 

% Effect of prev_mood on sleep_quality;
%  treatment_var = 'prev_mood';
%  outcome_var = 'sleep_quality';
%  list_of_conf = { 'prev_day_type', 'prev_activity', 'prev_sleep_duration', 'prev_sleep_quality'};
% % 
fprintf('-------------------------------------------------------------\n');
fprintf('Effect of %s on %s given\n', treatment_var, outcome_var);
fprintf('\t%s\n', list_of_conf{:});
fprintf('\n-------------------------------------------------------------\n');

fprintf('On all subjects, %d samples\n',height(allExtendedFeatures));


[matching(1)] = ...
        ordinal_psm_causal_effects(allExtendedFeatures, treatment_var, outcome_var, list_of_conf, graph, 'ordinal_psm_no_replacement_inter_subject', 'caliper', 0.2, 'subjectIds', allExtendedFeatures.subject);
%[matching(2)] = ...
 %       psm_causal_effects(allExtendedFeatures, treatment_var, outcome_var, list_of_conf, graph, 'psm_no_replacement', 'caliper',0.2);