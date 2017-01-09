function [pscores, matchedCaseInds, matchedControlInds] = psm(T, conf)
% Returns matched cases and controls by building a logistic model for T =
% logit(conf) and returns pscores, matched CaseInds and matchedControl
% inds.

% find cases, controls
matchedCaseInds = find(T);
matchedControlInds = find(~T);

if ~isempty(conf);
    % calculate p-scores
    b = glmfit(conf, T, 'binomial');
    pscores = glmval(b, conf, 'logit');
    
    % differences in case-control scores
    ctrScores = pscores; ctrScores(matchedCaseInds)=inf;
    matchedControlInds = knnsearch(ctrScores, pscores(matchedCaseInds),'dist','cityblock','k',1);%

%      ctrlConf = conf(ctrlInds, :);
%      [tmpInds, matchedScores] = knnsearch(ctrlConf, conf(caseInds, :),'dist','cityblock','k',1);
%      matchedControlInds= ctrlInds(tmpInds);

%     %compute matched differences
%     Y_control = Y(matchedControlInds);
%     Y_case = Y(caseInds);
%     ate = mean(Y_case-Y_control);
%    % figure;histogram(Y_case-Y_control);xlabel('Mood(case)-Mood(control)')
%     [~, pval] = ttest(Y_control, Y_case);
end

