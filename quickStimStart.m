% quickStimStart.m
%
% initialize an NI DAQ session for quickStim
%

function ap = quickStimStart()

    % DEFINE INPUT PARAMETERS
    ap = struct();               % Backbone structure
    ap.FS = 30000;               % Piezo signal sampling rate hz

    %set up piezo channels for tactile stim
    ap.piezoDriver = daq.createSession('ni');
    addAnalogOutputChannel(ap.piezoDriver, 'Dev1', [0 1], 'Voltage');
    ap.piezoDriver.Rate = ap.FS; %sampling rate
    
    ap.cameraTrigger = daq.createSession('ni');
    addDigitalChannel(ap.cameraTrigger,'dev1','Port1/Line7', 'OutputOnly');
    outputSingleScan(ap.cameraTrigger,0); %turn on capacitive sensor

end