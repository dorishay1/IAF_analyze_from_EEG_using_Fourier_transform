% Ex - 4


%% Data handling
clear; close all; clc;
channel = 19;                              %set channel to analyze.
conditions_num = 2;                        %setting number of conditions

%set zip file name.
%zip file should be in the current folder.
zip_file_name = 'EC_EO_data.zip';

%The output here is the data from the specific zip file and channel.
%data columns - runing index of subjects (regardless to thier subject number)
%data rows - 1 = subject number, 2/3 = Eyes Open/Close vec for selected channel,
%further explanition inside the function(we made this function).

[data,number_subjects] = data2cell(zip_file_name,channel,conditions_num);


%% Settings
fs = 256;                           %sampling frequency, Hz
dt = 1/fs;                          %time step [sec]
window_size = 40*fs;                 %setting window size this way allows us to
%think of it as a time window [sec].
overlap = round(window_size/2);     %setting overlap this way allows us to think of
%it as part of the time window.
f = 6:0.1:14;                       %vector alpha freq for pwelch.

%plot properties
alpha_band = [6 14];                %in which spectrom to focus on the axes.

%colors setting
IAF_line = ':m';                    %for IAF line
EC_EO_graph = 'g';                  %for EC-EO graph
EC_EO_colors = {'r','b'};           %for EC & EO graphs for all methods.
%% Plots

%The main loop of the work.
%we run the entire analyze for each subject in each condition.
%we mainly use temp variables, but in order to calculate the IAF later, we save
%the relveant information for the relvent time (more details inside the loop).
%The functios FFT & DFT are made by us, further explantion inside the functions.

for subject_index = 1:number_subjects
    
    %each subject gets a new window with title. we wanted a full screen figure
    %so it be large enogh to check all 6 plots carefully.
    figure('Units','normalized','Position', [0 0 1 1]);
    hold on
    sgtitle(['Subject Number - ',data{1,subject_index}])
    
    for eyes_condition = 1:conditions_num
        
        %sets the relvent vector from data and sets the color.
        data_vec = data{eyes_condition+1,subject_index};
        current_color = EC_EO_colors{eyes_condition};
        
        %% FFT
        fft_subplot = subplot(2,3,1);
        hold on
        [x,y] = FFT(data_vec,fs);
        plot(x,y,current_color)
        
        title('FFT')
        ylabel('Power');
        
        %IAF
        % EC is the first condition. the vector y is stored until the next
        % condition.
        if eyes_condition == 1
            fft_EC_y = y;
            
            %when getting to the next condition (EO), the IAF is calculated with the
            %previous y conditions that was stored (fft_EC_y) - y.
        elseif eyes_condition == 2
            
            dif_spec = fft_EC_y-y;
            IAF_max = find(dif_spec == max(dif_spec));
            
            fft_IAF_subplot = subplot(2,3,4);
            plot(x,dif_spec,EC_EO_graph)
            xline(x(IAF_max), IAF_line,'LineWidth', 1.5);
            ylabel('Power');
            xlabel('Frequency [Hz]');
            
            title(['EC-EO : IAF = ', num2str(x(IAF_max)), ' Hz']);
        end
        
        %% pwelch
        pwelch_subplot = subplot(2,3,2);
        hold on
        [y,x] = pwelch(data_vec,window_size,overlap,f,fs);
        plot(x,y,current_color)
        title('Pwelch')
        
        %IAF
        %same idea as previous IAF
        if eyes_condition == 1
            pwelch_EC_y = y;
            
        elseif eyes_condition == 2
            
            dif_spec = pwelch_EC_y-y;
            IAF_max = find(dif_spec == max(dif_spec));
            
            IAF_pwelch_subplot = subplot(2,3,5);
            plot(x,dif_spec,EC_EO_graph)
            xline(x(IAF_max), IAF_line,'LineWidth', 1.5);
            xlabel('Frequency [Hz]');
            title(['EC-EO : IAF = ', num2str(x(IAF_max)), ' Hz']);
            
        end
        
        
        %% DFT
        DFT_subplot = subplot(2,3,3);
        hold on
        [x,y] = DFT(data_vec,window_size,overlap,fs);        %more explantion inside function.
        plot(x,y,current_color)
        title('DFT')
        
        lgd = legend('Close','Open','FontSize',10);
        title(lgd,'Eyes condition');
        
        %IAF
        %same idea as previous IAF
        
        if eyes_condition == 1
            DFT_EC_y = y;
            
        elseif eyes_condition == 2
            
            dif_spec = DFT_EC_y-y;
            IAF_max = find(dif_spec == max(dif_spec));
            
            IAF_DFT_subplot = subplot(2,3,6);
            plot(x,dif_spec,EC_EO_graph)
            xline(x(IAF_max), IAF_line,'LineWidth', 1.5);
            xlabel('Frequency [Hz]');
            title(['EC-EO : IAF = ', num2str(x(IAF_max)), ' Hz']);
            
            legend('EC-EO','IAF')
            
        end
        
    end
    %% setting limits
    %linking all x axes in order to scale them into the alpha band.
    
    linkaxes([fft_subplot fft_IAF_subplot pwelch_subplot IAF_pwelch_subplot...
        DFT_subplot IAF_DFT_subplot],'x');
    fft_subplot.XLim = alpha_band;
    
end

