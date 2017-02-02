clear;close all;
load('features', 'extendedFeatures', 'allExtendedFeatures*');load subjects;

fig_dir = 'figs';
if ~isdir(fig_dir);mkdir(fig_dir);end

nSubjects = length(subjects);
% Marginal correlation of sleep_quality on mood.
treatment_var = 'prev_mood';
outcome_var = 'mood';

figure;hold on;
[marg_corr, nSamples]= deal(nan(nSubjects, 1));
for iSubject=1:nSubjects
    if isempty(extendedFeatures{iSubject});continue;end
    scatter(addnoise(extendedFeatures{iSubject}{:, treatment_var}), addnoise(extendedFeatures{iSubject}{:, outcome_var}), '.');
    marg_corr(iSubject) = corr(extendedFeatures{iSubject}{:, treatment_var}, extendedFeatures{iSubject}{:, outcome_var}, 'rows', 'pairwise', 'type', 'spearman');
    nSamples(iSubject)= height(extendedFeatures{iSubject});
end
xlabel(treatment_var, 'interpreter', 'none'); ylabel(outcome_var, 'interpreter', 'none');
fName = [fig_dir filesep treatment_var '_' outcome_var '_scatter'];
saveas(gcf, fName, 'png')



figure;h=gca;hold on;
histogram(marg_corr, 20);
hp1  =plot([nanmean(marg_corr) ,nanmean(marg_corr)], h.YLim, 'LineWidth', 2);
pooledCorr = corr(allExtendedFeatures{:, treatment_var}, allExtendedFeatures{:, outcome_var}, 'rows', 'pairwise', 'type', 'spearman');
hp2 =plot([pooledCorr pooledCorr], h.YLim, 'LineWidth', 2);
normCorr = corr(allExtendedFeaturesNorm{:, treatment_var}, allExtendedFeaturesNorm{:, outcome_var}, 'rows', 'pairwise');
hp3 =plot([normCorr normCorr], h.YLim, 'LineWidth', 2, 'LineStyle', '-.');
h.XLim =[-1 1];
xlabel(['Correlation(' treatment_var, ', ' outcome_var ')'], 'interpreter', 'none');
legend([hp1, hp2, hp3], {'mean', 'pooled', 'normalized'}, 'Location', 'NorthWest');

fName = [fig_dir filesep treatment_var '_' outcome_var '_corr'];
saveas(gcf,fName, 'png')
