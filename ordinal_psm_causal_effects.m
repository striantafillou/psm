function [matching] = ordinal_psm_causal_effects(features, treatment_var, outcome_var, list_of_conf, graph, scorefun, varargin)
% estimate matched and unmatched causal effect of treatment_var on
% outcome_var by propensity score matching on list_of_conf.

treatment = features{:, treatment_var}; 
outcome = features{:, outcome_var};
conf= features{:, list_of_conf};
nConf= length(list_of_conf);
if graph
    figure;
    scatter(1:nConf, corr(treatment, conf, 'type', 'kendall'), 'MarkerFaceColor', 'black', 'MarkerEdgeColor', 'black');hold all;
    ylabel('kendall''s \tau');
    set(gca, 'TickLabelInterpreter' , 'none',  'xtick', 1:nConf, 'xticklabel', list_of_conf, 'XTickLabelRotation', 60);xlim([0 nConf+1]);ylim([-1 1]);
    title(['Covariates before matching and rank correlation with ' treatment_var], 'interpreter', 'none');
end

[pscores,matchedCaseInds, matchedControlInds, b] = feval(scorefun, floor(treatment)+1, conf, varargin{:});
% plot covariate means and stds in cases vs contrls
if false
    f =figure;
    confMeans = [mean(conf);mean(conf(matchedControlInds, :)); mean(conf(matchedCaseInds, :))]; 
    confStds = [std(conf);std(conf(matchedControlInds, :)); std(conf(matchedCaseInds, :))];
   	rowNames = list_of_conf;
    colNames = {'All', [treatment_var ' low'], [treatment_var ' high']};
    uicontrol('Parent', f, 'Style', 'text', 'String', 'Balance of covariates in treated and untreated units', 'Units', 'Normalized', 'Position', [0.0339 0.0452 0.9 0.9]);
    t = uitable('Units','normalized','Position',...
            [0.05 0.0 .755 0.87], 'Data', confMeans', 'columnName', colNames, 'rowName', rowNames);
end

fprintf('%d and  controls used for %d cases\n', length(unique(matchedControlInds)));
% Plot standardized differences for matched and unmatched samples
[nSamples, nCovs] = size(conf);
cases = conf(matchedCaseInds, :);
unmatchedControls = conf(setdiff(1:nSamples, matchedCaseInds), :);
matchedControls = conf(matchedControlInds, :);

d_unmatched = standardized_difference(cases, unmatchedControls);
d_matched = standardized_difference(cases, matchedControls);

if graph
    figure;h = gca;
    scatter(abs(d_unmatched), 1:nCovs); hold on;
    scatter(abs(d_matched), 1:nCovs); hold on;
    plot([0.1 0.1], get(gca, 'ylim'));
    h.YTick = 1:nCovs;
    h.YTickLabel = list_of_conf;h.TickLabelInterpreter ='none';
    legend('unmatched', 'matched');
    title('Standardized differences for covariates')%
end

% % compute unmatched differences
% Y_control_um = outcome(controlInds);
% Y_case_um = outcome(caseInds);
% ate_um = nanmean(Y_case_um)-nanmean(Y_control_um);
% cd_um = cohend(Y_case_um, Y_control_um);
% [~, pval_um] = ttest2(Y_control_um, Y_case_um);
% cor = corr(treatment, outcome);
% fprintf('UNMATCHED ATE: %.3f, CE: %.3f  PVAL:%.3f, CORR %.3f\n', ate_um, cd_um,  pval_um, cor);


% compute matched differences
Y_control = outcome(matchedControlInds);
Y_case = outcome(matchedCaseInds);
ate = nanmean(Y_case)-nanmean(Y_control);
cd = cohend(Y_case, Y_control);
[~, pval] = ttest2(Y_control, Y_case);

cor = corr(treatment, outcome, 'rows', 'pairwise');
parcor  = partialcorr(treatment,outcome, conf, 'rows','pairwise'); 
fprintf('MATCHED ATE:   %.3f, CE: %.3f  PVAL:%.3f, PARCORR %.3f\n', ate, cd,  pval, parcor);

matching.ate =ate;
matching.cd = cd;
matching.nmControls = length(matchedControlInds);
matching.nmCases = length(matchedCaseInds);
matching.pcor = parcor;
matching.cor = cor;
matching.psmethod = scorefun;
end

