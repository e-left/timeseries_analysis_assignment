% This function tests on whether a given timeseries is pure white noise or
% not. It does this with two methods to be sure. First, it creates the auto
% correlation plot and then performs a Ljung-Box test.
% INPUTS 
% - x                   : vector of length 'n' of the time series
% - dispAutocorr        : boolean variable - true if you want to display ACF (default)
% OUTPUTS
% - isWhiteNoise        : boolean value of whether the timeseries is
%                         White-Noise (==1) or not (==0)
function isWhiteNoise = isTimeseriesWhiteNoise(x, dispAutocorr, timeseriesName)
    maxLag = min(20, length(x)-1);  % https://robjhyndman.com/hyndsight/ljung-box-test/
                                    % If L is too small, the test does not detect high-order autocorrelations
                                    % If L is too large, the test loses power when a significant correlation at one lag is washed out by insignificant correlations at other lags
                                    % Box, Jenkins, and Reinsel suggest the setting Lags=min[20,T-1]
                                    % Box, George E. P., Gwilym M. Jenkins, and Gregory C. Reinsel. Time Series Analysis: Forecasting and Control. 3rd ed. Englewood Cliffs, NJ: Prentice Hall, 1994
    
    % Default value for dispAutocorr
    if nargin < 2
        dispAutocorr = true;
    end
   
    %% Using auto-correlation plots
    if dispAutocorr == true
        figure;
        autocorr(x, NumLags=maxLag);
        title(['Auto-correlation coefficients for lags 1 through ', num2str(maxLag)])
        ylabel('Auto-correlation coefficients')
        if nargin > 2
            subtitle(['Timeseries: ', timeseriesName])
        end
    end

    %% Perform Ljung-Box test
    % https://timeseriesreasoning.com/contents/white-noise-model/
    significanceLevel = 0.05;
    [h, ~, ~, ~] = lbqtest(x, 'Lags', maxLag, 'Alpha', significanceLevel);
    
    % Check if p-value is below significance level
    if h == 0 
        % Failure to reject the no residual autocorrelation null hypothesis.
        isWhiteNoise = true;
    else
        % Rejection of the no residual autocorrelation null hypothesis 
        % A p-value of less than 0.05 indicates a significant auto-correlation that cannot be attributed to chance
        isWhiteNoise = false;
    end
end