% Load subject sleep duration and subject mood
% clear;
close all;

addpath('../Functions/');
load('subjects');
load('../settings.mat');

data_dir ='C:\Users\Sofia\Documents\Data\depression2016\CS120data\CS120\';

timezones = readtable('../general/timezones.csv', 'readvariablenames',false,'delimiter','\t');

affect=cell(length(subjects), 1);

% initialize_matrices
for i = 1:length(subjects)
    % now load mood data /they are imported three times per day.
    filename_emm = [data_dir, '\', subjects{i}, '\emm.csv'];
    if exist(filename_emm,'file')
        tab_emm = readtable(filename_emm,'readvariablenames', false, 'delimiter','\t');
        tab_emm  = unique(tab_emm, 'rows');
        
        % temp store date vec and timestamps
        ts =(tab_emm.Var1+time_zone*3600)/86400 + datenum(1970,1,1);
        tmp =  datevec(ts);
        
        % consecutive dates from first to last timestamp
        entries_ts = tmp(:, 1:3); entries_date_ids = entries_ts(:, 1)*10^4 + entries_ts(:,2)*10^2 + entries_ts(:, 3);
        dates = ts(1):ts(end);dates= datevec(dates); dates=dates(:,1:3);
        date_ids = dates(:, 1)*10^4+dates(:,2)*10^2+dates(:, 3);nDates=size(date_ids, 1);
        fprintf('Subject %d, %d affect report days\n', i, nDates);

        % subect and affect inds
        subject = repmat(i, nDates, 1); [stress, mood,  energy, focus] = deal(nan(nDates, 1)); 
        
        % temp store affect variables
        %[stress_tmp,  mood_tmp, energy_tmp, focus_tmp] = deal(tab_emm.Var2, tab_emm.Var3, tab_emm.Var4, tab_emm.Var5); % read variables
        for iDate =1:nDates
            dateInds = ismember(entries_date_ids, date_ids(iDate)); 
           % fprintf('Date %d inds [%s]\n', iDate, num2str(find(dateInds)'));
            stress(iDate) =  mean(tab_emm.Var2(dateInds));
            mood(iDate) = mean(tab_emm.Var3(dateInds));
            energy(iDate) =  mean(tab_emm.Var4(dateInds));
            focus(iDate) = mean(tab_emm.Var5(dateInds));
        end
        affect{i} = table(subject, dates, date_ids, stress, mood, energy, focus);
    else fprintf('Subject %d, NO affect report days\n', i, nDates);
        [stress, mood, energy, focus] = deal([]);
        affect{i} = table(stress, mood, energy, focus);
    end
end

save affect affect
%%
%         emm_ts{i} = tab_emm.Var1;[emm_ts{i}, unique_inds_i] = unique(emm_ts{i}, 'rows'); % load timestamps       
%         fprintf('Duplicate inds [%s]\n', num2str(setdiff(1:length(emm_ts{i}), unique_inds_i)));  % find unique inds
%         ind = find(strcmp(timezones.Var1, subjects{i})); % find the timezone of subject i
%         time_zone = timezones.Var2(ind); % find time zone 
%         emm_tv{i} = datevec((emm_ts{i}+ time_zone*3600)/86400 + datenum(1970,1,1)); % timestamp to vector, year - month - day - hour - min - sec
%         [stress_tmp,  mood_tmp, energy_tmp, focus_tmp] = ...
%             deal(tab_emm.Var2(unique_inds_i), tab_emm.Var3(unique_inds_i), tab_emm.Var4(unique_inds_i), tab_emm.Var5(unique_inds_i)); % read variables
%         
%         % now split daily
%          tmp = emm_tv{i};
%          [uniqueDays, dayIndsFirst] = unique(tmp(:, 1:3), 'rows');
%          [~, dayIndsLast] = unique(tmp(:, 1:3), 'rows', 'last');
%         
%          % calcualate mean stress, mood, energy, focus; record first day
%          % time for alignment with sleep.
%          nDays = size(uniqueDays, 1);
%          [stress_i,mood_i, energy_i, focus_i] = deal(nan(nDays, 1));
%          for iDay = 1:nDays         
%              stress_i(iDay) = mean(stress_tmp(dayIndsFirst(iDay):dayIndsLast(iDay)));
%              mood_i(iDay) = mean(mood_tmp(dayIndsFirst(iDay):dayIndsLast(iDay)));
%              energy_i(iDay) = mean(energy_tmp(dayIndsFirst(iDay):dayIndsLast(iDay)));
%              focus_i(iDay) = mean(focus_tmp(dayIndsFirst(iDay):dayIndsLast(iDay)));             
%          end
%          [stress{i},  mood{i}, energy{i}, focus{i}, mood_date{i}] = ...
%             deal(stress_i, mood_i, energy_i, focus_i, tmp(dayIndsFirst, :)); % read variables
%            %         min 
%     else
%         [mood_date{i}, stress{i},  mood{i}, energy{i}, focus{i}] = deal([]);
%     end
% 
% end
% 
% save emm_data mood stress energy focus mood_date




% % Load subject sleep duration and subject mood
% % clear;
% close all;
% 
% addpath('../Functions/');
% load('subjects');
% load('../settings.mat');
% 
% data_dir ='C:\Users\Sofia\Documents\Data\depression2016\CS120data\CS120\';
% 
% timezones = readtable('../general/timezones.csv', 'readvariablenames',false,'delimiter','\t');
% 
% % initialize_matrices
% [emm_ts, emm_tv, mood, stress, energy, focus, mood_date] = deal(cell(length(subjects),1));
% clc
% for i = 1:length(subjects)
%     % now load mood data /they are imported three times per day.
%     filename_emm = [data_dir, '\', subjects{i}, '\emm.csv'];
%     if exist(filename_emm,'file')
%         tab_emm = readtable(filename_emm,'readvariablenames', false, 'delimiter','\t');
%         emm_ts{i} = tab_emm.Var1;[emm_ts{i}, unique_inds_i] = unique(emm_ts{i}, 'rows'); % load timestamps       
%         fprintf('Duplicate inds [%s]\n', num2str(setdiff(1:length(emm_ts{i}), unique_inds_i)));  % find unique inds
%         ind = find(strcmp(timezones.Var1, subjects{i})); % find the timezone of subject i
%         time_zone = timezones.Var2(ind); % find time zone 
%         emm_tv{i} = datevec((emm_ts{i}+ time_zone*3600)/86400 + datenum(1970,1,1)); % timestamp to vector, year - month - day - hour - min - sec
%         [stress_tmp,  mood_tmp, energy_tmp, focus_tmp] = ...
%             deal(tab_emm.Var2(unique_inds_i), tab_emm.Var3(unique_inds_i), tab_emm.Var4(unique_inds_i), tab_emm.Var5(unique_inds_i)); % read variables
%         
%         % now split daily
%          tmp = emm_tv{i};
%          [uniqueDays, dayIndsFirst] = unique(tmp(:, 1:3), 'rows');
%          [~, dayIndsLast] = unique(tmp(:, 1:3), 'rows', 'last');
%         
%          % calcualate mean stress, mood, energy, focus; record first day
%          % time for alignment with sleep.
%          nDays = size(uniqueDays, 1);
%          [stress_i,mood_i, energy_i, focus_i] = deal(nan(nDays, 1));
%          for iDay = 1:nDays         
%              stress_i(iDay) = mean(stress_tmp(dayIndsFirst(iDay):dayIndsLast(iDay)));
%              mood_i(iDay) = mean(mood_tmp(dayIndsFirst(iDay):dayIndsLast(iDay)));
%              energy_i(iDay) = mean(energy_tmp(dayIndsFirst(iDay):dayIndsLast(iDay)));
%              focus_i(iDay) = mean(focus_tmp(dayIndsFirst(iDay):dayIndsLast(iDay)));             
%          end
%          [stress{i},  mood{i}, energy{i}, focus{i}, mood_date{i}] = ...
%             deal(stress_i, mood_i, energy_i, focus_i, tmp(dayIndsFirst, :)); % read variables
%            %         min 
%     else
%         [mood_date{i}, stress{i},  mood{i}, energy{i}, focus{i}] = deal([]);
%     end
% 
% end
% 
% save emm_data mood stress energy focus mood_date
