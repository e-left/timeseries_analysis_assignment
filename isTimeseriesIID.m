% This function checks if a timeseries can be iid using a non-linear formula
% Firstly, since is IID is a subset of white noise, we check if the time series is white noise
% Secondly, the Mutual Information (MI) is a non-linear measure of statistical dependence between two random variables
% The test is based on the sentence in the notes that:
% "If the time series is iid, then the mutual information for all lags should be insignificant"
% We also conduct a second test to check if the time series is a IID
% The second test is based on the fact that the first differences of a random walk are iid
% So, if the time series is iid, then the first additions of the time series should be a random walk
% INPUTS:
% - x                      : vector of a scalar time series
% - MIplot                 : boolean to plot the mutual information for all lags
% OUTPUT:
% - isIID : result of the test of whether the timeseries
%           is iid. For this to be true, the timeseries must be white noise and must
%           have insignificant mutual information for all lags
function isIID = isTimeseriesIID(x, MIplot)
    % Check if all mutual information values are below significance level
    % If they are, and x is also white noise, then x is iid
    if isTimeseriesWhiteNoise(x, false) == false
        isIID = false;
        % No further checks are needed
        return;
    end

    % Check if we want the plot of the mutual information for all lags
    if nargin < 2
        MIplot = false;
    end

    % Calculate the mutual information for all lags
    n = length(x);
    
    partitions = ceil(sqrt(n/5));       % Number of partitions of the one dimensional domain for which the probabilities are evaluated
    h1V = zeros(partitions, 1);             % for p(x(t+tau))
    h2V = zeros(partitions, 1);             % for p(x(t))
    h12M = zeros(partitions, partitions);   % for p(x(t+tau), x(t))

    % Normalise the data
    x_min = min(x);
    [x_max, idx_max] = max(x);
    x_norm(idx_max) = x_max + (x_max-x_min)*10^(-10);   % To avoid multiple exact maxima
    x_norm = (x-x_min)/(x_max-x_min);

    partitionsVector = floor(x_norm*partitions) + 1;    % Array of partitions: 1,...,partitions
    partitionsVector(idx_max) = partitions;             % Set the maximum in the last partition

    % What number of lags to consider
    tmax = min(20, length(x)-1);

    MImat = zeros(tmax+1,2);
    MImat(1:tmax+1, 1) = [0:tmax]';
    % Calculate the mutual information for all lags
    % (The following part is taken from eLearning)
    for tau = 0:tmax
        ntotal = n-tau;
        mutS = 0;
        for i = 1:partitions
            for j = 1:partitions
                h12M(i, j) = length(find(partitionsVector(tau+1:n) == i & partitionsVector(1:n-tau) == j));
            end
        end
        for i = 1:partitions
            h1V(i) = sum(h12M(i,:));
            h2V(i) = sum(h12M(:,i));
        end
        for i = 1:partitions
            for j = 1:partitions
                if h12M(i, j) > 0
                    mutS = mutS + (h12M(i, j)/ntotal)*log(h12M(i, j)*ntotal/(h1V(i)*h2V(j)));
                end
            end
        end
        MImat(tau+1, 2) = mutS;
    end

    % Calculate the threshold for significance
    mean_mutual_info = mean(MImat(2:end, 2));
    std_mutual_info = std(MImat(2:end, 2));

    % Set significance level and multiplier
    significance_level = 0.95; % For example, 95% significance level
    Z = norminv((1 + significance_level) / 2); % Z-score for desired significance level

    % Calculate threshold
    threshold = mean_mutual_info + Z * std_mutual_info;

    if MIplot == true
        figure;
        stem(MImat(:,1), MImat(:,2),'filled','-o','MarkerSize',4,'SeriesIndex',2)
        hold on;
        plot(MImat(2:end,1), threshold*ones(length(MImat(2:end,1)), 1), '--')
        grid on;
        xlabel('Lag (\tau)')
        ylabel('I(\tau)')
        ylim([0, max(MImat(:,2))+0.01])
    end

    % Check if all mutual information values are below threshold
    % If so, the max value of the mutual information is below the threshold
    if max(MImat(2:end,2)) > threshold
        isIID = false;
        % No further checks are needed
        return;
    end

    % First differences of random walk -> iid
    % So, if it is iid, then if we calculate the first additions of the time series, it should be a random walk
    % ---
    % Adding back trend
    % Time Series Course Notes, page 80, equations 91-92
    x_trended = zeros(length(x), 1);
    x_trended(1) = x(1); % x(1) is the first value of the time series
    for k = 2:length(x)
        x_trended(k) = x_trended(k - 1) + x(k);
    end

    % A random walk process assumes the error terms (innovations) in the series are independent and identically distributed (IID). 
    % This means the error at any given time point doesn't influence the error at any other point, and the errors all come from 
    % the same probability distribution with constant variance.
    % The variance ratio test compares the variance of the differenced series (where you subtract consecutive values) to the 
    % estimated variance of the noise. If the test rejects the null hypothesis (h = 1), it suggests the variance of the differenced
    % series is significantly different from the expected variance under the assumption of IID errors. 
    % This could be due to:
    % - Presence of autocorrelation in the errors (errors are not independent).
    % - teroscedasticity (variance of errors is not constant).
    h = vratiotest(x_trended, 'IID', true);

    if h == 0   % Indicates that, at a 5% level of significance, 
                % the test fails to reject the null hypothesis that the series is a random walk.
        isIID = true;
    else
        isIID = false;
    end
end