function expected_r = correlation_power_analysis(measured_r, N, plot_figure)
% function correlation_power_analysis(measured_r, N, plot_figure)
% 
% Given a measured test-retest correlation value, this function computes
% the expected correlation if the number of data points was
% increased by a factor of N. The variable N can be a vector
% in which case the function returns the expected correlation
% for each value of N.
%
% Equivalent to the "spearman-brown" prediction formula.
% http://en.wikipedia.org/wiki/Spearman-Brown_prediction_formula
% 
% Example:
% correlation_power_analysis(0.5,2.^(0:4),1);
% 
% 2014-12-26: Created by Sam NH
% 
% 2016-01-27: Modified to handle negative correlation values appropriately (assumes negative correlations are genuine)
% correlation_power_analysis(0.5,2.^(0:4),1);
% correlation_power_analysis(-0.5,2.^(0:4),1);

N = sort(N);
expected_r = N * (sign(measured_r) .* abs(measured_r)) ./ (1-abs(measured_r)+N*abs(measured_r));
if plot_figure
    plot(log2(N),expected_r,'k-o','LineWidth',2)
    xlabel('N');
    xtick = get(gca, 'XTick');
    set(gca, 'XTick', xtick, 'XTickLabel', 2.^xtick);
    ylabel('Expected Correlation (r)');
end

