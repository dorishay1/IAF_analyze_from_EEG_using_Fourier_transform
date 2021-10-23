function [datacell, number_subjects] = data2cell(zip_file_name,channel,conditions_num)
%This function takes a zipfile with edf files and converts it to a data cell of
%the selected channel. also saves the original subject number, total number of
%subjects and number of conditions.
unzip(zip_file_name,'..\DATA_DIR\');        %unziping the data.

%first filter: files will contain only files in 'DATA_DIR' folder and subfolders
%that end with '.edf'.
files = dir('..\DATA_DIR\**/*.edf');

%This is the allowed pattern. The first digits that shown will be stored as
%subject number, next, the letter after 'E' will be stored as eye condition.
look_str = '(?<subject_number>\d+).+E(?<eyes>[CO])';



%Generally, for each file in files (that contain only the edf files), this loop
%will check and extract the details from the file name. Using edfread will read
%the file and store the relevant information.

%The genral idea of the loop - we want to be able to get any subject number and
%to sort them by index (for easier analyze next) while keeping their subject ID.
%for doing that, after making sure that the file name is according to the
%requasted pattern, we use 'subject index' that increases by one only if the
%current subject id is not the same as the last one id.

%preparing memory - 1st row is for subject id and 2/3 are for each condition.
%the length is number of files divided by number of conditions.
nrows = conditions_num+1;
ncol = length(files)/conditions_num;
datacell = cell(nrows,ncol);

subject_index = 0;
last_subject = '0';
for i = 1:length(files)
    current_str = string(files(i).name);
    
    %checks if file name(current_str) is fit for the allowed pattern (look_str).
    %if it's not, error msg is shown. if it is, it stores it in temp variable.
    current_data = regexp(current_str,look_str,'names');
    if isempty(current_data) == 1
        error('unvalid file name: %s' ,current_str)
    end
    
    %fullfile helps us to apply special function ('edfread') on files that are
    %not in the current folder. Using this function we provide the full path for
    %the files. In temp_data we store the relvant data matrix (not by channel
    %yet).
    current_file = fullfile(files(i).folder,files(i).name);
    [~, temp_data] = edfread(current_file);
    
    
    %if the subject id is diffrent from the last id ('last subject') the
    %'subject_index' increase by 1 and insert the id subject to the first row.
    if strcmp(last_subject,current_data.subject_number) == 0
        subject_index = subject_index+1;
        
        datacell{1,subject_index} = char(current_data.subject_number);
    end
    
    %Eyes Close/Open data from channel will be stored in row 2/3.
    if current_data.eyes == "C"
        datacell{2,subject_index} = temp_data(channel,:);
        
    elseif current_data.eyes == "O"
        datacell{3,subject_index} = temp_data(channel,:);
        
    end
    
    %saves last subject's id for comparing in the next file.
    last_subject = current_data.subject_number;
    
end


%setting number of subjects & conditions for later.
number_subjects = length(datacell);



end

