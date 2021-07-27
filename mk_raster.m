% /
% Take in mouse lick time data and produce lick rasters.
%
%
% /
tic;

% find and import asymetric gaussian filter
cd ~/Desktop/Licking_Data/
load("AssymetricGaussian_filter");

%find and import data
cd ~/Desktop/Licking_Data/2021-July-20
files = dir('*.mat');
raster_length = 20000;
xs = [-9999:10000];

for n1 = 1 : length(files)
    load(files(n1).name);
    L_Licks = false(length(Table_out),raster_length); %empty logical array
    R_Licks = false(length(Table_out),raster_length); %empty logical array
    cv_Rt_l_licks = zeros(length(Table_out),raster_length); %empty mat
    cv_Rt_r_licks = zeros(length(Table_out),raster_length); %empty mat
    cv_Lt_l_licks = zeros(length(Table_out),raster_length); %empty mat
    cv_Lt_r_licks = zeros(length(Table_out),raster_length); %empty mat
    for n2 = 1 : length(Table_out)
        % LOAD IN TRIAL ITEMS
        trial_start = Table_out{n2,2};
        L_lick_times = (Table_out{n2,3}(Table_out{n2,3} ~= 0));
        R_lick_times = (Table_out{n2,11}(Table_out{n2,11} ~= 0));
        stim_on = Table_out{n2,6};
        reward_T = Table_out{n2,9};
        stim_type = Table_out{n2,5};
        % CHECK FOR EMPTY TRIAL
        if isempty(stim_type)
            continue
        end
        % CLEAN UP LICK TIMES
        if length(R_lick_times) > 2
            D_R = [1 diff(R_lick_times)];
            D_R(D_R < 0.01)=0;
            D_R(D_R > 0.01)=1;
            R_lick_times = R_lick_times(logical(D_R));
        end
        if length(L_lick_times) > 2
            D_L = [1 diff(L_lick_times)];
            D_L(D_L < 0.01)=0;
            D_L(D_L > 0.01)=1;
            L_lick_times = L_lick_times(logical(D_L));
        end
        
        % FIX TRIAL TIMES TO ___________
        L_lick_times = round(1000*(L_lick_times - stim_on))+9999;
        R_lick_times = round(1000*(R_lick_times - stim_on))+9999;
        
        % SAVE IN RASTER
        try
            L_Licks(n2,L_lick_times) = 1;
            R_Licks(n2,R_lick_times) = 1;
        catch
            disp(strcat("error, file:",files(n1).name," Trial #",num2str(n2)));
        end
        
        % SEPERATE OUT RIGHT TRIALS
        if strcmp(stim_type, "R")
            
            % LEFT LICKS
            L_cv = double(L_Licks(n2,:));
            L_locs = find(L_cv);
            for ii = 1 : length(L_locs)
                L_cv(L_locs(ii):(length(asymmGauss)+L_locs(ii)-1)) = asymmGauss;
            end
            cv_Rt_l_licks(n2,:) = L_cv; %save convoluted lick data 
            
            % RIGHT LICKS
            R_cv = double(R_Licks(n2,:));
            R_locs = find(R_cv);
            for ii = 1 : length(R_locs)
                R_cv(R_locs(ii):(length(asymmGauss)+R_locs(ii)-1)) = asymmGauss;
            end
            cv_Rt_r_licks(n2,:) = R_cv; %save convoluted lick data 
            
        % SEPERATE OUT LEFT TRIALS
        elseif strcmp(stim_type, "L")
            
            % LEFT LICKS
            L_cv = double(L_Licks(n2,:));
            L_locs = find(L_cv);
            for ii = 1 : length(L_locs)
                L_cv(L_locs(ii):(length(asymmGauss)+L_locs(ii)-1)) = asymmGauss;
            end
            cv_Lt_l_licks(n2,:) = L_cv; %save convoluted lick data 
            
            % RIGHT LICKS
            R_cv = double(R_Licks(n2,:));
            R_locs = find(R_cv);
            for ii = 1 : length(R_locs)
                R_cv(R_locs(ii):(length(asymmGauss)+R_locs(ii)-1)) = asymmGauss;
            end
            cv_Lt_r_licks(n2,:) = R_cv; %save convoluted lick data 
        % EMPTY TRIALS
        elseif ~exist(stim_type,'var')
            
        end
    end
    figure;
    % LEFT LICK PLOT
    subplot(2,1,1); hold on;
    title_name = strsplit(files(n1).name," ");
    title(strcat(title_name{1}," Left Trials"));
    plot(xs,sum(cv_Lt_l_licks,1),'b-'); 
    plot(xs,sum(cv_Lt_r_licks,1),'r-'); hold off;
    % RIGHT LICK PLOT
    subplot(2,1,2); hold on;
    title(strcat(title_name{1}," Right Trials"));
    plot(xs,mean(cv_Rt_l_licks,1),'b-');
    plot(xs,mean(cv_Rt_r_licks,1),'r-'); hold off;
    
end

toc;

        
        
        
        
        
