world3 = readtimetable("my_World3_data2.xlsx");
world3a = removevars(world3, {'Year', 'Quarter', 'Date'});
world3a(world3a.DateTime < datetime(1950,1,1),:) = [];
world3b = fillmissing(world3a, "linear");
% world3c = removevars(world3b,["fecundity_multiplier", "Population_65_Plus", "Arable_Land", "inflation" ] );
world3c = removevars(world3b,["fecundity_multiplier"] );
% world3c.Variables=world3c.Variables.*[1 1 1 1 1 1.0e-9 1 1.0e-7 1.0e-8 1.0e-8 1.0e-8 1.0e-11 1.0e-11 1 1.0e-8 1.0e-11 1.0e-11 1.0e-9 1 ];
world3c.Variables=world3c.Variables.*[1 1 1 1 1 1.0e-9 1 1.0e-7 1.0e-8 1.0e-8 1.0e-8 1.0e-8 1.0e-11 1.0e-11 1 1.0e-8 1.0e-11 1.0e-11 1.0e-8 1.0e-9 1 1 ];

reg_param = 1; % regularization parameter in the ridge regression
b = ridgeArray(world3c, 90, 10, reg_param);
w3Pred = ridgePredict(b,world3c,10);