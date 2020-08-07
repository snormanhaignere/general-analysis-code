function [y, seg_onset_smps] = concat_with_crossfade(S, seg_order, sr, rampdur_sec, varargin)

% Concatenates a set of segments with cross-fading.
% 
% -- Arguments --
% 
% S: Structure specifying the segments.
% 
% S.seg: a cell array containing waveforms or audio files
% 
% S.onset: the onset of the segment to excerpt from the waveform, if using
% entire waveform, set to 0, if the onset in a single number, we assume
% that the onset is the same for all segments
% 
% S.dur: the duration of each segment to excerpt, if using entire waveform
% set to the duration of the waveform, if the duration in a single number,
% we assume that the duration is the same for all segments
% 
% S.level: RMS level of the segment, if the level in a single number,
% we assume that the duration is the same for all segments
% 
% S.directory: directory containing the audio files
% 
% seg_order: the ordering of the segments, i.e. S.seg(seg_order) gives the
% segment sequence
% 
% sr: audio sampling rate to use
% 
% rampdur_sec: duration of hanning window applied to each segment
%
% -- Optional Inputs --
% 
% All optional inputs specified as key value pairs (..., 'key', value, ...)
% 
% justramps: return just ramps which is useful for verifying cross-fading
% 
% -- Outputs --
% 
% y: output sequence
% 
% seg_onset_smps: onset of each segment in the sequence in samples

%% Optional arguments

clear I;
I.justramps = false;
I = parse_optInputs_keyvalue(varargin, I);

%% Setup

n_seg = length(S.seg);
rampdur_smp = round(rampdur_sec*sr);

% half of the ramp duration in samples
% first and last can be different if odd number of samples
halframpdur_smp1 = floor(rampdur_smp/2);
halframpdur_smp2 = rampdur_smp - halframpdur_smp1;

% expand duration and onset if fixed
if isscalar(S.dur)
    S.dur = ones(size(S.seg))*S.dur;
end
if isscalar(S.onset)
    S.onset = ones(size(S.seg))*S.onset;
end
if isscalar(S.level)
    S.level = ones(size(S.seg))*S.level;
end

%% Excerpt segments with buffer for ramping

seg_with_buffer = cell(1, n_seg);
dur_smp = checkint(sr * S.dur);
onset_smp = checkint(sr * S.onset);
for i = 1:n_seg
    
    % read and resample waveform if file names specified
    if ischar(S.seg{i})
        [wav, orig_sr] = audioread(add_extension([S.directory '/' S.seg{i}]));
        if size(wav,2)==2
            wav = mean(wav,2);
        end
        if orig_sr ~= sr
            wav = resample(wav, sr, orig_sr);
        end
    else
        wav = S.seg{i};
        assert(size(wav,2)==1);
    end
    
    % get a segment with some additional time for windowing
    seg_with_buffer{i} = wav(((1-halframpdur_smp1):(dur_smp(i)+halframpdur_smp2)) + onset_smp(i));
    
    % rms normalize
    current_rms_level = sqrt(mean(seg_with_buffer{i}((halframpdur_smp1+1):(end-halframpdur_smp2)).^2));
    seg_with_buffer{i} = S.level(i) * seg_with_buffer{i} / current_rms_level;
end

%% Stitch segments together with cross-fading

total_smps = sum(dur_smp(seg_order));
if I.justramps
    y = zeros(total_smps, length(seg_order));
else
    y = zeros(total_smps, 1);
end
seg_onset_smps = cumsum([0; dur_smp(seg_order(1:end-1))])+1;
for i = 1:length(seg_order)
    
    seg = seg_with_buffer{seg_order(i)};
    win = ramp_hann(ones(size(seg)), rampdur_sec, sr);
    windowed_seg = win.*seg;
    
    % this is where we want to put the first segment
    ideal_location = ...
        ((1-halframpdur_smp1) : (dur_smp(seg_order(i))+halframpdur_smp2)) ...
        + seg_onset_smps(i)-1;
    assert(length(seg)==length(ideal_location));
    
    % but only some locations are valid
    xi = ideal_location >= 1 & ideal_location <= total_smps;
    
    % add the valid timepoints
    if I.justramps
        y(ideal_location(xi), i) = win(xi);
    else
        y(ideal_location(xi)) = y(ideal_location(xi)) + windowed_seg(xi);
    end
        
end
