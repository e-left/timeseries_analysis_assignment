% This function calculates the moving average trend of the given time series for a
% certain training and validation size and a window size of 5.
% INPUTS
% - x                       : vector of a scalar time series
% - trainingSize            : size of the training set
% - validationSize          : size of the validation set
% OUTPUT
% - movingAverageTrend      : vector of the moving average trend
function movingAverageTrend = movingAverageTrendEstimation(x, trainingSize, validationSize)
    % Add trend back to predictions
    movingAverageDetrendingWindowSize = 5;

    % Calculate moving average trend
    movingAverageTrend = zeros(validationSize, 1);
    for k = 1:movingAverageDetrendingWindowSize
        movingAverageTrend = movingAverageTrend + ...
            x((trainingSize - movingAverageDetrendingWindowSize + k + 1):(trainingSize - movingAverageDetrendingWindowSize + k + validationSize));
    end

    % Normalize the moving average trend
    movingAverageTrend = movingAverageTrend ./ movingAverageDetrendingWindowSize;
end