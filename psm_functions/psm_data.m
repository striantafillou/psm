function [treatment, outcome, conf] = psm_data(features, treatment_var, outcome_var, list_of_conf, prev_conf)


nSubjects = size(features, 1);
treatment = [];
outcome = [];
conf =[];
nConf = length(list_of_conf);

if size(prev_conf, 1)~= nConf;
    fprintf('times for confounders are not consistent with confounders\n');
end

ind = 0;
for iSub =1:nSubjects
    
    curFeatures = features{iSub};
    if isempty(curFeatures);continue;end
    nSamples = height(curFeatures);
   
    
    % treatment (always one timepoint before outcome)
    treatment(ind+1:ind+nSamples, 1) = curFeatures{:, treatment_var};
    
    % outcome (always current timepoint)
    outcome(ind+1:ind+nSamples, 1) = curFeatures{:, outcome_var};
    
    conf(ind+1:ind+nSamples, :) = curFeatures{:, list_of_conf};    % confounders
  
    ind= ind+nSamples;
end
    

           






             
    