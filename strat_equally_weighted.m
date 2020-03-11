% Assignment - 2 #2015-16 (HARDIK CHUGH - 1005587866)
function [ x_opt, cash_opt ] = strat_equally_weighted( x_init, cash_init, mu, Q, cur_prices )

current_portfolio_value = (cur_prices*x_init) + cash_init; %Caclcuating Current Portfilio Value

Number_Stock_Units =  current_portfolio_value/20; %Calcuating Number of Stocks per Asset to buy/sell based on eqally weighted. 

x_opt_1 = Number_Stock_Units./cur_prices;

x_difference = round(x_init-(x_opt_1)');

x_opt = x_init-x_difference; %Optimal Number of Shares 

transaction_cost = cur_prices*abs(x_difference)*0.005; %Applying Transaction Cost to Assets Buy/Sell

new_portfolio_value = cur_prices*x_opt;

cash_opt = current_portfolio_value-new_portfolio_value-transaction_cost; % Optimal Cash Value in our Checking Account

% Verifying that Cash Account is non-negative after applying transcation
% The function is explained clearly in the report 

if cash_opt < 0 
    
current_portfolio_value = (cur_prices*x_init) +cash_init;

Number_Stock_Units =  current_portfolio_value/20;

x_opt_1 = Number_Stock_Units./cur_prices;

x_difference = floor(x_init-(x_opt_1)');


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

x = x_opt;

w_eq=cur_prices.*x'/(cur_prices*x);

w1 = max(w_eq)-min(w_eq);

end




