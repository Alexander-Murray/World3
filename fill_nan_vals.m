function non_nan_data = fill_nan_vals(data)
    nData = size(data,1);
    nVars = size(data,2);
    
    non_nan_data = nan(size(data));

    for c = 1:nVars
        all_non_nans = find(~isnan(data(:,c)));
        inpute_data = data(all_non_nans(1),c);
        
        for r = 1:nData
            if isnan(data(r,c))
                non_nan_data(r,c) = inpute_data;
            else
                non_nan_data(r,c) = data(r,c);
                inpute_data = data(r,c);
            end
        end
    end
end