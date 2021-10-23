function [freq_x,dft_y] = DFT(data,window_size,overlap,fs)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

%time settings
dt = 1/fs;
dur = length(data)/fs;                  % duration of signal [sec]
t = 0:dt:dur;                           % times vector [sec]
N = length(t);                          % number of time components
freq_x = (0:round((N-1)/2))/(N*dt);     % the first half of freq.
N1 = length(freq_x);                    % number of freq.
                       

%W matrix
%first we prepare the constant 'w' expreassion. then,using meshgrid, we prepare 2 square matrix
%in the size of 'window_size': each one starts from 0 and runung by one until
%getting to 'window_size-1'. they do it in different direcation (by column/row).
%next, in W, we first dot multiply I & J in order to get the right multiplication for each
%location in W. last, using power rules, we make sure that the power of every
%element will fit the formula.
w = exp(-2*pi*1i/window_size);                          
[I, J] = meshgrid (0:(window_size-1), 0:(window_size-1));     
W = (w.^((I).*(J)));        


%using buffer function, we split the long data vector into windows at the size
%of 'window_size' and with overlapping at the size of 'overlap'.'nodelay' is
%used for zero padding at the end.
%*each row in the matrix represents a window.
input_mat = buffer(data,window_size,overlap,'nodelay');

%The DFT - according to the furmola, we do matrix multiply and calculate the
%DFT for each window. the output is a matrix of complex numbers in the same size
%of the original input_mat.
output_mat =   W * input_mat;

%mean by row of the power spectra and cutting the vector in half.
dft_y = mean((abs(output_mat/window_size)).^2, 2);
dft_y = dft_y(1:length(dft_y)/2);

%preparing matched freq vector fir dft_y.
freq_x = (1:round((window_size-1)/2))/(window_size*dt);

end

