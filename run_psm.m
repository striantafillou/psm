%
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
list_of_conf = { 'sleep_duration', 'prev_mood', 'prev_stress', 'prev_energy', 'prev_focus', 'prev_activity', 'prev_day_type'};


% Effect of prev_mood on sleep_quality;
%  treatment_var = 'prev_mood';
%  outcome_var = 'sleep_quality';
%  list_of_conf = { 'prev_day_type', 'prev_activity'};

fprintf('-------------------------------------------------------------\n');
fprintf('Effect of %s on %s given\n', treatment_var, outcome_var);
fprintf('\t%s\n', list_of_conf{:});
fprintf('\n-------------------------------------------------------------\n');

fprintf('On all subjects, %d samples\n',height(allExtendedFeatures));


[matching(1)] = ...
        psm_causal_effects(allExtendedFeatures, treatment_var, outcome_var, list_of_conf, graph, 'psm_no_replacement_inter_subject', 'caliper', 0.2, 'subjectIds', allExtendedFeatures.subject);
[matching(2)] = ...
        psm_causal_effects(allExtendedFeatures, treatment_var, outcome_var, list_of_conf, graph, 'psm_no_replacement', 'caliper',0.2);

%     
fprintf('NORMALIZED\n');
[matching(3)] = ...
        psm_causal_effects(allExtendedFeaturesNorm, treatment_var, outcome_var, list_of_conf, graph, 'psm_no_replacement_inter_subject', 'caliper', 0.2, 'subjectIds', allExtendedFeaturesNorm.subject);
[matching(4)] = ...
        psm_causal_effects(allExtendedFeaturesNorm, treatment_var, outcome_var, list_of_conf, graph, 'psm_no_replacement', 'caliper',0.2);

%
fName = [figDir filesep treatment_var '2' outcome_var];
figure; ah =gca;
scatter(1:4, [matching(:).cd], 'MarkerFaceColor', 'black', 'MarkerEdgeColor', 'black');hold all;
scatter(1:4, [matching(:).cd_um], 'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'black');
legend({'matched', 'unmatched'});
ylabel('Cohen d'); 
xlim([0 5]);ylim([min([0, min([matching.cd])-0.1]), 1])
ah.XTick = [0:5];
ah.XTickLabel ={' ', 'inter-subject', 'pooled', 'inter-subject normalized', 'pooled normalized', ' '};
ah.XTickLabelRotation =30;
ah.TickLabelInterpreter='none';

title({['Effect of ' treatment_var ' on ' outcome_var ' matched on ']; [sprintf('%s, ',list_of_conf{1:end-1}), sprintf('%s', list_of_conf{end})]}, 'interpreter', 'none');
saveas(gcf, fName, 'png');

%%


%%

clear;close all;
load('features', 'extendedFeatures', 'allExtendedFeatures*');load subjects;
addpath('MaxWeightMatching\')
% remove nans
for iSubject=1:length(subjects)
    if isempty(extendedFeatures{iSubject});continue;
    end
    [nanRows, ~] = find(isnan(extendedFeatures{iSubject}{:, :}));
    fprintf('Removing %d rows with nan values\n', length(nanRows));
    extendedFeatures{iSubject}(nanRows, :)= [];
end

 % Effect of prev_mood on sleep_quality;
%  treatment_var = 'prev_mood';
%  outcome_var = 'sleep_quality';
%  list_of_conf = { 'prev_sleep_duration','prev_activity', 'prev_day_type', 'prev_sleep_quality'};
 
treatment_var = 'sleep_quality';
outcome_var = 'mood';
list_of_conf = { 'sleep_duration', 'prev_stress', 'prev_energy', 'prev_focus', 'prev_mood','prev_activity', 'activity', 'day_type', 'prev_day_type'};
extendedFeatures(depressedSubjects) = [];


fprintf('-------------------------------------------------------------\n');
fprintf('Effect of %s on %s given\n', treatment_var, outcome_var);
fprintf('\t%s\n', list_of_conf{:});
fprintf('\n-------------------------------------------------------------\n');

nSamples = zeros(length(subjects), 1);
fprintf('On all subjects\n');
for iSubject=1:length(subjects)
    if isempty(extendedFeatures{iSubject});continue;end
    fprintf('\n*****************Subject %d************\n', iSubject);
    nSamples(iSubject) = height(extendedFeatures{iSubject}); if nSamples(iSubject)<20;continue;end
    [ate(iSubject), cd(iSubject), pval(iSubject), ate_um(iSubject), cd_um(iSubject), pval_um(iSubject), parcor(iSubject), cor(iSubject)] = ...
        psm_causal_effects(extendedFeatures{iSubject}, treatment_var, outcome_var, list_of_conf, false);
end
%%


