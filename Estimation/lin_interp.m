function non_nan_data = lin_interp(data)
    nData = size(data,1);
    nVars = size(data,2);
    
    non_nan_data = data;

    % loop over columns in data
    for c = 1:nVars
        all_non_nans = find(~isnan(data(:,c)));
        % account for the possibility that the first entry is nan
        if all_non_nans(1)~=1
            all_non_nans = [0;all_non_nans]; 
        end
        if all_non_nans(end)~=length(data(:,c))
            all_non_nans = [all_non_nans;length(data(:,c))+1]; % still need to handle this case
        end
        % initialize inds
        last_non_nan_ind = all_non_nans(1);
        next_non_nan_ind = all_non_nans(2);
        
        % loop over non-nan inds
        for i = 1:length(all_non_nans)-1
            if last_non_nan_ind == 0
                last_data = data(all_non_nans(2),c) - all_non_nans(2)*(data(all_non_nans(3),c)-data(all_non_nans(2),c))/(all_non_nans(3)-all_non_nans(2));
            else
                last_data = data(last_non_nan_ind,c);
            end
            if next_non_nan_ind == length(data(:,c))+1
                try
                    next_data = last_data + (all_non_nans(end)-all_non_nans(end-1))*(last_data-data(all_non_nans(end-2),c))/(last_non_nan_ind-all_non_nans(end-2));
                catch
                    next_data = last_data;
                end
            else
                next_data = data(next_non_nan_ind,c);
            end
            nNaNs = next_non_nan_ind-last_non_nan_ind-1;
            interp = last_data + (1:nNaNs)*(next_data-last_data)/(nNaNs+1); % linear interpolation between non-nan values
            non_nan_data(last_non_nan_ind+1:next_non_nan_ind-1,c) = interp;
            
            if i < length(all_non_nans)-1 % update non-nan inds
                last_non_nan_ind = all_non_nans(i+1);
                next_non_nan_ind = all_non_nans(i+2);
            end
        end
    end
end