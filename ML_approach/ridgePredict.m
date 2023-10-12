function r = ridgePredict(bArray, tt, newRows)
    % Returns a timetable consisting of the data in timetable "tt",
    % followed by "newRows" rows of (future) predictions.
    % "bArray" is a cell array of coefficients, usually produced by
    % "ridgeArray".
    r = tt;
    for i = 1:newRows
        newRow = ridgePredictRow(bArray, r, height(r));
        lastDate = r.DateTime(end);
        nextDate = lastDate + calmonths(3);
        r(nextDate,:) = newRow;
    end
end
