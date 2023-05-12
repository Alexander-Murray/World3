function y = interp_f(data,x)
    try
        x = full(evalf(x)); % accomodate for SX numeric input from Casadi
    catch
        x=x;
    end
    x_data = data(:,1);
    y_data = data(:,2);
    if x>=max(x_data)
       y = y_data(find(x_data==max(x_data)));
    elseif x<=min(x_data)
       y = y_data(find(x_data==min(x_data)));
    else
        loc = max(find(x>x_data));
        slope = (y_data(loc+1)-y_data(loc))/(x_data(loc+1)-x_data(loc));
        y = y_data(loc)+slope*(x-x_data(loc));
    end
end