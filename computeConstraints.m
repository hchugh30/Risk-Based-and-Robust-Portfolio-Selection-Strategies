function c = computeConstraints (x)

global A_ineq A_eq

if(isempty(A_ineq))
   c = [A_eq*x' ];
elseif(isempty(A_eq))
   c = [A_ineq*x' ];
else
   c = [A_eq*x'; A_ineq*x'];
end