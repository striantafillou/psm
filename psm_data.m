function [treatment, outcome, conf] = psm_data(features, treatment_var, outcome_var, list_of_conf, prev_conf)


nSubjects = size(features, 1);
treatment = [];
outcome = [];
nConf = length(list_of_conf);

if size(prev_conf, 1)~= nConf;
    fprintf('times for confounders are not consistent with confounders\n');
end

ind = 0;
for iSub =1:nSubjects
    
    curFeatures = features{iSub};
    if isempty(curFeatures);continue;end
    nSamples = height(curFeatures);
    prevInds =1:nSamples-1;
    curInds = 2:nSamples;
    effSamples = nSamples-1; % samples used
    
    % treatment (always one timepoint before outcome)
    treatment(ind+1:ind+effSamples, 1) = curFeatures{prevInds, treatment_var};
    
    % outcome (always current timepoint)
    outcome(ind+1:ind+effSamples, 1) = curFeatures{curInds, outcome_var};
    
    % confounders
    for iConf=1:nConf
         if prev_conf(iConf)
             conf(ind+1:ind+effSamples, iConf) = curFeatures{prevInds, list_of_conf{iConf}};
         else
             conf(ind+1:ind+effSamples, iConf) = curFeatures{curInds, list_of_conf{iConf}};
         end
    end
    ind= ind+effSamples;
end
    

           






             
    