function value=fun(A,B,obs)
   n=size(obs,1);
   A=transpose(A);
   B=transpose(B);
   value=1000;
   
   for i=1:n
       C=transpose(obs(i,1:2));
       D=transpose(obs(i,3:4));
       R=[B-A,D-C];
       ans=inv(R)*[D-A];
       alpha=ans(1);
       beta=ans(2);
       if alpha<0.99 && alpha>0.01  && beta<0.99 && beta>0.01
         value=0;
         break
       end
  
      
   end
   if value~=0
       value=norm(A-B);
   end


