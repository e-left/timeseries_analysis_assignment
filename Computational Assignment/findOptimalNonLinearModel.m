% This function searches for the optimal non linear model given ranges for tau, m and nNeighboors
% The search process is the following:
% First, we start by iterating over every tau value
% For every possible value for tau, we construct a three dimensional matrix for the values of m, q and nNeighboors
% In that matrix, m and nNeighboors get every possible value, while q ranges from 0 up to m
% For each of that we calculate 2 things:
% 1. NRMSE for 1 timestep prediction
% 2. If the residual timeseries from the prediction is i.i.d.
% For the selection, we consider only models that satisfy criterion 2. Then, we aim to minimize criterion 1 for each 3D
% matrix for a given value of tau, to get for each value of tau a tuple (tauValue, m, q, nNeighboors, NRMSE). Amongst all of
% these tuples, we return the one that minimizes the total NRMSE
% INPUTS:
% - x                      : vector of a scalar time series
% - tauValues              : vector of possible tau values
% - mValues                : vector of possible m values
% - nNeighboorsValues      : vector of possible number of neighboors values
function [tau, m, q, nNeighboors, NRMSEfit] = findOptimalNonLinearModel(x, tauValues, mValues, nNeighboorsValues)
    % Hold final models here
    finalModels = [];

    % Start the loops. First iterate over each tau value
    for iTau = 1:length(tauValues)
        tau = tauValues(iTau);
        % Iterate over m
        for iM = 1:length(mValues)
            m = mValues(iM);
            % Iterate over number of neighboors
            for iN = 1:length(nNeighboorsValues)
                n = nNeighboorsValues(iN);
                % Iterate over q
                for q = 1:m
                    % Perform fitting and get NRMSE
                    [nrmseModel, pred] = localfitnrmse(x, tau, m, 1, n, q);

                    % Get residuals
                    % Get first and last element of time series since they depend on the parameters
                    firstElement = pred(1, 1);
                    lastElement = pred(end, 1);

                    % Grad predictions
                    predictions = pred(:, 2);

                    % Grab true values
                    target = x(firstElement:lastElement);

                    % Transform both into columns
                    predictions = predictions(:);
                    target = target(:);

                    % Calculate residuals
                    res = target - predictions;

                    % If residuals are i.i.d. add to matrix
                    if isTimeseriesIID(res)
                        thisModel   = [tau, m, q, n, nrmseModel];
                        finalModels = [finalModels; thisModel]; %#ok<AGROW>
                    end
                end
            end
        end
    end

    % If no good models were found, return an error
    if isempty(finalModels) 
        error("Suitable model not found")
    end

    % Return the model with the minimal NRMSE
    % First, find the index of the minimal NRMSE
    [~, minimalNRMSEIdx] = min(finalModels(:, 5));
    % Then, return the optimal model
    optimalModel = finalModels(minimalNRMSEIdx, :);
    tau = optimalModel(1);
    m = optimalModel(2);
    q = optimalModel(3);
    nNeighboors = optimalModel(4);
    NRMSEfit = optimalModel(5);
end