% Load subject sleep duration and subject mood

clear;clc
%close all;

addpath('../Functions/');
load('subjects');
load('../settings.mat');

data_dir ='C:\Users\Sofia\Documents\Data\depression2016\CS120data\CS120\';
timezones = readtable('../general/timezones.csv', 'readvariablenames', false, 'delimiter','\t');

[time_act, date_act, act, act_conf]= deal(cell(length(subjects),1));
% start loading data
for i=1:length(subjects)
    
    filename_act = [data_dir, '\', subjects{i}, '\act.csv'];
    
    if exist(filename_act,'file'),
        tab_act = readtable(filename_act,'readvariablenames',false,'delimiter','\t');
        tab_act = unique(tab_act, 'rows');
        if isnan(time_zone); time_zone=0; end      
        
        ts =(tab_act.Var1+time_zone*3600)/86400 + datenum(1970,1,1);
        tmp =  datevec(ts);
        
        % consecutive dates from first to last timestamp
        entries_ts = tmp(:, 1:3); entries_date_ids = entries_ts(:, 1)*10^4 + entries_ts(:,2)*10^2 + entries_ts(:, 3);
        dates = ts(1):ts(end);dates= datevec(dates); dates=dates(:,1:3);
        date_ids = dates(:, 1)*10^4+dates(:,2)*10^2+dates(:, 3);nDates=size(date_ids, 1);
        
        fprintf('Subject %d, %d activity report days\n', i, nDates);
        % subect and activity inds
        subject = repmat(i, nDates, 1); activity= nan(nDates, 1);
        
        actstr = tab_act.Var2;
        bike_inds = strcmp('BIKING', actstr);
        walk_inds=strcmp('ON_FOOT', actstr);        
        act_inds = bike_inds|walk_inds;        
        act_date_ids = entries_date_ids(act_inds);       
        
        for iDate = 1:nDates;
            activity(iDate) =nnz(ismember(act_date_ids, date_ids(iDate)));            
        end

        act{i} = table(subject, dates, date_ids, activity);
    else
        fprintf('Subject %d, NO report days\n', i);
        [subject, activity] =deal([]);
        act{i} = table(subject, activity);
    end
end

save act act;
