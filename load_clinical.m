
clear;clc
%close all;

addpath('../Functions/');
load('subjects');
load('../settings.mat');

data_dir ='C:\Users\Sofia\Documents\Data\depression2016\CS120data\CS120Clinical\';

%load screener data
filename_scr = [data_dir, '\CS120Final_Screener.xlsx'];
% dummy excel to get the headers
dummy =readtable(filename_scr,'filetype', 'spreadsheet', 'Range', 'A1:CN2');
variableNames = dummy.Properties.VariableNames;
scr =readtable(filename_scr,'filetype', 'spreadsheet', 'Range', 'A84:CN294', 'ReadVariableNames', false);
scr.Properties.VariableNames = variableNames;


useVars = {'ID','dem03', 'score_PHQ', 'Score_AUDIT', 'score_DAST', 'CONTROL', 'ANXIOUS', 'DEPRESSED',  'DEPRESSED_ANXIOUS'};

scrInfo = scr(1:208, useVars);
% find depressed and controls;
% PHQ8 = scr{:, 'score_PHQ'};
 IDS = scr{:, 'ID'};
% 
% depressedIDs =  IDS(PHQ8>10);
% depressedSubjects = ismember(subjects, depressedIDs);

nSubjects=length(subjects);
[mem, memind] = ismember(subjects, IDS);

for iSubject=1:nSubjects
   if mem(iSubject)
   
   	scrInfo(iSubject,:) = scr(memind(iSubject), useVars);
   else
        scrInfo{iSubject, 1}= subjects(iSubject);
        scrInfo{iSubject, 2:end} = deal(nan);
        fprintf('Subject %s not present in screener\n', subjects{iSubject});
        
    end     
end
scrInfo.ANXIOUS = ~isnan(scrInfo.ANXIOUS);
scrInfo.DEPRESSED = ~isnan(scrInfo.DEPRESSED);
scrInfo.DEPRESSED_ANXIOUS = ~isnan(scrInfo.DEPRESSED_ANXIOUS);
scrInfo.CONTROL = ~isnan(scrInfo.CONTROL);

scrInfo.Properties.VariableNames =  {'ID','Age', 'score_PHQ', 'score_AUDIT', 'score_DAST', 'isControl', 'isAnxious', 'isDepressed',  'isDepressedAnxious'};

varNames = scrInfo.Properties.VariableNames;
for iVar=1:width(scrInfo)
    curVar = varNames{iVar};
    if isnumeric(scrInfo{:,curVar })
        scrInfo{scrInfo{:, curVar}>990, curVar}=nan;
    end
end
% did subjects 'BE623WB'  'FI330WL' drop out? In the screener, but not
% subjects
%save('subjects.mat', 'scrInfo', '-append');

%%
%load screener data
filename_bsl = [data_dir, '\CS120Final_Baseline'];
% dummy excel to get the headers
dummy =readtable(filename_bsl, 'filetype', 'spreadsheet', 'Range', 'A1:CN2');
variableNames = dummy.Properties.VariableNames;
bsl =readtable(filename_bsl,'filetype', 'spreadsheet', 'Range', 'A84:CN294', 'ReadVariableNames', false);
bsl.Properties.VariableNames = variableNames;


useVars = {'ID', 'demo09', 'demo12', 'demo13'};
varNames = {'ID', 'gender', 'education', 'marital_status'};


bslInfo = cell2table({'', nan, nan,nan},'VariableNames', useVars);
% find depressed and controls;
% PHQ8 = scr{:, 'score_PHQ'};
 IDS = bsl{:, 'ID'};
% 
% depressedIDs =  IDS(PHQ8>10);
% depressedSubjects = ismember(subjects, depressedIDs);

nSubjects=length(subjects);
[mem, memind] = ismember(subjects, IDS);

for iSubject=1:nSubjects
   if mem(iSubject)
   
   	bslInfo(iSubject,:) = bsl(memind(iSubject), useVars);
   else
        bslInfo{iSubject, 1}= subjects(iSubject);
        bslInfo{iSubject, 2:end} = deal(nan);
        fprintf('Subject %s not present in screener\n', subjects{iSubject});
        
    end     
end
bslInfo.Properties.VariableNames = varNames;

for iVar=1:width(bslInfo)
    curVar = varNames{iVar};
    if isnumeric(bslInfo{:,curVar })
        bslInfo{bslInfo{:, curVar}>990, curVar}=nan;
    end
end
subjectInfo = join(scrInfo, bslInfo);


%save('subjects.mat', 'bslInfo', '-append');

%% Week 3 data: Load phq8, PSQI info

%load w3 data
filename_w3 = [data_dir, '\CS120Final_3week'];
% dummy excel to get the headers
dummy =readtable(filename_w3,'filetype', 'spreadsheet', 'Range', 'A1:CO2');
variableNames = dummy.Properties.VariableNames;
w3 =readtable(filename_w3,'filetype', 'spreadsheet', 'Range', 'A84:CO294', 'ReadVariableNames', false);
w3.Properties.VariableNames = variableNames;
IDS = w3{:, 'ID'};


phqInds=  cellfun(@(s) ~isempty(strfind(s, 'phq')),variableNames );
phqVars = variableNames(phqInds);
phqVarNames = strcat('w3_phq_', {'01', '02', '03', '04', '05', '06', '07', '08'});

psqInds=  cellfun(@(s) ~isempty(strfind(s, 'psq')),variableNames );
psqVars = variableNames(psqInds);
psqVars = psqVars(8:end); % psq 1-8 are am/pm times for sleep, not 0-3 scores;
psqVarNames= strcat('w3_', psqVars);
psqVarNames{1} = 'w3_psq_sleep_duration';

useVars = {'ID', 'DateCompleted', phqVars{:}, psqVars{:}};
varNames = {'ID','w3_DateCompleted', phqVarNames{:}, psqVarNames{:}, 'w3DropOut'};

w3Info = w3(1,useVars);
w3Info{1, end+1}= false;

nSubjects=length(subjects);
[mem, memind] = ismember(subjects, IDS);
for iSubject=1:nSubjects
   if mem(iSubject)   
   	w3Info(iSubject,1:end-1) = w3(memind(iSubject), useVars);
    w3Info{iSubject, end} = false;
   else
        w3Info{iSubject, 1}= subjects(iSubject);
        w3Info{iSubject, 2}={[]};
        w3Info{iSubject, 3:end-1} = deal(nan);
        w3Info{iSubject, end} = true;
        fprintf('Subject %s not present in week3\n', subjects{iSubject});
    end     
end

w3Info.Properties.VariableNames = varNames;

for iVar=1:width(w3Info)
    curVar = varNames{iVar};
    if isnumeric(w3Info{:,curVar })
        w3Info{w3Info{:, curVar}>990, curVar}=nan;
    end
end

w3_phq8 = nansum(w3Info{:, phqVarNames}, 2);
w3Info = [w3Info table(w3_phq8)];
subjectInfo = join(subjectInfo, w3Info);
%%

%load w6 data
filename_w6 = [data_dir, '\CS120Final_6week'];
% dummy excel to get the headers
dummy =readtable(filename_w6,'filetype', 'spreadsheet', 'Range', 'A1:CO2');
variableNames = dummy.Properties.VariableNames;
w6 =readtable(filename_w6,'filetype', 'spreadsheet', 'Range', 'A84:CO294', 'ReadVariableNames', false);
w6.Properties.VariableNames = variableNames;
IDS = w6{:, 'ID'};


phqInds=  cellfun(@(s) ~isempty(strfind(s, 'phq')),variableNames );
phqVars = variableNames(phqInds);
phqVarNames = strcat('w6_phq_', {'01', '02', '03', '04', '05', '06', '07', '08'});

psqInds=  cellfun(@(s) ~isempty(strfind(s, 'psq')),variableNames );
psqVars = variableNames(psqInds);
psqVars = psqVars(8:end); % psq 1-8 are am/pm times for sleep, not 0-3 scores;
psqVarNames= strcat('w6_', psqVars);
psqVarNames{1} = 'w6_psq_sleep_duration';

useVars = {'ID', 'DateCompleted', phqVars{:}, psqVars{:}};
varNames = {'ID','w6_DateCompleted', phqVarNames{:}, psqVarNames{:}, 'w6DropOut'};

w6Info = w6(1,useVars);
w6Info{1, end+1}= false;

nSubjects=length(subjects);
[mem, memind] = ismember(subjects, IDS);
for iSubject=1:nSubjects
   if mem(iSubject)   
   	w6Info(iSubject,1:end-1) = w6(memind(iSubject), useVars);
    w6Info{iSubject, end} = false;
   else
        w6Info{iSubject, 1}= subjects(iSubject);
        w6Info{iSubject, 2}={[]};
        w6Info{iSubject, 3:end-1} = deal(nan);
        w6Info{iSubject, end} = true;
        fprintf('Subject %s not present in week6\n', subjects{iSubject});
    end     
end

w6Info.Properties.VariableNames = varNames;

for iVar=1:width(w6Info)
    curVar = varNames{iVar};
    if isnumeric(w6Info{:,curVar })
        w6Info{w6Info{:, curVar}>990, curVar}=nan;
    end
end

w6_phq8 = nansum(w6Info{:, phqVarNames}, 2);
w6Info = [w6Info table(w6_phq8)];
subjectInfo = join(subjectInfo, w6Info);
save('subjects.mat', 'subjectInfo', '-append');
