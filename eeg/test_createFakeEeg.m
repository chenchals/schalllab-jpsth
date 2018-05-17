function [ ts, fakeEeg, components ] = test_createFakeEeg(varargin)
%TEST_CREATEFAKEEEG Summary of this function goes here
%   Detailed explanation goes here
% From: https://www.researchgate.net/post/Do_you_know_any_fx_formulas_for_EEG-like_signal_generation
% Modified: Chenchal

    args = parseArgs(varargin);
    % randomizer for repeatable results
    %rng('default'); % Mersenne Twister with seed 0
    %     % Frequency params
    Fs = linspace(args.freqMin,args.freqMax,args.numberOfSineWaves)';
    %     % time params
    % sample time steps
    ts = linspace(args.minT,args.maxT,args.sRate*args.maxT);
    
    
    if args.randomizePhase
        % random phase difference times  
        %shiftDeg = repmat(0,args.numberOfSineWaves,1); % deg shift for each sine wave
        % random pick 10 deg increments
        shiftDeg = randi(36,args.numberOfSineWaves,1).*10; % deg shift for each sine wave
        periodLength = 1./Fs;
        shiftXvals = (shiftDeg./360).*periodLength; % shift x axis by this amount for each frequency
        % nearest index of ts array to shift
        [~, shiftXind] = arrayfun(@(x) min(abs(ts -x)),shiftXvals,'UniformOutput',false);
        shiftXind = cell2mat(shiftXind);
        %t = arrayfun(@(x) randsample(ts,length(ts)),(1:args.numberOfSineWaves)','UniformOutput',false);
        t = arrayfun(@(x) circshift(ts,x),shiftXind,'UniformOutput',false);
        t = cell2mat(t);      
    else
        t = repmat(ts,args.numberOfSineWaves,1);
    end
    % amplitude of sine waves
    if args.randomAmplitudes
        % amplitudes - Currently random for number of sines
        amplitudes = rand(args.numberOfSineWaves,1);
    else
        amplitudes = ones(args.numberOfSineWaves,1);
    end

    % time varying amplitute scaling -
    if args.randomAmplitudeScaling
        amplitudeScaling = rand(size(t));
    else
        % currently set to 1 for all sine waves across time
        amplitudeScaling = ones(size(t));
    end
    % Compute sine waves
    % time varying sine waves
    components = (amplitudes.*amplitudeScaling).*sin(2*pi*(Fs.*t));
    % sum all sine waves
    fakeEeg = sum(components);
    figure
    plot(ts(1,:),fakeEeg);
    hold on
    plot(ts(1,:),components(1:end,:))
    hold off

end

function out = parseArgs(varargin)
    defaults = {
        {'randomizePhase', true}
        {'randomAmplitudes', false}
        {'randomAmplitudeScaling', false}
        % Frequency params
        {'freqMin', 0}
        {'freqMax', 100}
        {'numberOfSineWaves',100}
        % time params
        {'minT', 0}
        {'maxT', 1}
        {'sRate', 1000}
        };

    parser = inputParser();
    for i = 1: numel(defaults)
        p = defaults{i};
        parser.addParameter(p{1},p{2});
    end
    parser.parse();
    if nargin > 0
        parser.parse(varargin{1}{:});
    end

    out = parser.Results;

end

