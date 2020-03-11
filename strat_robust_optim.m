% Assignment - 2 #2015-16 (HARDIK CHUGH - 1005587866)
function[ x_opt, cash_opt ] = strat_robust_optim( x_init, cash_init, mu, Q, cur_prices )
%% Add PATH to CPLEX and other solvers
addpath('/Applications/CPLEX_Studio128/cplex/matlab/x86-64_osx');

n=length(x_init);

%% Define initial portfolio ("equally weighted" or "1/n portfolio")
w0 = ones(n,1) ./ n;

ret_init = dot(mu, w0);

var_init = w0' * Q * w0;

% Bounds on variables
lb_rMV = zeros(n,1);
ub_rMV = inf*ones(n,1);

% Required portfolio robustness
var_matr = diag(diag(Q));
% Target portfolio return estimation error is return estimation error of 1/n portfolio
rob_init = w0' * var_matr * w0; % return estimation error of initial portfolio
rob_bnd = rob_init; % target return estimation error

% Compute minimum variance portfolio
cplex_minVar = Cplex('MinVar');
cplex_minVar.addCols(zeros(1,n)', [], lb_rMV, ub_rMV);
cplex_minVar.addRows(1, ones(1,n), 1);
cplex_minVar.Model.Q = 2*Q;
cplex_minVar.Param.qpmethod.Cur = 6;
options.DisplayFunc = 'off';
cplex_minVar.DisplayFunc = 'off'; % disable output to screen
cplex_minVar.solve();
cplex_minVar.Solution;
w_minVar = cplex_minVar.Solution.x; % asset weights
ret_minVar = dot(mu, w_minVar);
var_minVar = w_minVar' * Q * w_minVar;
rob_minVar = w_minVar' * var_matr * w_minVar;

% Target portfolio return is return of minimum variance portfolio
Portf_Retn = ret_minVar;

%% Formulate and solve robust mean-variance problem
 
% Objective function
f_rMV  = zeros(n,1);
% Constraints
A_rMV  = sparse([  mu'; ones(1,n)]);
lhs_rMV = [Portf_Retn; 1];
rhs_rMV = [inf; 1];
% Initialize CPLEX environment
cplex_rMV = Cplex('Robust_MV');
cplex_rMV.addCols(f_rMV, [], lb_rMV, ub_rMV);
cplex_rMV.addRows(lhs_rMV, A_rMV, rhs_rMV);
cplex_rMV.Model.Q = 2*Q;
Qq_rMV = var_matr;
cplex_rMV.addQCs(zeros(size(f_rMV)), Qq_rMV, 'L', rob_bnd, {'qc_robust'});
cplex_rMV.Param.threads.Cur = 4;
cplex_rMV.Param.timelimit.Cur = 60;
cplex_rMV.Param.barrier.qcpconvergetol.Cur = 1e-12; % solution tolerance
options.DisplayFunc = 'off';
cplex_rMV.DisplayFunc = 'off'; % disable output to screen
cplex_rMV.solve();   
cplex_rMV.Solution;

if(isfield(cplex_rMV.Solution, 'x'))
    w_rMV = cplex_rMV.Solution.x;
    card_rMV = nnz(w_rMV);
    ret_rMV  = dot(mu, w_rMV);
    var_rMV = w_rMV' * Q * w_rMV;
    rob_rMV = w_rMV' * var_matr * w_rMV;
end
   


% Round near-zero portfolio weights
w_rMV_nonrnd = w_rMV;
w_rMV(find(w_rMV<=1e-6)) = 0;
w_rMV = w_rMV / sum(w_rMV);
[w_rMV_nonrnd w_rMV];

current_portfolio_value = (cur_prices*x_init) + cash_init; %Caclcuating Current Portfilio Value

Number_Stock_Units =  current_portfolio_value*w_rMV; %Calcuating Number of Stocks per Asset to buy/sell

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

Number_Stock_Units = current_portfolio_value*w_rMV;

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

