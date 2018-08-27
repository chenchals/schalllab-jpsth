function [ t, y, components ] = test_createSeries(maxTime, frequencies, amplitudes)
%TEST_CREATESERIES Summary of this function goes here
%   Detailed explanation goes here

 % Arbitarary time series
 t = linspace(0,maxTime)';
 % sine wave fx
 fx_y = @(freq, ampl) ampl * sin(2*pi*freq*t);
 % Component sine waves
 components = arrayfun(fx_y,frequencies(:)',amplitudes(:)','UniformOutput', false);
 components = cell2mat(components);
 % Summed sine waves
 y = sum(components,2);
 
end
