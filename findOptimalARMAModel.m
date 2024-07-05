% This function finds the optimal ARMA model for a given time series by searching the grid of p and q values
% and selecting the model with the minimum AIC value. It then checks if the residuals of the selected model
% are white noise, and if not, continues searching for a better model.
% INPUTS 
% - x               : vector of a scalar time series
% - maxSearch_p     : maximum value for p for the grid search
% - maxSearch_q     : maximum value for q for the grid search
% - timeseriesName  : name of the time series for display purposes
% OUTPUTS
% - best_p          : the best value found for p in the grid search (one with minimum AIC)
% - best_q          : the best value found for q in the grid search (one with minimum AIC)
% - res             : residuals of the selected ARMA model
% - arma_model      : the ARMA model object
function [best_p, best_q, res, arma_model] = findOptimalARMAModel(x, maxSearch_p, maxSearch_q, timeseriesName)
    % Based on the behavior of both ACF and PACF graphs, we search the grid for p=0:maxSearch_p 
    % and q = 0:maxSearch_q to find the best model
    aicHeatmap = gridSearch_AIC(x, maxSearch_p, maxSearch_q);
    
    % Plot heatmaps to find optimal model
    % We wish to minimize AIC 
    figure;
    heatmap(aicHeatmap, "XData", 0:maxSearch_q, "YData", 0:maxSearch_p);
    title(['AIC Heatmap - Timeseries: ', timeseriesName])
    xlabel("q");
    ylabel("p");
        
    % Flatten and sort out AIC array
    aic_flattened = reshape(aicHeatmap, [], 1);
    aic_flattened_sorted = sort(aic_flattened);
    
    % Start from the first entry
    i = 1;
    % We have not yet found a good model
    foundGoodModel = false;
    
    % Loop starting from the model with the minimum AIC until we find one
    % with a good fit (that means residuals are white noise)
    while ~foundGoodModel && (i <= length(aic_flattened_sorted))
        currentAIC = aic_flattened_sorted(i);
        [best_p, best_q] = find(aicHeatmap == currentAIC);
        % Go from 1 based indexing to 0 based indexing
        best_p = best_p - 1;
        best_q = best_q - 1;
    
        % We check the residuals
        [~, ~, ~, ~, ~, arma_model] = fitARMA(x, best_p, best_q);
        [res, ~] = resid(x, arma_model);
    
        % Check if residuals are white noise
        if isTimeseriesWhiteNoise(res, false)
            fprintf("ARMA(%d, %d) is a good model for x1\n", best_p, best_q);
            foundGoodModel = true;
        else
            fprintf("ARMA(%d, %d) is a bad model for x1\n", best_p, best_q);
        end 
    
        % Increment search index
        i = i + 1;
    end
end