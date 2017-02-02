function [pscores, matchedCaseInds, matchedControlInds, b] = psm_no_replacement_inter_subject(T, conf, varargin)
% Returns matched cases and controls by building a logistic model for T =
% logit(conf) and returns pscores, matched CaseInds and matchedControl
% inds.
fprintf('Greedy matching without replacement inter subject\n')

caliper= varargin{find(strcmp(varargin, 'caliper'))+1};
subjectIds = varargin{find(strcmp(varargin, 'subjectIds'))+1};
nConf=size(conf,2);

% calculate p-scores
% find cases, controls
caseInds = find(T);nCases =length(caseInds);
controlInds = find(~T);nControls = length(controlInds);

% calculate p-scores
b = glmfit(conf, T, 'binomial');
pscores = glmval(b, conf, 'logit');

scores = [pscores subjectIds];
controlScores = scores;
controlScores(caseInds)=inf;
matchedControlInds = nan(nCases, 1);
matchedCases = false(nCases, 1);
for iCase=1:nCases
    [matchedControlInds(iCase), cdist]= knnsearch(controlScores, scores(caseInds(iCase), :), 'dist', @psm_within_subject, 'k', 1);
    if cdist<caliper
%         matchedControlInds(iCase)=-1;
%     else
        matchedCases(iCase)=true;
    end        
    controlScores(matchedControlInds(iCase))=inf;
    
end
    

matchedCaseInds = caseInds(matchedCases);
matchedControlInds= matchedControlInds(matchedCases);
%figure;scatter(addnoise(pscores(matchedControlInds)), addnoise(pscores(matchedCaseInds)), '.');
%figure;scatter(addnoise(conf(matchedControlInds)), addnoise(conf(matchedCaseInds)), '.');
end
% 


function [dist] = psm_within_subject(x1, x2)
% takes as input a (2+1)x1 vector x1 and a (2+1)xN matrix x2 and returns the
% propensity score matching distances +\Delta subject weher
dist = (x1(:, 1) - x2(:, 1)).^2;
dist(x2(:, 2)~=x1(:, 2)) =inf;
end