% This function calculates the NRMSE values for the ARMA model with trend
% INPUTS:
% - x                      : vector of a scalar time series
% - modelPredictions       : matrix of the model predictions
% - method                 : method to add the trend back to the model predictions
% - Tmax                   : number of predictions to make
% - trainingSize           : size of the training set
% - validationSize         : size of the validation set
% OUTPUT:
% - NRMSEValues            : vector of NRMSE values for each prediction
function NRMSEValues = calculateNRMSEForARMAWithTrend(x, modelPredictions, method, Tmax, trainingSize, validationSize)
    % Check if input method is valid
    if strcmp(method, 'addEstimatedTrendFunction') || strcmp(method, 'differencing')
        % Calculate the model predictions with the trend
        modelPredictionsTrended = timeseriesPredTrending(x, modelPredictions, method, trainingSize, validationSize, Tmax);
    else
        error('Invalid method');
    end

    % Calculate NRMSE using the model predictions with the trend and the original data
    NRMSEValues = zeros(Tmax, 1);
    for k = 1:Tmax
        NRMSEValues(k) = nrmse(x((trainingSize + k):end), modelPredictionsTrended(k:end, k));
    end
end