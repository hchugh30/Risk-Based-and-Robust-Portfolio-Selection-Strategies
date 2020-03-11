% Assignment - 2 #2015-16 (HARDIK CHUGH - 1005587866)
clc;
clear all;
format long
warning('off','all')

% Input files
input_file_prices  = 'Daily_closing_prices.csv';

% Read daily prices
if(exist(input_file_prices,'file'))
  fprintf('\nReading daily prices datafile - %s\n', input_file_prices)
  fid = fopen(input_file_prices);
     % Read instrument tickers
     hheader  = textscan(fid, '%s', 1, 'delimiter', '\n');
     headers = textscan(char(hheader{:}), '%q', 'delimiter', ',');
     tickers = headers{1}(2:end);
     % Read time periods
     vheader = textscan(fid, '%[^,]%*[^\n]');
     dates = vheader{1}(1:end);
  fclose(fid);
  data_prices = dlmread(input_file_prices, ',', 1, 1);
else
  error('Daily prices datafile does not exist')
end

% Convert dates into array [year month day]
format_date = 'mm/dd/yyyy';
dates_array = datevec(dates, format_date);
dates_array = dates_array(:,1:3);

% Find the number of trading days in Nov-Dec 2014 and
% compute expected return and covariance matrix for period 1
day_ind_start0 = 1;
day_ind_end0 = length(find(dates_array(:,1)==2014));
cur_returns0 = data_prices(day_ind_start0+1:day_ind_end0,:) ./ data_prices(day_ind_start0:day_ind_end0-1,:) - 1;
mu = mean(cur_returns0)';
Q = cov(cur_returns0);

% Remove datapoints for year 2014
data_prices = data_prices(day_ind_end0+1:end,:);
dates_array = dates_array(day_ind_end0+1:end,:);
dates = dates(day_ind_end0+1:end,:);

% Initial positions in the portfolio
init_positions = [5000 950 2000 0 0 0 0 2000 3000 1500 0 0 0 0 0 0 1001 0 0 0]';

% Initial value of the portfolio
init_value = data_prices(1,:) * init_positions;
fprintf('\nInitial portfolio value = $ %10.2f\n\n', init_value);

% Initial portfolio weights
w_init = (data_prices(1,:) .* init_positions')' / init_value;

% Number of periods, assets, trading days
N_periods = 6*length(unique(dates_array(:,1))); % 6 periods per year
N = length(tickers);
N_days = length(dates);

% Annual risk-free rate for years 2015-2016 is 2.5%
r_rf = 0.025;
% Annual risk-free rate for years 2008-2009 is 4.5%
r_rf2008_2009 = 0.045;

% Number of strategies
strategy_functions = {'strat_buy_and_hold' 'strat_equally_weighted' 'strat_min_variance' 'strat_max_Sharpe' 'strat_equal_risk_contr' 'strat_lever_equal_risk_contr' 'strat_robust_optim'};
strategy_names     = {'Buy and Hold' 'Equally Weighted Portfolio' 'Minimum Variance Portfolio' 'Maximum Sharpe Ratio Portfolio' 'Equal Risk Contributions Portfolio' 'Leveraged Equal Risk Contributions Portfolio' 'Robust Optimization Portfolio'};
%N_strat = 7; % 
N_strat = length(strategy_functions); 
fh_array = cellfun(@str2func, strategy_functions, 'UniformOutput', false);

for (period = 1:N_periods)
   % Compute current year and month, first and last day of the period
   if(dates_array(1,1)==15)
       cur_year  = 15 + floor(period/7);
   else
       cur_year  = 2015 + floor(period/7);
   end
   cur_month = 2*rem(period-1,6) + 1;
   day_ind_start = find(dates_array(:,1)==cur_year & dates_array(:,2)==cur_month, 1, 'first');
   day_ind_end = find(dates_array(:,1)==cur_year & dates_array(:,2)==(cur_month+1), 1, 'last');
   fprintf('\nPeriod %d: start date %s, end date %s\n', period, char(dates(day_ind_start)), char(dates(day_ind_end)));

   % Prices for the current day
   cur_prices = data_prices(day_ind_start,:);

   % Execute portfolio selection strategies
   for(strategy = 1:N_strat)

      % Get current portfolio positions
      if(period==1)
         curr_positions = init_positions;
         curr_cash = 0;
         portf_value{strategy} = zeros(N_days,1);
      if(strategy==6)
          curr_positions = 2*init_positions;
      end
      else
         curr_positions = x{strategy,period-1};
         curr_cash = cash{strategy,period-1};
      end

      % Compute strategy
      [x{strategy,period} cash{strategy,period}] = fh_array{strategy}(curr_positions, curr_cash, mu, Q, cur_prices);

      % Verify that strategy is feasible (you have enough budget to re-balance portfolio)
      % Check that cash account is >= 0
      % Check that we can buy new portfolio subject to transaction costs

      % Transaction cost is implimented in indivual statergy function.
      % Please refer to statergy functions for validation. 

      % Compute portfolio value
      if(strategy==6)
      portf_value{strategy}(day_ind_start:day_ind_end) = data_prices(day_ind_start:day_ind_end,:) * x{strategy,period} + cash{strategy,period} - 1000002.12;
      else
      portf_value{strategy}(day_ind_start:day_ind_end) = data_prices(day_ind_start:day_ind_end,:) * x{strategy,period} + cash{strategy,period};
      end
      fprintf('   Strategy "%s", value begin = $ %10.2f, value end = $ %10.2f\n', char(strategy_names{strategy}), portf_value{strategy}(day_ind_start), portf_value{strategy}(day_ind_end));

      % Compute portfolio weights
      w{strategy,period} = cur_prices .* x{strategy,period}' / (cur_prices * x{strategy,period});
   end
      
   % Compute expected returns and covariances for the next period
   cur_returns = data_prices(day_ind_start+1:day_ind_end,:) ./ data_prices(day_ind_start:day_ind_end-1,:) - 1;
   mu = mean(cur_returns)';
   Q = cov(cur_returns);
   
end

% Plot results
% Daily portfolio values for all 7 strategies
figure(1);

hold off 
plot (portf_value{1}(1:503),'b', 'LineWidth',2);
xlim([0 510])
hold on
plot (portf_value{2}(1:503),'r', 'LineWidth',2);
xlim([0 510])
hold on
plot (portf_value{3}(1:503),'c', 'LineWidth',2);
xlim([0 510])
hold on
plot (portf_value{4}(1:503),'k', 'LineWidth',2);
xlim([0 510])
hold on
plot (portf_value{5}(1:503),'y', 'LineWidth',2);
xlim([0 510])
hold on
plot (portf_value{6}(1:503),'g', 'LineWidth',2);
xlim([0 510])
hold on
plot (portf_value{7}(1:503),'m', 'LineWidth',2);
xlim([0 510])
hold on 
legend('Buy and Hold Statergy','Equally Weighted Statergy','Minimum Variance Statergy','Sharpe Ratio Statergy', 'Equally Risk Contributions Statergy','Leverage Equally Risk Contributions Statergy','Robust Mean Variance Statergy', 'Location', 'northwest')
xlabel('Number of Days');
ylabel('Portfolio Value')
title('Daily portfolio values for all 7 strategies')
grid on

% Dynamic changes in portfolio allocations under Robust Optimization
% Portfolio Statergy
figure(2);

hold off
for i = 1:20
y = zeros (1,12);
for p = 1:12
y(p) = w{7,p}(i);
end
plot(y,'d');
hold on
end
ylim([0 1])
xlim([1 12])
xlabel('Period')
ylabel('Portfolio Weights')
legend('MSFT','F','CRAY','GOOG','HPQ','YHOO','HOG','VZ','AAPL','IBM','T','CSCO','BAC','INTC','AMD','SNE','NVDA','AMZN','MS','BK','Location','northeast','Orientation','Vertical')
title(' Dynamic changes in portfolio allocations under Robust Optimization Statergy')
grid minor

% Dynamic changes in portfolio allocations under Minimum Varience
% Portfolio Statergy

figure(3);

hold off
for i = 1:20
y = zeros (1,12);
for p = 1:12
y(p) = w{3,p}(i);
end
plot(y,'d');
hold on
end
ylim([0 1])
xlim([1 12])
xlabel('Period')
ylabel('Portfolio Weights')
legend('MSFT','F','CRAY','GOOG','HPQ','YHOO','HOG','VZ','AAPL','IBM','T','CSCO','BAC','INTC','AMD','SNE','NVDA','AMZN','MS','BK','Location','northeast','Orientation','Vertical')
title('Dynamic changes in portfolio allocations under Minimum Varience Statergy')
grid minor

% Dynamic changes in portfolio allocations under Max Sharpe Ratio
% Portfolio Statergy

figure(4);

hold off
for i = 1:20
y = zeros (1,12);
for p = 1:12
y(p) = w{4,p}(i);
end
plot(y,'d');
hold on
end
ylim([0 1])
xlim([1 12])
xlabel('Period')
ylabel('Portfolio Weights')
legend('MSFT','F','CRAY','GOOG','HPQ','YHOO','HOG','VZ','AAPL','IBM','T','CSCO','BAC','INTC','AMD','SNE','NVDA','AMZN','MS','BK','Location','northeast','Orientation','Vertical')
title('Dynamic changes in portfolio allocations under Max Sharpe Ratio Portfolio Statergy')
grid minor

% Comparison of three optimization trading strategies

figure(5);

hold off 

plot (portf_value{5}(1:503),'-.m', 'LineWidth',1);
xlim([0 510])
hold on
plot (portf_value{6}(1:503),'--g', 'LineWidth',1);
xlim([0 510])
hold on
plot (portf_value{7}(1:503),':b', 'LineWidth',1);
xlim([0 510])
hold on
 
legend( 'Equally Risk Contributions','Leverage Equally Risk Contributions','Robust Mean Variance', 'Location', 'northwest')
xlabel('Number of Days');
ylabel('Portfolio Value')
title('Comparison of equal risk contributions, leveraged equal risk contributions and robust mean-variance optimization trading strategies')
grid on

% Comparison of Equally Risk Contributions Strategy with Assignement 1
% Statergies 
figure(6);
 
hold off 

plot (portf_value{1}(1:503),'r', 'LineWidth',0.7);
xlim([0 510])
hold on
plot (portf_value{2}(1:503),'b', 'LineWidth',0.7);
xlim([0 510])
hold on
plot (portf_value{3}(1:503),'k', 'LineWidth',0.7);
xlim([0 510])
hold on
plot (portf_value{4}(1:503),'c', 'LineWidth',0.7);
xlim([0 510])
hold on
plot (portf_value{5}(1:503),'-.m', 'LineWidth',2.5);
xlim([0 510])
hold on
 
legend( 'Buy and Hold','Equally Weighted','Min Variance','Max Sharpe Ratio','Equally Risk Contributions', 'Location', 'northwest')
xlabel('Number of Days');
ylabel('Portfolio Value')
title('Equally Risk Contributions Comparison')
grid on

% Comparison of Leverage Equally Risk Contributions Strategy with Assignement 1
% Statergies 

figure(7);
 
hold off 

plot (portf_value{1}(1:503),'r', 'LineWidth',0.7);
xlim([0 510])
hold on
plot (portf_value{2}(1:503),'b', 'LineWidth',0.7);
xlim([0 510])
hold on
plot (portf_value{3}(1:503),'k', 'LineWidth',0.7);
xlim([0 510])
hold on
plot (portf_value{4}(1:503),'c', 'LineWidth',0.7);
xlim([0 510])
hold on
plot (portf_value{6}(1:503),'--g', 'LineWidth',2.5);
xlim([0 510])
hold on

 
legend( 'Buy and Hold','Equally Weighted','Min Variance','Max Sharpe Ratio','Leverage Equally Risk Contributions', 'Location', 'northwest')
xlabel('Number of Days');
ylabel('Portfolio Value')
title('Comparison of Leverage Equally Risk Contributions')
grid on

% Comparison of Robust Mean Variance Strategy with Assignement 1
% Statergies 

figure(8);
 
hold off 

plot (portf_value{1}(1:503),'r', 'LineWidth',0.7);
xlim([0 510])
hold on
plot (portf_value{2}(1:503),'b', 'LineWidth',0.7);
xlim([0 510])
hold on
plot (portf_value{3}(1:503),'k', 'LineWidth',0.7);
xlim([0 510])
hold on
plot (portf_value{4}(1:503),'c', 'LineWidth',0.7);
xlim([0 510])
hold on
plot (portf_value{7}(1:503),':y', 'LineWidth',3);
xlim([0 510])
hold on
 
legend( 'Buy and Hold','Equally Weighted','Min Variance','Max Sharpe Ratio','Robust Mean Variance', 'Location', 'northwest')
xlabel('Number of Days');
ylabel('Portfolio Value')
title('Comparison of Robust Mean Variance')
grid on