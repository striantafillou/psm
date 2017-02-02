
clear;close all;
load('features', 'allExtendedFeatures*');load subjects;
addpath('psm_functions');
% remove nans
[nanRows,~] = find(isnan(allExtendedFeatures{:, :}));allExtendedFeatures(nanRows, :)= [];
fprintf('Removing %d rows with nan values\n', length(unique(nanRows)));

[nanRowsNorm, ~] = find(isnan(allExtendedFeaturesNorm{:, :}));allExtendedFeaturesNorm(nanRowsNorm, :)= [];
fprintf('Removing %d rows with nan values\n', length(unique(nanRowsNorm)));

clinVars = {'Age', 'gender', 'marital_status',  'education',  'score_PHQ',    'score_AUDIT',    'score_DAST',   'isControl' ,   'isAnxious',    'isDepressed',    'isDepressedAnxious',  ...
    'w3_phq8', 'w3_psq_sleep_duration', 'w6_phq8', 'w6_psq_sleep_duration'};
clinData= nan(height(allExtendedFeatures), length(clinVars));

for iSubject =1:length(subjects)
    subjSamples =  find(allExtendedFeatures.subject==iSubject);
    nSamples = length(subjSamples);
    if nSamples>0
       clinData(subjSamples, :) = repmat(subjectInfo{iSubject, clinVars}, nSamples, 1);
    end
end
    

clinTable= array2table(clinData);clinTable.Properties.VariableNames = clinVars;

% Effect of prev_mood on sleep_quality;
 treatment_var = 'prev_mood';
 outcome_var = 'sleep_quality';
 list_of_conf = { 'prev_sleep_duration','prev_activity', 'prev_day_type',  'Age', 'gender', 'marital_status',  'education',   'score_AUDIT',    'score_DAST'};
% 
fprintf('-------------------------------------------------------------\n');
fprintf('Effect of %s on %s given\n', treatment_var, outcome_var);
fprintf('\t%s\n', list_of_conf{:});
fprintf('\n-------------------------------------------------------------\n');

fprintf('On all subjects, %d samples\n',height(allExtendedFeatures));
allExtendedFeaturesPlusClin = [allExtendedFeatures clinTable];

[ate, cd, pval, ate_um, cd_um, pval_um, parcor, cor] = ...
        psm_causal_effects(allExtendedFeaturesPlusClin, treatment_var, outcome_var, list_of_conf, true, 'psm_no_replacement', 'caliper',0.2);
