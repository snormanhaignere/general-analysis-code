function [px_pos_freq, f] = fftplot2(sig,sr,varargin)
% [px_pos_freq, f] = fftplot2(sig,sr,varargin)
% 
% Wrapper function for the matlab fft command.
% Plots the power spectrum of the input signal in units of "power per Hz per sample".
% Input signal is assumed to be real and only positive frequencies are plotted.
% 
% sig is the input vector (column or row vector). sr is the sampling rate of the vector in Hz.
% 
% The number of samples used to compute the fft ("nfft") can be specified
% by including 'nfft', NUMBER_OF_SAMPLES as input arguments. 
% By default, nfft is set to the number of samples in the input signal. 
% If the number of samples in the input signal is not a multiple of nfft,
% the input signal is zero-padded. Otherwise, no padding is used.
% The amount of padding is taken into account when estimating the power spectrum of the signal.
% 
% px_pos_freq is a vector with the power at each positive frequency
% (in units of power per frequency-bin per sample, not power per Hz per sample).
% The sum of px_pos_freq equals the average power of the signal (i.e. mean(sig.^2)).
% 
% f is the frequency in Hz of each bin
% 
% Example
% sr = 20000; % 20 kHz sampling rate
% [B,A] = butter(4,[1000,2000]/(sr/2));
% sig = filtfilt(B,A,randn(sr,1)); % bandpass signal
% px_pos_freq = fftplot2(sig,sr,'nfft',2^11);
% mean(sig.^2)
% sum(px_pos_freq)
% 
% Last modified by Sam Norman-Haignere on 12/28/2014

% column vector
if size(sig,2) ~= 1;
    sig = transpose(sig);
end
if size(sig,2) ~= 1
    error('fftplot2 expects the input signal to be a single row or column vector');
end

% fft size
nfft = length(sig);
if optInputs(varargin, 'nfft')
    nfft = round(varargin{optInputs(varargin, 'nfft')+1});
end

% input matrix if length(wav) > nfft
if length(sig) > nfft % divide the input into a matrix of non-overlapping vectors 
    n_full_columns = floor(length(sig)/nfft);
    wav_matrix = reshape(sig(1:nfft*n_full_columns), nfft, n_full_columns);
    n_remaining_samples = rem(length(sig),nfft);
    if n_remaining_samples ~= 0 % zero pad if necessary
        last_column = [sig((1:n_remaining_samples) + nfft*n_full_columns); zeros(nfft-n_remaining_samples,1)];
        wav_matrix = [wav_matrix, last_column];
    end
    n_nonzero_samples = n_full_columns*nfft + n_remaining_samples;
elseif length(sig) < nfft % zero pad
    wav_matrix = [sig; zeros(nfft-length(sig),1)];
    n_nonzero_samples = length(sig);
else
    wav_matrix = sig;
    n_nonzero_samples = length(sig);
end

% fft normalized appropriately to satisfy parseval's theorem
% summed across multiple columns if present
px = sum(abs(fft(wav_matrix)).^2 / nfft, 2);

% normalized by the number of samples
% this gives the magnitude spectrum in power per frequency bin per sample
% which is the spectrum level if nfft == sr
px_per_sample = px / n_nonzero_samples;

% maximum positive frequency in samples, the nyquist if nfft is even
% if nfft is 4, frequencies of the dft are 2*pi*[0, 1, 2, 3]/4
% in which case the third sample is the nyquist
% if nfft is 5, then the frequencies of the dft are 2*pi*[0, 1, 2, 3, 4]/5
% in this case, third sample is the maximum positive frequency but not the nyquist
max_pos_freq = ceil((nfft+1)/2); 

% remove negative frequencies while preserving total power
if mod(nfft,2)==0 % if nyquist present
    px_pos_freq = [px_per_sample(1); 2*px_per_sample(2:max_pos_freq-1); px_per_sample(max_pos_freq)];
else
    px_pos_freq = [px_per_sample(1); 2*px_per_sample(2:max_pos_freq)];
end

% frequency vector in Hz
f = sr*(0:max_pos_freq-1)/nfft;

% add transfer function if specified
if optInputs(varargin,'tf');
    tf = varargin{optInputs(varargin, 'tf')+1};
    gain = myinterp1(log2(tf.f), tf.px, log2(f(2:end)), 'pchip')';
    px_pos_freq(2:end) = px_pos_freq(2:end) .* 10.^(gain/10);
end

if optInputs(varargin, 'noplot')
    return;
end

% plot spectrum level
bin_width_in_Hz = sr/nfft;
plot(log2(f(:)),10*log10((1/bin_width_in_Hz)*px_pos_freq), 'k','LineWidth',1);
xlim([min(log2(f(:))), max(log2(f(:)))]);
xtick = get(gca,'XTick');
set(gca, 'XTick', xtick, 'XTickLabel', 2.^xtick);