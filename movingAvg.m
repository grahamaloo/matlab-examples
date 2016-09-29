function [mvavg] = movingAvg(x, T)
    assert(T>0);
    
    mvavg = zeros(size(x, 1) - T+1, size(x, 2));
    
    for j = 0:T-1
        mvavg = mvavg + x(1+j:end-T+1+j, :);
    end
    
    mvavg = mvavg / T;
    
    mvavg = [NaN * ones(T-1, size(x, 2)); mvavg];
end