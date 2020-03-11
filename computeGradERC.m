function gval = computeGradERC (x)

global C 
  
  n = size(C,1) ;  

 % if(size(x,1)==1)
 %    x = x';
 % end
  
 %% Analytical Solutions for the Gradient
   
  RC=C*x';
  gval=zeros(n,1);
  
  
  for k=1:n
      for i=1:n
          for j=i+1:n
              if k==i
                  gval(k)= gval(k) + (2*2*(((C(i,k)*x(i))) + RC(i)) - (C(j,k)*x(j))) * ((x(i)*RC(i))-(x(j)*RC(j)));
              elseif k==j
                  gval(k)= gval(k) + (2*2*((C(i,k)*x(i)) -((C(j,k)*x(j))+RC(j)))*((x(i)*RC(i)) - (x(j)*RC(j))));
              else
                  gval(k)= gval(k) + (2*2*((C(i,k)*x(i)) -(C(j,k)*x(j)))*((x(i)* RC(i)) - (x(j)*RC(j))));
              end
          end
      end
  end
  
    %Finite Differences Method
  
  h = 0.0001;
  
  global g
  
  g = ones(n,3);
  
  for i = 1:n
      for j = 1:3
          g(i,j) = (computeObjERC(x+h)-computeObjERC(x))/h;
          g(i,j) = (computeObjERC(x)-computeObjERC(x-h))/h;
          g(i,j) = (computeObjERC(x+0.5*h)-computeObjERC(x-0.5*h))/h;
          
      end
  end
  
  g = [g gval];
end







