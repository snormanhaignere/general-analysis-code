function FT = missing_values_of_2DFT_for_real_sig(FT)

% Fills in missing values in the 2D fourier transform of a real signal, based on
% symmetries in the signal. Computes a twice flipped and conjugated 2DFT, and
% replaces any NaN values in the original 2DFT with these values. 
% 
% -- Example --
% 
% % FT of a real signal
% FTX = fft2(randn(6,6));
% FTX_shifted = fftshift_nyqlast(FTX);
% f_shifted = fftshift_nyqlast(fft_freqs_from_siglen(6,1));
% 
% % remove negative columns
% FTX_shifted_missing_values = FTX_shifted;
% FTX_shifted_missing_values(:,f_shifted < 0) = NaN;
% FTX_missing_values = ifftshift_nyqlast(FTX_shifted_missing_values);
% 
% % restore columns
% FTX_restored = missing_values_of_2DFT_for_real_sig(FTX_missing_values);
% FTX_restored_shifted = fftshift_nyqlast(FTX_restored);
% 
% % compare
% FTX - FTX_restored
% 
% % plot 
% figure;
% set(gcf, 'Position', [0 0 1000 250])
% subplot(1,3,1);
% imagesc(f_shifted, f_shifted, abs(FTX_shifted),[0 11]);
% set(gca,'YDir','normal', 'XTick', f_shifted, 'YTick', f_shifted);
% xlabel('Freq (Pi Radians)'); ylabel('Freq (Pi Radians)');
% title('original mag');
% subplot(1,3,2);
% imagesc(f_shifted, f_shifted, abs(FTX_shifted_missing_values),[0 11]);
% set(gca,'YDir','normal', 'XTick', f_shifted, 'YTick', f_shifted);
% title('missing mag');
% subplot(1,3,3);
% imagesc(f_shifted, f_shifted, abs(FTX_restored_shifted),[0 11]);
% set(gca,'YDir','normal', 'XTick', f_shifted, 'YTick', f_shifted);
% title('restored mag');

% rearrange FT so that the DC is in the middle and the nyquist is last
% easier to think about
FT = fftshift_nyqlast(FT);

% create twice flipped and conjugated signal
FT_conj_flipped = conj(FT);
for i = 1:2
    
    % size of the ith dimension
    N = size(FT, i);
    
    % frequencies in the ith dimension
    freqs = fftshift_nyqlast(fft_freqs_from_siglen(N, 1));
    
    % negative and positive frequencies, excluding the DC and nyquist
    n_neg_freqs = sum(freqs<0);
    freqs_to_flip = [1:n_neg_freqs, (1:n_neg_freqs) + n_neg_freqs + 1];
    
    % flip the appropriate dimension
    if i == 1
        FT_conj_flipped(freqs_to_flip,:) = flipud(FT_conj_flipped(freqs_to_flip,:));
    elseif i==2
        FT_conj_flipped(:,freqs_to_flip) = fliplr(FT_conj_flipped(:,freqs_to_flip));
    else
        error('i must be 1 or 2, not %d', i);
    end
    
end

% replace NaN values with conjugated and flipped values
FT(isnan(FT)) = FT_conj_flipped(isnan(FT));

% shift back such that DC is first and nyquist is in the middle
FT = ifftshift_nyqlast(FT);

