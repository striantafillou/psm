function [pscores, matchedCaseInds, matchedControlInds, b] = psm_no_replacement(T, conf, varargin)
% Returns matched cases and controls by building a logistic model for T =
% logit(conf) and returns pscores, matched CaseInds and matchedControl
% inds.
fprintf('Greedy matching without replacement\n')

caliper= varargin{find(strcmp(varargin, 'caliper'))+1};

% find cases, controls
caseInds = find(T);nCases =length(caseInds);
controlInds = find(~T);nControls = length(controlInds);

% calculate p-scores
b = glmfit(conf, T, 'binomial');
pscores = glmval(b, conf, 'logit');

controlScores = pscores;
controlScores(caseInds)=inf;
matchedControlInds = nan(nCases, 1);
matchedCases = false(nCases, 1);
for iCase=1:nCases
    [matchedControlInds(iCase), cdist]= knnsearch(controlScores, pscores(caseInds(iCase)), 'dist', 'euclidean', 'k', 1);
    if cdist<caliper
%         matchedControlInds(iCase)=-1;
%     else
        matchedCases(iCase)=true;
    end        
    controlScores(matchedControlInds(iCase))=inf;
    
end
    

matchedCaseInds = caseInds(matchedCases);
matchedControlInds= matchedControlInds(matchedCases);
%figure;scatter(pscores(matchedControlInds), pscores(matchedCaseInds), '.');

end
% 


