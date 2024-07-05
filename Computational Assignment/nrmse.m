% This function computes the normalized root mean square error 
% using 1/(N-1) for the computation of SD.
% INPUTS
% - x       : Vector of correct values
% - x_hat   : Vector of predicted values
% OUTPUT
% - y       : Value of NRMSE
function y = nrmse(x, x_hat)
    x_mean = mean(x);
    var_hat = sum((x - x_mean).^2);
    var_pre = sum((x - x_hat).^2);
    
    % Compute the NRMSE based on the known formula
    y = sqrt(var_pre / var_hat);
end