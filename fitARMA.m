% This function fits an autoregressive moving average (ARMA) 
% The ARMA model has the form
% x(t) = phi(0) + phi(1)*x(t-1) + ... + phi(p)*x(t-p) + 
%        +z(t) - theta(1)*z(t-1) + ... - theta(q)*z(t-p), 
% z(t) ~ WN(0, sdnoise^2)
% INPUTS:
%  - x       : vector of the scalar time series
%  - p       : the order of the AR part of the model.
%  - q       : the order of the MA part of the model.
% OUTPUT: 
%  - phi          : the coefficients of the estimated AR part (of length
%                 (p+1) with phi(0) as first component.
%  - theta        : the coefficients of the estimated MA part (of length q)
%  - arma_model   : the model structure 
%  - SDz          : the standard deviation of the noise term
%  - aic          : the AIC value for the model
%  - fpe          : the FPE value for the model
function [phi, theta, SDz, aicS, fpeS, arma_model] = fitARMA(x, p, q)    
    % Default value for p
    if isempty(p)
        p = 0;
    end

    % Default value for q
    if isempty(q)
        q = 0;
    end
    
    % Initialization
    x = x(:);
    mx = mean(x);   % Timeseries mean value
    xxV = x-mx;     % Normalization
    
    arma_model = armax(xxV, [p q]); % Estimate armax polynomial model

    %% AR part of the model
    % If p is 0, return an empty vector of coefficients for AR part
    if p == 0
        phi = [];
    else
        phi_firstVal = (1 + sum(arma_model.a(2:p+1)))*mx;
        phi = [phi_firstVal -arma_model.a(2:p+1)];
        
        % Check if AR part is stationary
        rootarV = roots(arma_model.a);
        if any(abs(rootarV) >= 1)
            fprintf('The estimated AR(%d) part of the model is not stationary.\n',p);
        end
    end

    %% MA part of the model
    % If q is 0, return an empty vector of coefficients for MA part
    if q == 0
        theta = [];
    else
        theta = -arma_model.c(2:end);

        % Check if MA part is reversible
        rootmaV = roots(arma_model.c);
        if any(abs(rootmaV) >= 1)
            fprintf('The estimated MA(%d) part of the model is not reversible.\n',q);
        end
    end

    % Calculate model's metrics
    SDz = sqrt(arma_model.NoiseVariance);
    aicS = aic(arma_model);
    fpeS = arma_model.EstimationInfo.FPE;
end