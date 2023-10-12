function [lnpost, lnpY, lnprio] = objfcn_dsge(para, phi_smc, prio, bounds, data)

% recover prior information
pshape   = prio(:,1);
pmean    = prio(:,2);
pstdd    = prio(:,3);
pmask    = prio(:,4);
pfix     = prio(:,5);
pmaskinv = 1- pmask;
pshape   = pshape.*pmaskinv;

% check bounds
parabd_ind1 = para > bounds(:,1); % lower bounds
parabd_ind2 = para < bounds(:,2); % upper bounds
parabd_ind1 = parabd_ind1(logical(pmaskinv));
parabd_ind2 = parabd_ind2(logical(pmaskinv));

modelpara = para;
sum_AR = para(6) + para(7);

if and(parabd_ind1 == 1,  parabd_ind2 == 1) % in bounds
       [T1, ~, T0, ~, GEV] = model_solution(modelpara);
       if (GEV(1) == 1) && (GEV(2) == 1) && (sum_AR<1) % solution exists and unique, Joshua Brault 06/08/2021
       [A,B,H,R,Se,Phi, PD] = sysmat(T1,T0,modelpara);
       if PD == 1
       %liki = kalman(A,B,H,R,Se,Phi,data);
       liki = kalman2(A,B,H,R,Se,Phi,data);
       real = isreal(liki); % added by Joshua Brault 06/08/2021
            if (real == 1)
                lnpY = sum(liki);
                lnprio = priodens(modelpara, pmean, pstdd, pshape);
                lnpost = (phi_smc*lnpY + lnprio);
            else
                lnpY    = -inf;
                lnprio  = -inf;
                lnpost  = -inf;
            end
       else
        lnpY    = -inf;
        lnprio  = -inf;
        lnpost  = -inf;
       end
    else % if parameter proposal is out of bounds
        lnpost  = -inf;
        lnpY    = -inf;
        lnprio = -inf;
       end
else
        lnpost  = -inf;
        lnpY    = -inf;
        lnprio = -inf;
end
end
