function [freq_x,ps_y] = FFT(data,fs)
%FFT takes data as vector (from one specific channel) and calculate the power
%spectra using fft function.
%the output is x & y vectors for ploting the results.

dt = 1/fs;                              % time step [sec]

%time settings
dur = length(data)/fs;                  % duration of signal [sec]
t = 0:dt:dur;                           % times vector [sec]
N = length(t);                          % number of time components
freq_x = (0:round((N-1)/2))/(N*dt);     % the first half of freq.
N1 = length(freq_x);                    % number of freq.

%calculating the power spectra.
ft= fft(data);                          %fft the input.                          
ft= ft/length(ft);                      %normalizing the fft by it length.
ps_y = abs(ft).^2;                      %calculat the power spectra.

ps_y = ps_y(1:N1);                      %taking only the first half.
end

