function [pscores,matchedCaseInds, matchedControlInds, b] = psm_bipartite_weighted_matching(T, conf, varargin)
    fprintf('Weighted bipartite matching\n');
    caseInds= find(T);nCases=length(caseInds);
    controlInds = find(~T);nControls = length(controlInds);
    caliper= varargin{find(strcmp(varargin, 'caliper'))+1};

    % calculate p-scores
    b = glmfit(conf, T, 'binomial');
    pscores = glmval(b, conf, 'logit');

    %Make weighted matrix for bipartite matching.
    wmat = nan(nCases*nControls, 3);
    for iCase=1:nCases
        wmat((iCase-1)*nControls+1:iCase*nControls, :) = [repmat(caseInds(iCase), nControls, 1) controlInds -abs(pscores(caseInds(iCase))- pscores(controlInds))];
    end

    % Remove distances greater than caliper.
    %caliper =-0.2;
    wmat(wmat(1:end-1, 3)<caliper, :)=[];
   

    tic;
    out= maxWeightMatching(wmat, true);
     if wmat(end, 3)<caliper
        out(end)=-1;
    end
    t=toc;
    fprintf('Finished weighted matching in %.3f seconds\n', t);


    matchedControlInds = out(caseInds);
    matchedCases= matchedControlInds>0;
    matchedControlInds= matchedControlInds(matchedCases);
    matchedCaseInds=caseInds(matchedCases);

    scatter(pscores(matchedControlInds), pscores(matchedCaseInds));
end