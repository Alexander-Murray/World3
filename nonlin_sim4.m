function [sim_traj] = nonlin_sim4(eqns,ineqns,shocks,shock_vals,params,param_vals)
% Assumes that CasADi has already been added to the path since this code
% relies on casadi-cased functions and variables as input. If it is not on
% the path then add it and import it via the following two commands:
%     addpath(genpath('/home/mrra/CasADi_v3.5.5_linux'));

%this version is made for the low var model formulation. Therefore, it
%treats variables as the LHS of x(t) = f(x(t-1)|p)

    import casadi.*
    
    T = length(eqns);
    
     sim_fun = cell(T,1);
     sim_eval = cell(T,1);
     tic
     for t = 1:T
         sim_fun{t} = Function('f',{params,shocks{t}},{[eqns{t};ineqns{t}]});
         sim_eval{t} = sim_fun{t}(param_vals,shock_vals{t});
     end
     sim_traj = full(horzcat(sim_eval{:}));
end