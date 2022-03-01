function processWaveformForKINARM()

% The purpose of this script is to filter and then decimate an arbitrary
% waveform so that it can be used with a Task Program and a KINARM
% It requires 
% 
%% Step 1 - Load sound 
% A recorded sound needs to be loaded into MATLAB. This sound can be from any
% source. The code below shows two methods: one from a .MAT file and one from a
% .WAV file  

% e.g. load sound waveform from .MAT file
% load('PianoKey28(C)44100Hz.mat');	% sample piano sound (see copyright below)
% waveform = y(:,1);			% this sample happens to be stereo. Turn it into a mono signal for this example.
% freqInput = 44100;		% sampling frequency of the original source waveform (Hz)

% OR e.g. load sound waveform from .WAV file
[waveform, freqInput] = audioread('pop1.wav');
waveform = waveform(:,1);			% this sample happens to be stereo. Turn it into a mono signal for this example.

% Print warning to user to ensure that the correct filter coefficients are used...
fprintf('Sampling Frequency of waveform is %d Hz. Make sure that filter coefficients are correct.\n', freqInput);

%% Step 2 - Specify output waveform parameters
% the update rate for a task using R2015a or higher with Dexterit-E is 4 kHz.
% For R2013a and previous, the update rate is 2 kHz.  
freqOutput = 4000;		% update rate of the model to be run on the KINARM's robot computer


%% Step 3 - determine the filter coeffients.
% In order to avoid aliasing issues, the waveform should not contain
% frequencies higher than 1/2 the frequency at which the sound will be
% played (i.e. the update rate of the model). 
%
% As per below, this script uses a double-pass filtering technique. This
% double-pass approach not only minimizes the effects of phase shifting,
% but also shifts the 3 dB cutoff frequency to a lower frequency. For
% example, if the nominally specified filter is 3rd order, 3 dB @ 2 kHz,
% then the double-pass variant produces an overall filter of 6th order
% magnitude with 3 dB cutoff frequency of ~1.73 kHz.   

% The following coeffients are from NuHertz's Filter Free
% (http://www.nuhertz.com/) 
% Once the filter has been specified, click on the Synthesize filter button and
% in the new dialog click on the Vec button and then click on the Copy Num/Den
% button and paste here.  

% 2 kHz, 3rd order Butterworth filter with a sampling frequency of 44100 Hz  
NUM = [2.21770132e-03, 6.65310395e-03, 6.65310395e-03, 2.21770132e-03];
DEN = [1, -2.43191667, 2.01412566, -.564467379];

% 2 kHz, 3rd order Butterworth filter with a sampling frequency of 22050 Hz  
% NUM = [1.40997088e-02, 4.22991263e-02, 4.22991263e-02, 1.40997088e-02];
% DEN = [1, -1.87302725, 1.30032695, -.314502036];

% 2 kHz, 3rd order Butterworth filter with a sampling frequency of 11025 Hz  
% NUM = [7.818039e-02, .23454117, .23454117, 7.818039e-02];
% DEN = [1, -.793433605, .501017505, -8.21407799e-02];



%% Step 4 - filter the waveform.
% The commands below implement a double-pass filter.

filteredWaveform1 = filter(NUM, DEN, waveform);
filteredWaveform2 = fliplr(filteredWaveform1);
filteredWaveform3 = filter(NUM, DEN, filteredWaveform2);
filteredWaveform = fliplr(filteredWaveform3);


%% Step 5 - scale the waveform.
% The specification for audio line out is +/-1 V. The following autoscales
% the sound so that it is maximally loud, without clipping. This factor can
% be manually set. 
scalingFactor = 1 / max(abs(filteredWaveform));

% Scale the waveform so that it is an appropriate amplitude for +/- 1 V
waveform = waveform * scalingFactor;
filteredWaveform = filteredWaveform * scalingFactor;

%% Step 6 - Re-sample to the model's update rate
% The final waveform needs to be re-sampled to the update rate of the model
% (freqOutput). 

tInput = (1:length(filteredWaveform)) / freqInput;
tOutput = (1:floor( length(filteredWaveform) * freqOutput / freqInput) ) /freqOutput;
outputWaveform = spline(tInput, filteredWaveform, tOutput );

save('sampleSound', 'outputWaveform');

%% Step 7 - Play the original, filtered and re-sampled sounds to ensure that the final version sounds correct  

pauseDuration = length(waveform) / freqInput + 1;
sound(waveform, freqInput);
pause(pauseDuration)
sound(filteredWaveform, freqInput);
pause(pauseDuration)
sound(outputWaveform, freqOutput);

%% Copyright 
% The following is from the copyright for the original sound files of the
% piano key 
% Copyright (c) 2010, Kristofer
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.





