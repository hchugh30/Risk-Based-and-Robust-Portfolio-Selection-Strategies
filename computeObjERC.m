function fval = computeObjERC (x)

global C

  n = size(C,1) ;  

  if(size(x,1)==1)
     x = x';
  end
  
  y = x .* (C*x) ; 
  
  fval = 0 ; 
  
  for i = 1:n
    for j = i+1:n
      xij  = y(i) - y(j) ; 
      fval = fval + xij*xij ; 
    end 
  end
  
  fval = 2*fval ;     
  
end
