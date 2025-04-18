% quickStim.m
% [] = quickStim(ap,dur,rampDur,freq,amp)
% 
% A quickly modified version of the tactile piezo stimulus code 
% taken from StimulatorGUI.m
% mduhain <2025-01-22>
%
% RUN INITIALIZATION FUNTION FIRST
% >> ap = quickStimStart()
%
% THEN USE STRUCT "ap" AS INPUT HERE
% >> quickStim(ap,dur,rampDur,freq,amp);
%
% INPUT RANGES
%   ap = handle from quickStimStart();
%   dur = duration (ms)
%   rampDur = voltage ramp ON/OFF duration (ms)
%   freq = frequency (hz) 
%   amp = amplitude (mV) 0-3V range

function [] = quickStim(ap,dur,rampDur,freq_hz,amp_mv)

    % DEFINE INPUT PARAMETERS
    % ap = struct();                  % Backbone structure
    % ap.FS = 20000;                  % Piezo signal sampling rate hz
    ap.stim_dur = dur;                % Stimulus duration in milliseconds
    ap.stim_amp = amp_mv/1000;        % Volt range (in volts +/-) for bipolar signal
    ap.stim_freq = freq_hz;           % Hz (cycles per second)
    ap.stim_volt_ramp_dur = rampDur;  % Millisecond duration of ramp-up & ramp-down

    % Create total stimulus time (ms) with two voltage ramps
    ap.stim_dur_wRamps = ap.stim_dur + 2*ap.stim_volt_ramp_dur;

    % Convert stim_dur back to seconds and multiple by sampling rate 
    ap.stim_space = zeros(ap.stim_dur/1000*ap.FS,1);

    % Blank time values for generating sine wave
    loc_t = 0:1/ap.FS:ap.stim_dur_wRamps/1000 - 1/ap.FS;

    % Create signal
    ap.stim_space = sin(2*pi*loc_t*ap.stim_freq);

    % Trim edges with voltage ramp
    t1 = (ap.stim_volt_ramp_dur / 1000) * ap.FS;
    t2 = t1 + ((ap.stim_dur / 1000) * ap.FS);
    rampUp = linspace(0,ap.stim_amp,t1);
    rampDown = linspace(ap.stim_amp,0,t1);
    ap.stim_space(t1+1:t2) = ap.stim_space(t1+1:t2) .* ap.stim_amp;
    ap.stim_space(1:t1) = ap.stim_space(1:t1) .* rampUp; %apply ramp UP
    ap.stim_space(t2+1:end) = ap.stim_space(t2+1:end) .* rampDown;

    % Check for accurate stimulus creation
    % locXVals = linspace(0,ap.stim_dur_wRamps,length(ap.stim_space));
    % figure; plot(locXVals, ap.stim_space);

    % %set up piezo channels for tactile stim
    % ap.piezoDriver = daq.createSession('ni');
    % addAnalogOutputChannel(ap.piezoDriver, 'Dev1', [0 1], 'Voltage');
    % ap.piezoDriver.Rate = ap.FS; %sampling rate

    % Que stim delivery
    ap.piezoDriver.queueOutputData([ap.stim_space',(ap.stim_space'.*0)]); 
    
    % Trigger Frame Capture
    outputSingleScan(ap.cameraTrigger,1); % trigger on
    outputSingleScan(ap.cameraTrigger,0); % trigger off
    
    % OPTIONAL PLOT
    % figure; plot([ap.stim_space',(ap.stim_space'.*0)]);

    % Deliver stimulus
    ap.piezoDriver.startBackground();

    %Display unique parameters
    disp(strcat("hz_",num2str(ap.stim_freq),"_mv_",num2str(amp_mv)))
    disp("");
end