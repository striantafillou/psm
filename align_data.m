clear;
clc;
load sleep;load affect;load act;

load subjects; nSubjects= length(subjects);

features = cell(nSubjects, 1);

for i=1:nSubjects
    nSleep = height(sleep{i}); nAct = height(act{i});nAffect =height(affect{i});
    if nSleep==0 || nAct==0||nAffect==0;
        features{i} =[];
        fprintf('some of the features missing for subject %d\n', i)
    else
        tmp = outerjoin(sleep{i}, act{i}, 'MergeKeys', true);
        features{i} = outerjoin(tmp, affect{i}, 'MergeKeys', true);
    end
end

save features features;
 
% also save extended features with previous versions of variables
clear; clc; load features;
nSubjects = size(features, 1);extendedFeatures = cell(nSubjects, 1);
for iSub =1:nSubjects
    
    iFeatures = features{iSub};
    if isempty(iFeatures);continue;end
    nSamples = height(iFeatures);
    prevInds =1:nSamples-1;
    curInds = 2:nSamples;
    effSamples = nSamples-1; % samples used
    variableNames = iFeatures.Properties.VariableNames;
    
    
    curFeatures = iFeatures(curInds, :);
    prevFeatures = iFeatures(prevInds, 4:end);
    prevFeatures.Properties.VariableNames = strcat('prev_', variableNames(4:end));
    extendedFeatures{iSub} = [curFeatures prevFeatures];
end

allExtendedFeatures = table;

for iSubject=1:nSubjects
    allExtendedFeatures = [allExtendedFeatures; extendedFeatures{iSubject}];
end



allExtendedFeaturesNorm = allExtendedFeatures;
si =0;
for iSub =1:nSubjects
    if isempty(extendedFeatures{iSub});continue;end
    nSamples(iSub)= height(extendedFeatures{iSub});
    m = repmat(nanmean(extendedFeatures{iSub}{:, 4:end}), nSamples(iSub), 1);   
    s = repmat(nanstd(extendedFeatures{iSub}{:, 4:end}), nSamples(iSub), 1);
    if any(any(s==0))       
        s(s==0)=1;
    end
    allExtendedFeaturesNorm{si+1:si+nSamples(iSub), 4:end} = (allExtendedFeaturesNorm{si+1:si+nSamples(iSub), 4:end}-m)./s;
    zeroS= find(nanstd(extendedFeatures{iSub}{:, 4:end})==0);
  
    si = si+nSamples(iSub);
end
%allExtendedFeaturesNorm.day_type = allExtendedFeatures.day_type;
%allExtendedFeaturesNorm.prev_day_type = allExtendedFeatures.prev_day_type;
save features features extendedFeatures allExtendedFeatures*;


% clear
% load sleep_data; load emm_data;load subjects;nSubjects= length(subjects);
% [varDate, varMood, varStress, varEnergy, varFocus,  varSleep_dur, varSleep_qual, varDay_type] = deal(cell(nSubjects,1));
% [allSubj,  allMood, allStress, allEnergy, allFocus,  allSleep_dur, allSleep_qual, allDay_type] = deal(nan(10000,1));
% nSamples = nan(nSubjects, 1);
% allDate =  nan(10000, 3);
% tab_ind=0;
% for i=1:nSubjects
%     % check if days are aligned
%     time_sleep_i = sleep_date{i};
%     time_mood_i = mood_date{i};
%     
%     % should be day_sleep = day_mood, time_sleep < time_mood   
%     nDaysSleep = size(time_sleep_i, 1);
%     nDaysMood = size(time_mood_i, 1);
%     
%     if nDaysSleep==0 || nDaysMood==0
%         fprintf('%d: No data\n', i)
%         continue;
%     end
%     
%     % now align mood and sleep data
%     [commonDays, indSleep, indMood] = intersect(time_sleep_i(:, 1:3), time_mood_i(:, 1:3), 'rows');
%     nCommonDays = size(commonDays,1);
%     nSamples(i) = nCommonDays;
%     fprintf('Subject %d, %d out of %d days with both sleep and mood\n', i, nCommonDays,max([nDaysSleep nDaysMood]));
%     
%     [varDate{i}, varMood{i}, varStress{i}, varEnergy{i}, varFocus{i},  varSleep_dur{i}, varSleep_qual{i}, varDay_type{i}] = deal(time_sleep_i(indSleep,1:3), ...
%         mood{i}(indMood,:), stress{i}(indMood, :),energy{i}(indMood, :), focus{i}(indMood, :), sleep_dur{i}(indSleep, :), sleep_qual{i}(indSleep, :), day_type{i}(indSleep, :));
%     [allDate(tab_ind+1:tab_ind+nCommonDays, :), allMood(tab_ind+1:tab_ind+nCommonDays), allStress(tab_ind+1:tab_ind+nCommonDays), allEnergy(tab_ind+1:tab_ind+nCommonDays), ...
%          allFocus(tab_ind+1:tab_ind+nCommonDays),  allSleep_dur(tab_ind+1:tab_ind+nCommonDays), allSleep_qual(tab_ind+1:tab_ind+nCommonDays),allDay_type(tab_ind+1:tab_ind+nCommonDays)] = ...
%          deal(time_sleep_i(indSleep,1:3), mood{i}(indMood,:), stress{i}(indMood, :),energy{i}(indMood, :), focus{i}(indMood, :), sleep_dur{i}(indSleep, :),...
%          sleep_qual{i}(indSleep, :),day_type{i}(indSleep, :));
%      allSubj(tab_ind+1:tab_ind+nCommonDays) =i;
%      tab_ind = tab_ind+nCommonDays;         
% end % end for
% 
% % Plot the correlations of each feature;
% plotcorrmatrix([allEnergy allFocus allMood allStress allSleep_dur allSleep_qual], {'Energy','Focus', 'Mood','Stress','SlDur', 'SlQual'});
% 
%     
