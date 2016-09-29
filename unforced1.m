function [yp] = unforced1(t,y)
    yp = [y(2);(-((15)*y(2))-((64)*y(1)))]; 
end