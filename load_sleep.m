% Load subject sleep duration and subject mood
close all;

addpath('../Functions/');
load('subjects');
load('../settings.mat');

data_dir ='C:\Users\Sofia\Documents\Data\depression2016\CS120data\CS120\';

timezones = readtable('../general/timezones.csv', 'readvariablenames',false,'delimiter','\t');

sleep=cell(length(subjects), 1);

% initialize_matrices
for i = 1:length(subjects)
    ind = find(strcmp(timezones.Var1, subjects{i})); % find the timezone of subject i
    time_zone = timezones.Var2(ind); 
    % now load mood data /they are imported three times per day.
    filename_sleep= [data_dir, '\', subjects{i}, '\ems.csv'];
    if exist(filename_sleep,'file')
        tab_sleep = readtable(filename_sleep,'readvariablenames', false, 'delimiter','\t');
        tab_sleep  = unique(tab_sleep, 'rows');
        
        % temp store date vec and timestamps
        ts =(tab_sleep.Var1+time_zone*3600)/86400 + datenum(1970,1,1);
        tmp =  datevec(ts);
        
        % consecutive dates from first to last timestamp
        entries_ts = tmp(:, 1:3); entries_date_ids = entries_ts(:, 1)*10^4 + entries_ts(:,2)*10^2 + entries_ts(:, 3);
        dates = ts(1):ts(end);dates= datevec(dates); dates=dates(:,1:3);
        date_ids = dates(:, 1)*10^4+dates(:,2)*10^2+dates(:, 3);nDates=size(date_ids, 1);
        fprintf('Subject %d, %d sleep report days\n', i, nDates);

        % initialize subect and sleep inds 
        subject = repmat(i, nDates, 1); [sleep_duration, sleep_quality,  day_type] = deal(nan(nDates, 1)); 
        
        time_bed =(tab_sleep.Var2/1000+time_zone*3600)/86400+ datenum(1970,1,1);
        time_sleep =(tab_sleep.Var3/1000+time_zone*3600)/86400+ datenum(1970,1,1);
        time_wake=(tab_sleep.Var4/1000+time_zone*3600)/86400+ datenum(1970,1,1);
        time_up = (tab_sleep.Var5/1000+time_zone*3600)/86400+ datenum(1970,1,1);
        % temp store affect variables
        %[stress_tmp,  mood_tmp, energy_tmp, focus_tmp] = deal(tab_emm.Var2, tab_emm.Var3, tab_emm.Var4, tab_emm.Var5); % read variables
        for iDate =1:nDates
            dateInd= ismember(entries_date_ids, date_ids(iDate)); 
            if sum(dateInd)>1; %fprintf('something is wrong\n');
                % if you have more than one report for the same day, keep
                % only the first.
                discInds = find(dateInd); discInds=discInds(2:end); dateInd(discInds)=false;
                disp([datestr(ts(dateInd), 0) repmat(' | ', sum(dateInd), 1) datestr(time_sleep(dateInd), 0) repmat(' | ', sum(dateInd), 1) datestr(time_wake(dateInd), 0)]);
            end
            if sum(dateInd)==0; continue;end
            %fprintf('Date %d inds [%s]\n', iDate, num2str(find(dateInd)));
            % fix am-pm mixup issue
            if  hour(time_sleep(dateInd))>=12 && hour(time_sleep(dateInd))<15 && (time_wake(dateInd)-time_sleep(dateInd))*86400/3600>=15; %
                fprintf('Sleep time %s, wake time %s, ', datestr(time_sleep(dateInd)), datestr(time_wake(dateInd)));
                time_sleep(dateInd) = time_sleep(dateInd)+ datenum(hours(12));
                fprintf('\t new wake time %s\n', datestr(time_sleep(dateInd)));
            end
            sleep_duration(iDate)= (time_wake(dateInd)-time_sleep(dateInd))*86400/3600;
            sleep_quality(iDate) = tab_sleep.Var6(dateInd);
            day_type(iDate)= find(strcmp({'off', 'partial', 'normal'}, tab_sleep.Var7(dateInd)));
        end
        sleep{i} = table(subject, dates, date_ids, sleep_duration, sleep_quality, day_type);
    else fprintf('Subject %d, NO sleep report days\n', i, nDates);
        [sleep_duration, sleep_quality, day_type]=deal([]);
        sleep{i} = table( sleep_duration, sleep_quality, day_type);        
    end
end
save sleep sleep
%%

% %%
% clear;
% %close all;
% 
% addpath('../Functions/');
% load('subjects');
% load('../settings.mat');
% 
% data_dir ='C:\Users\Sofia\Documents\Data\depression2016\CS120data\CS120\';
% timezones = readtable('../general/timezones.csv', 'readvariablenames',false,'delimiter','\t');
% 
% [sleep_dur, sleep_date, sleep_qual, day_type] = deal(cell(length(subjects),1));
% % start loading data
% for i=1:length(subjects)
%     
%     filename_sleep = [data_dir, '\', subjects{i}, '\ems.csv'];
%     
%     if exist(filename_sleep,'file'),
%         tab_sleep = readtable(filename_sleep,'readvariablenames',false,'delimiter','\t');
%         
%         ind = find(strcmp(timezones.Var1, subjects{i})); % find the timezone of subject i
%         time_zone = timezones.Var2(ind); 
%         if isnan(time_zone); time_zone=0; end % two of the subjects have nan timezones
%                 
%         % Remove_duplicates
%         tmp = tab_sleep.Var1; % load timestamps 
%         size(tmp);
%         sleep_tv_tmp = datevec((tmp+time_zone*3600)/86400 + datenum(1970,1,1)); % convert to vector, year - month - day - hour - min - sec
%         
%         [~, unique_inds_i] = unique(sleep_tv_tmp(:, 1:3), 'rows'); % find unique days (removes duplicates and double day entries)
%         sleep_date{i} = datevec((tab_sleep.Var1(unique_inds_i)+time_zone*3600)/86400 + datenum(1970,1,1));
%         fprintf('Duplicate/double entries[%s]\n', num2str(setdiff(1:length(tmp), unique_inds_i))); 
%         
%         %load measurements
%         [time_bed, time_sleep, time_wake, time_up] = deal(tab_sleep.Var2/1000+time_zone*3600, tab_sleep.Var3/1000+time_zone*3600, tab_sleep.Var4/1000+time_zone*3600, tab_sleep.Var5/1000+time_zone*3600);
%          
%         % correct very large durations due to wrong am/pm inputs around
%         % 12pm
%         ind_mixup = (mod(time_sleep,86400)/3600>=12)&(mod(time_sleep,86400)/3600<15)& ((time_wake-time_sleep)/3600>=15);
%         time_sleep(ind_mixup) = time_sleep(ind_mixup) + 12*3600;
% 
% 
%         sleep_dur{i} = (time_wake(unique_inds_i)-time_sleep(unique_inds_i))/3600;
%         sleep_qual{i} = tab_sleep.Var6(unique_inds_i);
% 
% 
%         % what type of day was it?
%         tmp = tab_sleep.Var7(unique_inds_i);
%         dtp = nan(size(tmp));
%         dtp(strcmp(tmp, 'off')) = 0;
%         dtp(strcmp(tmp, 'partial')) = 1;
%         dtp(strcmp(tmp, 'normal')) = 2;
%         day_type{i} = dtp;
%         
%         % duration-quality correlation
%         c =corr(sleep_qual{i}, sleep_dur{i});
%         duration_qual_corr (i) = c;
%         
%        
%     
%        % visualy inspect the data
%        % close all;
% %         scatter(sleep_qual{i}, sleep_dur{i}, [], dtp); xlabel('quality'); ylabel('duration');
% %         xlim([0.8, 7.2]); ylim([0, 20]); hold all; plot(xlim, [median(sleep_dur{i}) median(sleep_dur{i})], 'color', 'k', 'LineWidth', 0.1);
% %         
% %         title(sprintf('correlation: %.3f', c));        
%         %pause;       
%         
%         
%     else
%         [sleep_dur{i}, sleep_date{i}, sleep_qual{i}, day_type{i}] = deal([]);
%     end
% end
% 
% 
% save sleep_data day_type  sleep_date sleep_qual sleep_dur
