% This function does a grid search for the best ARMA model using the AIC criterion
% INPUTS
% - x               : vector of a scalar time series
% - maxP            : maximum value for p
% - maxQ            : maximum value for q
% OUTPUTS
% - aicHeatmap      : matrix of AIC values for each combination of p and q
function aicHeatmap = gridSearch_AIC(x, maxP, maxQ)
    aicHeatmap = zeros(maxP + 1, maxQ + 1);
    for p = 0:maxP
        for q = 0:maxQ
            % Calculate AIC value of the model and place it in the matrix
            [~, ~, ~, aic] = fitARMA(x, p, q);
            aicHeatmap(p + 1, q + 1) = aic;
        end
    end
end