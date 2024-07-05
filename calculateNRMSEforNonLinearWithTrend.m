% This function calculates the NRMSE for a non-linear model with a trend
% INPUTS:
% - x                      : vector of a scalar time series
% - modelPredictions       : matrix of the model predictions
% - method                 : method to add the trend back to the model predictions
% - Tmax                   : number of predictions to make
% - trainingSize           : size of the training set
% OUTPUT:
% - NRMSEValues            : vector of NRMSE values for each prediction
function NRMSEValues = calculateNRMSEforNonLinearWithTrend(x, modelPredictions, method, Tmax, trainingSize)
    % Check if input method is valid
    if strcmp(method, 'addEstimatedTrendFunction') || strcmp(method, 'differencing')
        % Calculate the model predictions with the trend
        predModel2NonLinearTrended = timeseriesPredTrendingNonLinear(x, modelPredictions, method, Tmax);
    else
        error('Invalid method');
    end

    % Calculate NRMSE using the model predictions with the trend and the original data
    NRMSEValues = zeros(Tmax, 1);
    lastElement = predModel2NonLinearTrended(end, 1);
    for k = 1:Tmax
        NRMSEValues(k) = nrmse(x((trainingSize + k):lastElement), predModel2NonLinearTrended(k:(lastElement - trainingSize), k + 1));
    end
end