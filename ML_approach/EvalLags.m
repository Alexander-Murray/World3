function [score, fc, estModel, model] = EvalLags(train, evaln, nLags)
   model = varm(width(train), nLags);
   estModel = estimate(model, train);
   fc = forecast(estModel, height(evaln), train);
   score = rms(rms(table2array(fc) - table2array(evaln)));
end
