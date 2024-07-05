% This function is used for removing the trend on given timeseries x. It can remove the
% trend either by using the first differences (method == 'differencing') or
% by removing an estimated trend function from the timeseries. Here we use
% the moving average (MA(5)) (method == 'removeEstimatedTrendFunction')
% INPUTS 
% - x               : vector of length 'n' of the time series
% - method          : the method to be used to detrend the timeseries (x)
% OUTPUTS
% - detrendedX      : vector of length 'n' of the smoothed time series
function detrended_x = timeseriesDetrending(x, method)
    if strcmp(method, 'differencing')
        % The new series is constructed where the value at the current time 
        % step is calculated as the difference between the original observation
        % and the observation at the previous time step. This has the effect of 
        % removing a trend from our timeseries dataset.
        detrended_x = x(2:end) - x(1:end-1);
        detrended_x = [x(1); detrended_x]; % Add the original value first to keep the 
                                           % number of values in the vector equal to the original

        % Plot the detrended (by differencing) timeseries
        figure;
        plot(detrended_x, '.-')
        xlabel('t')
        ylabel('x(t)')
        title('Detrended timeseries by differencing')
        
    elseif strcmp(method, 'removeEstimatedTrendFunction')
        % Since, on the plot, we saw that we have changes on a short time scale
        % So, the order needed to be a small value as well
        movingAverageOrder = 5;
        smoothedTimeseries = movingAverageSmoothing(x, movingAverageOrder);

        % Plot the timeseries and the smoothed (using MA) timeseries 
        figure;
        plot(x, '.-');
        hold on;
        plot(smoothedTimeseries, '.-r');
        xlabel('t');
        title('Timeseries (with trend)');
        legend('Original x(t)', sprintf('MA(%d) smooth', movingAverageOrder), 'Location', 'Best');
        
        % Calculate the detrended timeseries by removed the smoothed
        % timeseries from the original
        detrended_x = x - smoothedTimeseries;

        % Plot the detrended (by removing the MA) timeseries
        figure;
        plot(detrended_x, '.-')
        xlabel('t')
        ylabel('x(t)')
        title(sprintf('Detrended timeseries by MA(%d) smooth', movingAverageOrder))
    else
        error('Detrending method given is not valid')
    end
end