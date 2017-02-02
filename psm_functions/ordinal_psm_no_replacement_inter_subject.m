function [pscores, matchedCaseInds, matchedControlInds, b] = ordinal_psm_no_replacement_inter_subject(treatment, conf, varargin)
% Returns matched cases and controls by building a logistic model for T =
% logit(conf) and returns pscores, matched CaseInds and matchedControl
% inds.
fprintf('Greedy matching without replacement inter subject\n')

caliper= varargin{find(strcmp(varargin, 'caliper'))+1};
subjectIds = varargin{find(strcmp(varargin, 'subjectIds'))+1};

nConf=size(conf,2);
% calculate p-scores
b = mnrfit(conf, treatment, 'model', 'ordinal');
pscores = conf*b(end-nConf+1:end);

matchedControlInds = [];
matchedCaseInds = [];
distances =[];
scores = [pscores treatment subjectIds];
nSamples= length(treatment);

matched = false(nSamples, 1); 

for iSample=1:nSamples    
    if ~any(~matched)
        fprintf('all have been matched or visited\n');
        break;
    end
    if matched(iSample)
        continue;
    end
    tmpScores=scores;
    tmpScores(matched, :)=nan;
    tmpScores(iSample, :)=nan;
    %[curDist, curMatch] = min(ordinal_psm_dist(scores(iSample, :), tmpScores));
    [curDist, curMatch] = min(ordinal_psm_dist_inter_subject(scores(iSample, :), tmpScores));
    
    if curDist>caliper
        continue;
    end
    if scores(curMatch, 2)<scores(iSample, 2);
        matchedControlInds =[matchedControlInds;curMatch];
        matchedCaseInds=[matchedCaseInds;iSample];
    else
        matchedControlInds =[matchedControlInds;iSample];
        matchedCaseInds=[matchedCaseInds;curMatch];
    end
    distances =[distances; curDist];
    matched([iSample curMatch])=true;
    fprintf('Sample %d matched with %d\n',iSample, curMatch);

end
    

figure;scatter(pscores(matchedControlInds), pscores(matchedCaseInds), '.');

end


function [dist] = ordinal_psm_dist(x1,x2)
% takes as input a (2+1)x1 vector x1 and a (2+1)xN matrix x2 and returns the
% propensity score matching distances proposed in Lu et al, 2001.
% first column is psm, second column is treatment.

dist = ((x1(1)-x2(:, 1)).^2)./((x1(2)-x2(:, 2)).^2);
end

function [dist] = ordinal_psm_dist_inter_subject(x1, x2)
tmp = zeros(length(x2),1);
tmp(x1(3)~=x2(:, 3))=inf;
dist = ((x1(1)-x2(:, 1)).^2)./((x1(2)-x2(:, 2)).^2) +tmp;
end

