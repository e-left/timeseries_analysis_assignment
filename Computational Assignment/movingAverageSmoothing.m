% This function makes a smoothing of the given time series using a 
% moving average filter of a given order. It makes use of the 'filtfilt'
% Matlab function and produces a time series of the same length as the
% given time series with the first and last order/2 values being somehow
% estimated by the filter.
% INPUTS 
% - x               : vector of length 'n' of the time series
% - order           : the maorder of the moving average filter
% OUTPUTS
% - x_smoothed      : vector of length 'n' of the smoothed time series
function x_smoothed = movingAverageSmoothing(x, order) 
    n = length(x);
    x = x(:);
    if order > 1
        b = ones(1, order)/order;
        x_smoothed = filtfilt(b, 1, x);
    else
        x_smoothed = NaN*ones(n, 1);
    end
end