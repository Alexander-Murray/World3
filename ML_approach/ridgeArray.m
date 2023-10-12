function b = ridgeArray(tt, numSamples, lags, alpha)
    % Returns ridge regression coefficients for training data consisting of 
    % "numSamples" samples, each of "lags" rows, taken from the timetable
    % "tt". "alpha" is the (poorly documented) MATLAB "ridge parameter".
    % The returned value is a cell array, containing one set of
    % coefficients for each column of tt.
    if nargin < 4
        alpha = 0.01;
    end
    if nargin < 3
        lags = 10;
    end
    if nargin < 2
        numSamples = 70;
    end
    nrows = height(tt);
    allData = table2array(tt);
    for colNumber = 1:width(tt)
        for i = 1:numSamples
            start = randi([1 nrows-lags]);
            slice = allData(start : start+lags-1, :);
            trainData(i,:) = reshape(slice, [1, numel(slice)]);
            evalData(i,1) = allData(start + lags, colNumber);
        end
        b{colNumber} = ridge(evalData, trainData, alpha, 0);
    end
end
