% Assignment - 2 #2015-16 (HARDIK CHUGH - 1005587866)
function [ x_opt, cash_opt ] = strat_lever_equal_risk_contr( x_init, cash_init, mu, Q, cur_prices )

global C A_ineq A_eq

C = Q; 

%Define Risk Free Rate
r_rf = 2.5/(100*6);

%% Add PATH to CPLEX and other solvers
addpath('D:\CPLEX\CPLEX1263_x64\cplex\matlab\x64_win64\');

n=length(x_init);

% Equality constraints
A_eq = ones(1,n);
b_eq = 1;

% Inequality constraints
A_ineq = [];
b_ineql = [];
b_inequ = [];
           
% Define initial portfolio ("equally weighted" or "1/n portfolio")
w0 = repmat(1.0/n, n, 1);

options.lb = zeros(1,n);       % lower bounds on variables
options.lu = ones (1,n);       % upper bounds on variables
options.cl = [b_eq' b_ineql']; % lower bounds on constraints
options.cu = [b_eq' b_inequ']; % upper bounds on constraints

% Set the IPOPT options
options.ipopt.jac_c_constant        = 'yes';
options.ipopt.hessian_approximation = 'limited-memory';
options.ipopt.mu_strategy           = 'adaptive';
options.ipopt.tol                   = 1e-10;
options.ipopt.print_level = 0;
% The callback functions
funcs.objective         = @computeObjERC;
funcs.constraints       = @computeConstraints;
funcs.gradient          = @computeGradERC;
funcs.jacobian          = @computeJacobian;
funcs.jacobianstructure = @computeJacobian;

%% Run IPOPT
[wsol info] = ipopt(w0',funcs,options);

% Make solution a column vector
if(size(wsol,1)==1)
    w_erc = wsol';
else
    w_erc = wsol;
end

% Computing Equally Risk Controbution portfolio
current_portfolio_value = (cur_prices*x_init) + cash_init; %Caclcuating Current Portfilio Value

Number_Stock_Units = current_portfolio_value*w_erc; %Calcuating Number of Stocks per Asset to buy/sell

x_opt_1 = Number_Stock_Units./(cur_prices)';

x_difference = round(x_init-(x_opt_1));

x_opt = x_init-x_difference; %Optimal Number of Shares

transaction_cost = cur_prices*abs(x_difference)*0.005; %Applying Transaction Cost to Assets Buy/Sell

new_portfolio_value = cur_prices*x_opt;

cash_opt = current_portfolio_value-new_portfolio_value-transaction_cost-(r_rf*1000002.12); % Optimal Cash Value in our Checking Account

% Verifying that Cash Account is non-negative after applying transcation
% The function is explained clearly in the report 

if cash_opt < 0 
    
current_portfolio_value = (cur_prices*x_init) + cash_init;

Number_Stock_Units = current_portfolio_value*w_erc;

x_opt_1 = Number_Stock_Units./(cur_prices)';

x_difference = floor(x_init-(x_opt_1));


x_opt = x_init-x_difference;

transaction_cost = cur_prices*abs(x_difference)*0.005;

new_portfolio_value = cur_prices*x_opt;

cash_opt = current_portfolio_value-new_portfolio_value-transaction_cost-(r_rf*1000002.12);

while cash_opt <0

    for i =1:20
    
        if x_difference(i)<0 && cash_opt <0
            x_difference(i) = x_difference(i)+1;
        
        else
            x_difference(i) = x_difference(i);
        
        end
    end
    
x_opt = x_init-x_difference;

transaction_cost = cur_prices*abs(x_difference)*0.005;

new_portfolio_value = cur_prices*x_opt;

cash_opt = current_portfolio_value-new_portfolio_value-transaction_cost-(r_rf*1000002.12);

end

x_opt=x_opt;

end

end



