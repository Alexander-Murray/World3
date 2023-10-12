world3 = readtimetable("f:\boc\world3-main\estimation\my_world3_data2.xlsx");
world3a = removevars(world3, {'Year', 'Quarter', 'Date'});
world3a(world3a.DateTime < datetime(1950,1,1),:) = [];
world3b = fillmissing(world3a, "linear");
world3c = removevars(world3b,["fecundity_multiplier", "Population_65_Plus", "Arable_Land", "inflation" ] );
world3c = world3c .* [1 1 1 1 1 1.0e-9 1 1.0e-7 1.0e-8 1.0e-8 1.0e-8 1.0e-11 1.0e-11 1 1.0e-8 1.0e-11 1.0e-11 1.0e-9 1 ];
eval_rows = 10;
world3_train = world3c(1:height(world3c)-eval_rows,:);
world3_eval = world3c(height(world3c)-(eval_rows-1):height(world3c),:);

for i = 1:9    % tried 10 but had to cut it off -- took too long. 9 takes many hours.
    [score{i}, fc{i}, estMdl{i}, mdl{i}] = EvalLags(world3_train, world3_eval, i);
end
