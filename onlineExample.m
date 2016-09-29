%% simple ODE representing spring with damping
% finding sol to mx''+cx'+kx=0
% w/ m = 2kg c = 30 and k = 128 and x(0) = 0 and x'(0) = 0.6

clearvars; close all; clc

tspan=[0 4];
y0=[0;0.6]; %initial cond
[t,y]=ode45('unforced1', tspan, y0);
plot(t,y(:,1));
grid on
xlabel('time')
ylabel('Displacement')
title('Displacement Vs Time') 

%% small PageRank example
% solving G = alpha * As + (1-alpha)/n * ee^T
% representing Markov chain in matrix As which has eliminated traps

clearvars;

As = [0 1/2 1/2 0 0 0;
      1/6 1/6 1/6 1/6 1/6 1/6;
      1/3 1/3 0 0 1/3 0;
      0 0 0 0 1/2 1/2;
      0 0 0 1/2 0 1/2;
      0 0 0 1 0 0];
  
e = [1; 1; 1; 1; 1; 1];
G = 0.8 * As + ((1-0.8)/6)  * (e * e');

G^(1000) %limit print to console

%% run Johansen test on price series 
clearvars; clc
load inputData_ETF;

indexOne = find(strcmp('EWA', syms));
indexTwo = find(strcmp('EWC', syms));

x = cl(:,indexOne);
y = cl(:,indexTwo);

plot(x);
hold on;
plot(y, 'g');

legend('EWA', 'EWC');

figure;
scatter(x, y);

figure;
regression_results = ols(y, [x ones(size(x))]);
hedgeRatio = regression_results.beta(1);

plot(y-hedgeRatio*x);

results = cadf(y, x, 0, 1);

prt(results);

yPrime = [y x];
results = johansen(yPrime, 0, 1);

prt(results);

index = find(strcmp('IGE', syms));

z = cl(:, index);

yDoubPrime = [yPrime z];

results = johansen(yDoubPrime, 0, 1);

prt(results);

yport = sum(repmat(results.evec(:, 1)', [size(yDoubPrime, 1) 1]).*yDoubPrime, 2);

ylag = lag(yport, 1);
deltaY = yport - ylag;
deltaY(1) = [];
ylag(1) = [];
regress_results = ols(deltaY, [ylag ones(size(ylag))]);
halflife = -log(2)/regress_results.beta(1);

fprintf(1, 'halflife=%f days\n', halflife);

lookback = round(halflife);

numUnits = -(yport-movingAvg(yport, lookback))./movingStd(yport, lookback); 
positions = repmat(numUnits, [1 size(yDoubPrime, 2)]).*repmat(results.evec(:, 1)', [size(yDoubPrime, 1) 1]).*yDoubPrime; % results.evec(:, 1)' can be viewed as the capital allocation, while positions is the dollar capital in each ETF.
pnl = sum(lag(positions, 1).*(yDoubPrime-lag(yDoubPrime, 1))./lag(yDoubPrime, 1), 2); % daily P&L of the strategy
ret = pnl./sum(abs(lag(positions, 1)), 2); % return is P&L divided by gross market value of portfolio
ret(isnan(ret)) = 0;

figure;
plot(cumprod(1+ret)-1); % Cumulative compounded return

fprintf(1, 'APR=%f Sharpe=%f\n', prod(1+ret).^(252/length(ret))-1, sqrt(252)*mean(ret)/std(ret));

