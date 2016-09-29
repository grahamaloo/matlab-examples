function [sd] = movingStd(x, T, varargin)
    sd=NaN*ones(size(x));

    if (nargin == 2)
        for t=T:size(x, 1)
            % for t=T:length(x)
            sd(t, :)=std(x(t-T+1:t, :));
        end
    else
        period=varargin{1};
        for t=T*period:size(x, 1)
            sd(t, :)=std(x(t-T*period+1:t, :));
        end
    end
end 