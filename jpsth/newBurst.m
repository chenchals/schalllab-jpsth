function [ oStruct ] = newBurst( spikeTimes, period )
%NEWBURST 

% see Legendy CR and Salcman M 1985 
% Bursts and recurrences of bursts in the spike trains of spontaneously
% active striate cortex neurons.
% J. Neurophysiol 53, 926-939
%
% Legendy Algorithm:
% Degree of surprise(S) of burst given an expectation of avg. Poisson process 
% S = -log(P)
%   P is probability that in a random Poisson process given 
%     r avg. spike rate of the spike train
%     T interval of time that contains
%     n or more spikes
% P = exp(-rT) * SUM((rT)^i/i!) for i = n to inf
%






end

