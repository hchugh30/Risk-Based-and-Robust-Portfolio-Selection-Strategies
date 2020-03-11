% Assignment - 2 #2015-16 (HARDIK CHUGH - 1005587866)
function [ x_opt, cash_opt ] = strat_min_variance( x_init, cash_init, mu, Q, cur_prices )

% Add path to CPLEX
addpath('/Applications/CPLEX_Studio128/cplex/matlab/x86-64_osx');

% Optimization problem data
n=length(x_init);
lb = zeros(n,1);
ub = inf*ones(n,1);
A = ones(1,n);
b = 1;

% Compute minimum variance portfolio
cplex1 = Cplex('min_Variance');
cplex1.addCols(zeros(n,1), [], lb, ub);
cplex1.addRows(b, A, b);
cplex1.Model.Q = 2*Q;
cplex1.Param.qpmethod.Cur = 6; % concurrent algorithm
cplex1.Param.barrier.crossover.Cur = 1; % enable crossover
cplex1.DisplayFunc = []; % disable output to screen
cplex1.solve();

% Computing minimum variance portfolio
w_minVar = cplex1.Solution.x;


current_portfolio_value = (cur_prices*x_init) + cash_init; %Caclcuating Current Portfilio Value

Number_Stock_Units =  w_minVar .* current_portfolio_value; %Calcuating Number of Stocks per Asset to buy/sell

x_opt_2 = Number_Stock_Units./cur_prices';

x_difference = round(x_init-(x_opt_2));

x_opt = x_init-x_difference; %Optimal Number of Shares

transaction_cost = cur_prices*abs(x_difference)*0.005; %Applying Transaction Cost to Assets Buy/Sell

new_portfolio_value = cur_prices*x_opt;

cash_opt = current_portfolio_value-new_portfolio_value-transaction_cost; % Optimal Cash Value in our Checking Account

% Verifying that Cash Account is non-negative after applying transcation
% The function is explained clearly in the report 

if cash_opt < 0 
    
current_portfolio_value = (cur_prices*x_init) + cash_init;

Number_Stock_Units =  w_minVar .* current_portfolio_value;

x_opt_2 = Number_Stock_Units./cur_prices';

x_difference = floor(x_init-(x_opt_2));

x_opt = x_init-x_difference; 

transaction_cost = cur_prices*abs(x_difference)*0.005;

new_portfolio_value = cur_prices*x_opt;

cash_opt = current_portfolio_value-new_portfolio_value-transaction_cost;

while cash_opt <0
    
    for i =1:20
        
        if x_difference(i)<0 && cash_opt <0
            
            x_difference(i) = x_difference(i)+1;
            
        else
            x_differene(i) = x_difference(i);
        
        end
    end
    
x_opt = x_init-x_difference;

transaction_cost = cur_prices*abs(x_difference)*0.005;

new_portfolio_value = cur_prices*x_opt;

cash_opt = current_portfolio_value-new_portfolio_value-transaction_cost;

end
end

x_opt=x_opt;

cash = cash_opt;

end



