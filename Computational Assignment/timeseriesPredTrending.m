% This function adds the trend back to the predictions given by the prediction model
% INPUTS
% - x                   : vector of a scalar time series
% - predModel           : matrix of the model predictions
% - method              : method to add the trend back to the model predictions
% - trainingSize        : size of the training set
% - validationSize      : size of the validation set
% - Tmax                : the predictions given were repeated for each of the 
%                         prediction steps T=1...Tmax
% OUTPUT
% - predModelTrended    : matrix of the model predictions with the trend
function predModelTrended = timeseriesPredTrending(x, predModel, method, trainingSize, validationSize, Tmax)
    predModelTrended = zeros(validationSize, Tmax);
    if strcmp(method, 'differencing')
        % Adding back trend
        % Time Series Course Notes, page 80, equations 91-92
        predModelTrended(:, 1) = x((trainingSize + 1):end) + predModel(:, 1);
        for k = 2:Tmax
            predModelTrended(:, k) = predModelTrended(:, k - 1) + predModel(:, k);
        end

    elseif strcmp(method, 'addEstimatedTrendFunction')
        % Add trend back to predictions
        movingAverageTrend = movingAverageTrendEstimation(x, trainingSize, validationSize);

        % Add it to predictions (extend line)
        for k = 1:Tmax
            predModelTrended(:, k) = predModel(:, k) + movingAverageTrend;
        end
    end
end