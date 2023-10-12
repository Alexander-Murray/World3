function r = ridgeTest(b, tt, predictRow)
    % Returns a prediction for row number "predictRow" of timetable "tt",
    % and cell number implicitly defined by "b".
    % "b" is an array of coefficients, usually one of the cells of the 
    % array returned by "ridgeArray".
    allData = table2array(tt);
    sampleSize = (length(b) - 1) / width(tt);
    predictData = allData(predictRow-sampleSize:predictRow-1,:);
    predictData = reshape(predictData, [1, numel(predictData)]);
    r = b(1) + predictData * b(2:end);
end
