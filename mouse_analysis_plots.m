% Mouse data analysis

% Data Columns 
% 1: Trial #
% 2: Trial_Start_Time
% 3: Lick_Times_L
% 4: Grasp_Times_L
% 5: Stim_Type
% 6: Stim_ON_Time
% 7: Stim_OFF_Time
% 8: Reward_Size
% 9: Reward_Time
% 10: Trial_End_Time
% 11: Lick_Times_R
% 12: Grasp_Times_R
% 13: Stim Paw


% shift lick response curves to be alligned with stimu;us onsey, not trial
% onset. 
%--------------------------------------------------------------------------

%find and import data
cd ~/Desktop/PROJECT/Analysis/data-selected
names = dir;
names([1 2], :) = [];
file_num = 8;


for sub=1:2
    if sub == 1
        Trial_side = "R";
        figure; hold on;
    else
        Trial_side = "L";
    end
    length_prev = 0;
    for nn=file_num:file_num %length(names)
        load(names(nn).name);

        for n=1:length(Table_out)
            trial_start = Table_out{n,2};
            L_lick_times = Table_out{n,3}(Table_out{n,3} ~= 0);
            R_lick_times = Table_out{n,11}(Table_out{n,11} ~= 0);
            stim_on = Table_out{n,6};
            reward_T = Table_out{n,9};
            stim_type = Table_out{n,5};

            %clean up lick data
            if length(R_lick_times) > 2
                D_R = diff(R_lick_times);
                D_R(D_R < 0.01)=0;
                D_R(D_R > 0.01)=1;
                D_R = [1 D_R];
                R_lick_times = R_lick_times(logical(D_R));
            else
                %disp("RIGHT lick data appears to be empty...");
            end

            if length(L_lick_times) > 2
                D_L = diff(L_lick_times);
                D_L(D_L < 0.01)=0;
                D_L(D_L > 0.01)=1;
                D_L = [1 D_L];
                L_lick_times = L_lick_times(logical(D_L));
            else
                %disp("LEFT lick data appears to be empty...");
            end

            % Which stim
            if strcmp(stim_type,Trial_side)
                continue;
            else
            end

            % PLOTTING
            if sub == 1
                subplot(1,2,1); hold on;
            else
                subplot(1,2,2); hold on;
            end
            plot(0,(n+length_prev),'g*');
            if ~isempty(L_lick_times)
                plot(L_lick_times - trial_start,(n+length_prev),'b.');
            end
            if ~isempty(R_lick_times)
                plot(R_lick_times - trial_start,(n+length_prev),'r.');
            end
            if ~isempty(reward_T)
                plot(reward_T - trial_start, (n+length_prev),'m*');
            end
            if ~isempty(stim_on)
                plot(stim_on - trial_start, (n+length_prev),'c*');
            end
        end
        length_prev = length_prev + length(Table_out);
        disp(strcat("Finished experiment # ",num2str(n)));
    end %end of file name loop


    % FIND APPROPRIATE PLOT TITLE
    if Trial_side == "R"
        title(strcat(names(nn).name(1:4)," Licking Behavior, (Left Rewards)"));
    elseif Trial_side == "L"
        title(strcat(names(nn).name(1:4)," Licking Behavior, (Right Rewards)"));
    else 
        title(strcat(names(nn).name(1:4)," Licking Behavior"));
    end

    % Label axis'
    xlabel('Time (seconds)');
    ylabel('Trial #');
    hold off;
end



