function J = computeJacobian (x)

global A_ineq A_eq
  
  J = sparse([ A_eq; A_ineq ]);
