function [pscores, matchedCaseInds, matchedControlInds] = psm_within_subject(T, conf, subj)
% Returns matched cases and controls by building a logistic model for T =
% logit(conf) and returns pscores, matched CaseInds and matchedControl
% inds within subject

% find cases, controls
matchedCaseInds = find(T);
matchedControlInds = find(~T);

    if ~isempty(conf);
    
        % calculate p-scores
        b = glmfit(conf, T, 'binomial');
        pscores = glmval(b, conf, 'logit');

        % differences in case-control scores
        ctrScores = pscores; 
        ctrScores(matchedCaseInds)=inf;
        ctrScores = [ctrScores subj];
        matchedControlInds = knnsearch(ctrScores, [pscores(matchedCaseInds) subj(matchedCaseInds)],'dist','@psm_within_subject','k',1);%
        %matchedControlInds =knnsearch(ctrScores, pscores(matchedCaseInds), 'dist', @psm_within_subject,'k',1)
    end
end

function [dist] = ordinal_psm_dist(x1,x2)
% takes as input a (2+1)x1 vector x1 and a (2+1)xN matrix x2 and returns the
% propensity score matching distances proposed in Lu et al, 2001.
% first column is psm, second column is treatment.

dist = ((x1(1)-x2(:, 1)).^2)./(x1(2)-x2(:, 2).^2);
end