% This function adds the trend back to the predictions given by the prediction model
% and a certain method and number of predictions to make
% INPUTS
% - x                   : vector of a scalar time series
% - predModel           : matrix of the model predictions
% - method              : method to add the trend back to the model predictions
% - Tmax                : the predictions given were repeated for each of the
%                         prediction steps T=1...Tmax
% OUTPUT
% - predModelTrended    : matrix of the model predictions with the trend
function predModelTrended = timeseriesPredTrendingNonLinear(x, predModel, method, Tmax)

    predModelTrended = zeros(size(predModel));
    predModelTrended(:, 1) = predModel(:, 1);

    firstElement = predModel(1, 1);
    lastElement = predModel(end, 1);
    if strcmp(method, 'differencing')
        % Adding back trend
        % Time Series Course Notes, page 80, equations 91-92
        predModelTrended(:, 2) = x(firstElement:lastElement) + predModel(:, 2);
        for k = 2:Tmax
            predModelTrended(:, k + 1) = predModelTrended(:, k + 1 - 1) + predModel(:, k + 1);
        end

    elseif strcmp(method, 'addEstimatedTrendFunction')
        trainingSize = firstElement - 1;
        validationSize = length(x) - trainingSize;

        % Add trend back to predictions
        movingAverageTrend = movingAverageTrendEstimation(x, trainingSize, validationSize);
        
        % Keep it only for the elements we actually have
        movingAverageTrend = movingAverageTrend(lastElement - firstElement);

        % Add it to predictions (extend line)
        for k = 1:Tmax
            predModelTrended(:, k + 1) = predModel(:, k + 1) + movingAverageTrend;
        end
    end
end