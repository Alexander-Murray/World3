function newRow = ridgePredictRow(bArray, tt, rowNumber)
   % Returns a cell array containing a row's worth of predictions for row
   % number "rowNumber" of timetable "tt". "bArray" is a cell array of
   % coefficients, usually returned by "ridgeArray".
   for col = 1:width(tt)
       newRow{col} = ridgeTest(bArray{col}, tt, rowNumber);
   end
end
