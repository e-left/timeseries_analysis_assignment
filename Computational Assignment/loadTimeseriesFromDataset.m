% This function simply loads the timeseries data from the dataset file according to the team number of the assignment
% INPUTS:
% - teamNumber : team number of the assignment
% OUTPUT:
% - data       : vector of a scalar time series
function data = loadTimeseriesFromDataset(teamNumber)
    fullData = readmatrix("ContestData.dat");
    data     = fullData(:, teamNumber);
end