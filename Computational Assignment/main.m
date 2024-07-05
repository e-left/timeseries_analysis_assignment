clear;      % Clear workspace
close all;  % Close all windows
clc;        % Clear command line

warning off;    % Disable warnings

% =============================================================
%                   Timeseries Analysis
%                    Project 2023-2024
%           Aristotle University of Thessaloniki
%  School of Engineering - Electrical and Computer Engineering
% =============================================================
%        Team 10
% -----------------------
% Kyparisssis Kyparissis    10346   kyparkypar@ece.auth.gr
% Alexandridis Fotios       9953    faalexandr@ece.auth.gr

% Load data, keep only column that concerns our team (Team 10)
teamNumber = 10;
x = loadTimeseriesFromDataset(teamNumber);

% Display timeseries to get an idea on what we work on
figure;
plot(x, '.-')
xlabel('t')
ylabel('x(t)')
title('Timeseries to be analysed (Team 10)')

%% ----------------- (Step #1) -----------------
% Remove trend from the timeseries using two methods
fprintf("\nDetrending\n");
fprintf("======================\n")

x1 = timeseriesDetrending(x, 'removeEstimatedTrendFunction');
fprintf("x1 is the detrended timeseries x by removing the MA\n");
subtitle('Timeseries new name: x_1');
ylabel('x_1(t)');

x2 = timeseriesDetrending(x, 'differencing');
fprintf("x2 is the detrended timeseries x using first differences method\n");
subtitle('Timeseries new name: x_2');
ylabel('x_2(t)');

%% ----------------- (Step #2) -----------------
% Check if timeseries is whitenoise or not
% Done with 2 methods: 
% - Auto-correlation plots 
% - Ljung-Box test

% Using x1
% ----------------
fprintf("\nLjung-Box test result\n");
fprintf("======================\n")
if isTimeseriesWhiteNoise(x1, true, 'x_1')
    fprintf("The time series x1 appears to be white noise\n");
else
    fprintf("The time series x1 is likely NOT white noise\n");
end

% Using x2
% ----------------
if isTimeseriesWhiteNoise(x2, true, 'x_2')
    fprintf("The time series x2 appears to be white noise\n");
else
    fprintf("The time series x2 is likely NOT white noise\n");
end

%% ----------------- (Step #3) -----------------
% Find the best linear models for x1 and x2
% Since both are not white noise, we continue
fprintf("\nFind best linear model\n");
fprintf("======================\n");

% For x1
% ----------------
figure;
parcorr(x1);
title('Partial Auto-correlation coefficients')
subtitle('Timeseries: x_1');
ylabel('Partial Auto-correlation coefficients')
% After observing the ACF and PACF plots of x2, we need to find where:
% - In ACF plot for MA(q) order: 	Significant at lag q / Cuts off after lag q
% - IN PACF plot for AR(p) order:   Significant at lag p / Cuts off after lag p 
% This provides the initial estimates for the range of values we should consider
% We will create a grid search area of (p, q) pairs (0:p, 0:q), for the p and q
% We observed that:
maxSearch_p_x1 = 3;
maxSearch_q_x1 = 3;

% Implement a grid search algorithm to fit different ARMA(p, q) models within the specified range of parameters
[optimal_p_x1, optimal_q_x1, resx1, armax1] = findOptimalARMAModel(x1, maxSearch_p_x1, maxSearch_q_x1, 'x_1');
fprintf("Best linear model found for x1: ARMA(%d, %d)\n", optimal_p_x1, optimal_q_x1);

% Plot residuals
figure;
plot(resx1, '.-');
title(sprintf("ARMA(%d, %d) 1-step-ahead prediction errors (residuals)", optimal_p_x1, optimal_q_x1))
subtitle('For timeseries: x_1');
xlabel('t');
ylabel('Residuals')


% For x2
% ----------------
figure;
parcorr(x2);
title('Partial Auto-correlation coefficients')
subtitle('Timeseries: x_2');
ylabel('Partial Auto-correlation coefficients')
% After observing the ACF and PACF plots of x2, we need to find where:
% - In ACF plot for MA(q) order: 	Significant at lag q / Cuts off after lag q
% - IN PACF plot for AR(p) order:   Significant at lag p / Cuts off after lag p 
% This provides the initial estimates for the range of values we should consider
% We will create a grid search area of (p, q) pairs (0:p, 0:q), for the p and q
% We observed that:
maxSearch_p_x2 = 5;
maxSearch_q_x2 = 2;

% Implement a grid search algorithm to fit different ARMA(p, q) models within the specified range of parameters
[optimal_p_x2, optimal_q_x2, resx2, armax2] = findOptimalARMAModel(x2, maxSearch_p_x2, maxSearch_q_x2, 'x_2');
fprintf("Best linear model found for x2: ARMA(%d, %d)\n", optimal_p_x2, optimal_q_x2);

% Plot residuals
figure;
plot(resx2, '.-');
title(sprintf("ARMA(%d, %d) 1-step-ahead prediction errors (residuals)", optimal_p_x2, optimal_q_x2))
subtitle('For timeseries: x_2');
xlabel('t');
ylabel('Residuals')

%% ----------------- (Step #4) -----------------
trainingSize = 450;
validationSize = 150;
Tmax = 5;

% For x1 with model ARMA(2, 3)
% ----------------
[~, predModel1, ~, ~] = predictARMAnrmse(x1, optimal_p_x1, optimal_q_x1, Tmax, validationSize);

% Adding back trend to get predictions of the original timeseries
% and calculating NRMSE for x1 predictions
nrmse1 = calculateNRMSEForARMAWithTrend(x, predModel1, 'addEstimatedTrendFunction', Tmax, trainingSize, validationSize);

% Display NRMSE
figure;
plot(nrmse1, '.-', 'Color', 'r');
title({'NRMSE for timeseries predictions';['for timesteps forward 1 up to ', num2str(Tmax)]})
subtitle({['Model: ARMA(' num2str(optimal_p_x1) ', ' num2str(optimal_q_x1) ')'];'For timeseries: x_1'});
xticks(1:Tmax)
xlabel('Timesteps forward')
ylabel('NRMSE')
yticks(sort(unique(nrmse1)))
grid on;


% For x2 with model ARMA(2, 2)
% ----------------
[~, predModel2, ~, ~] = predictARMAnrmse(x2, optimal_p_x2, optimal_q_x2, Tmax, validationSize);

% Adding back trend to get predictions of the original timeseries
% and calculating NRMSE for x2 predictions
nrmse2 = calculateNRMSEForARMAWithTrend(x, predModel2, 'differencing', Tmax, trainingSize, validationSize);

% Display NRMSE for x2 predictions
figure;
plot(nrmse2, '.-', 'Color', "#D95319");
title({'NRMSE for timeseries predictions';['for timesteps forward 1 up to ', num2str(Tmax)]})
subtitle({['Model: ARMA(' num2str(optimal_p_x2) ', ' num2str(optimal_q_x2) ')'];'For timeseries: x_2'});
xticks(1:Tmax)
xlabel('Timesteps forward')
ylabel('NRMSE')
yticks(sort(unique(nrmse2)))
grid on;

%% ----------------- (Step #5) -----------------

% Display both NRMSE for x1, x2 predictions for comparison
figure;
plot(nrmse1, '.-', 'Color', 'r');
hold on;
plot(nrmse2, '.-', 'Color', "#D95319");
title({'NRMSE for timeseries predictions';['for timesteps forward 1 up to ', num2str(Tmax)]})
xticks(1:Tmax)
xlabel('Timesteps forward')
ylabel('NRMSE')
grid on;
legend(sprintf('For x_1 with model: ARMA(%d, %d)', optimal_p_x1, optimal_q_x1), ...
       sprintf('For x_2 with model: ARMA(%d, %d)', optimal_p_x2, optimal_q_x2), ...
       'Location', 'best');

%% ----------------- (Step #6) -----------------
% We already have the variables resx1 and resx2 and the plots have already been displayed in step 3

%% ----------------- (Step #7) -----------------
isResX1IID = isTimeseriesIID(resx1, true);
title('Mutual Information')
subtitle('Timeseries: Residuals of x_1')
if isResX1IID
    fprintf("\nx1 residuals seem to be iid\n");
else
    fprintf("\nx1 residuals are NOT iid\n");
end

isResX2IID = isTimeseriesIID(resx2, true);
title('Mutual Information')
subtitle('Timeseries: Residuals of x_2')
if isResX2IID
    fprintf("x2 residuals seem to be iid\n");
else
    fprintf("x2 residuals are NOT iid\n");
end

%% ----------------- (Step #8) -----------------
% Starting with smaller values, we concluded that the minimal NRMSE is found in this range
% Regarding the parameter values, we check various values for tau. For each value of m, q is searched in the range
% 0 <= q <= m. Finally, we search for a number of neighboors >= m

fprintf("\nFind the best non linear (local linear) model\n");
fprintf("======================\n")

% For timeseries x1
[tau1, m1, q1, nNeighboors1, NRMSEfit1] = findOptimalNonLinearModel(x1, 1:15, 1:10, 10:20);
fprintf("Optimal model for timeseries x1 has following parameters: tau=%d, m=%d, q=%d, number of neighboors=%d with fitting error NRMSE=%f\n", tau1, m1, q1, nNeighboors1, NRMSEfit1);


% For timeseries x2
[tau2, m2, q2, nNeighboors2, NRMSEfit2] = findOptimalNonLinearModel(x2, 1:5, 10:20, 20:30);
fprintf("Optimal model for timeseries x2 has following parameters: tau=%d, m=%d, q=%d, number of neighboors=%d with fitting error NRMSE=%f\n", tau2, m2, q2, nNeighboors2, NRMSEfit2);

%% ----------------- (Step #9) -----------------
% For x1
% ----------------
[~, predModel1NonLinear] = localpredictnrmse(x1, validationSize, tau1, m1, Tmax, nNeighboors1, q1);

% adding back trend to get predictions of the original timeseries
% and calculating NRMSE for x1 predictions
nrmse1NonLinear = calculateNRMSEforNonLinearWithTrend(x, predModel1NonLinear, 'addEstimatedTrendFunction', Tmax, trainingSize);

% Display NRMSE
figure;
plot(nrmse1NonLinear, '.-', 'Color', 'r');
title({'NRMSE for timeseries predictions';['for timesteps forward 1 up to ', num2str(Tmax)]})
subtitle({['Model: Local Linear Model( tau=' num2str(tau1) ', m=' num2str(m1) ', q=' num2str(q1) ', number of neighboors=' num2str(nNeighboors1) ')'];'For timeseries: x_1'});
xticks(1:Tmax)
xlabel('Timesteps forward')
ylabel('NRMSE')
yticks(sort(unique(nrmse1NonLinear)))
grid on;

% For x2
% ----------------
[~, predModel2NonLinear] = localpredictnrmse(x2, validationSize, tau2, m2, Tmax, nNeighboors2, q2);

% Adding back trend to get predictions of the original timeseries
% Cand calculating NRMSE for x2 predictions
nrmse2NonLinear = calculateNRMSEforNonLinearWithTrend(x, predModel2NonLinear, 'differencing', Tmax, trainingSize);

% Display NRMSE
figure;
plot(nrmse2NonLinear, '.-', 'Color', 'r');
title({'NRMSE for timeseries predictions';['for timesteps forward 1 up to ', num2str(Tmax)]})
subtitle({['Model: Local Linear Model( tau=' num2str(tau2) ', m=' num2str(m2) ', q=' num2str(q2) ', number of neighboors=' num2str(nNeighboors2) ')'];'For timeseries: x_2'});
xticks(1:Tmax)
xlabel('Timesteps forward')
ylabel('NRMSE')
yticks(sort(unique(nrmse2NonLinear)))
grid on;


%% ----------------- (Step #10) -----------------
% Display both NRMSE for x1, x2 predictions for comparison
figure;
plot(nrmse1NonLinear, '.-', 'Color', 'r');
hold on;
plot(nrmse2NonLinear, '.-', 'Color', "#D95319");
title({'NRMSE for timeseries predictions';['for timesteps forward 1 up to ', num2str(Tmax)]})
xticks(1:Tmax)
xlabel('Timesteps forward')
ylabel('NRMSE')
grid on;
legend(['For x_1 Local Linear Model(tau=' num2str(tau1) ', m=' num2str(m1) ', q=' num2str(q1) ', number of neighbours=' num2str(nNeighboors1) ')'], ...
       ['For x_2 Local Linear Model(tau=' num2str(tau2) ', m=' num2str(m2) ', q=' num2str(q2) ', number of neighbours=' num2str(nNeighboors2) ')'], ...
       'Location', 'best');

% Compare with linear models
figure;
plot(nrmse1, '.-', 'Color', 'r');
hold on;
plot(nrmse2, '.-', 'Color', "b");
plot(nrmse1NonLinear, '.-', 'Color', 'g');
plot(nrmse2NonLinear, '.-', 'Color', "#D95319");
title({'NRMSE for timeseries predictions';['for timesteps forward 1 up to ', num2str(Tmax)]})
xticks(1:Tmax)
xlabel('Timesteps forward')
ylabel('NRMSE')
grid on;
legend(sprintf('For x_1 with model: ARMA(%d, %d)', optimal_p_x1, optimal_q_x1), ...
       sprintf('For x_2 with model: ARMA(%d, %d)', optimal_p_x2, optimal_q_x2), ...
       ['For x_1 Local Linear Model(tau=' num2str(tau1) ', m=' num2str(m1) ', q=' num2str(q1) ', number of neighbours=' num2str(nNeighboors1) ')'], ...
       ['For x_2 Local Linear Model(tau=' num2str(tau2) ', m=' num2str(m2) ', q=' num2str(q2) ', number of neighbours=' num2str(nNeighboors2) ')'], ...
       'Location', 'best');