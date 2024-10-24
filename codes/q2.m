clc;
clear;
close all;
data = importdata('input2.txt', ' ') ; 
N= data(1);

for i=1:N
    A(i,1)=data(4*i-2);
    A(i,2)=data(4*i-1);   % obstacle
    A(i,3)=data(4*i);
    A(i,4)=data(4*i+1);
end

S=[data(N*4+2),data(N*4+3)];
F=[data(N*4+4),data(N*4+5)];
start=S;
final=F;

plot([S(1),F(1)],[S(2),F(2)],'ro','LineWidth',2);
hold on

M=data((N+1)*4+2);

robat=zeros(M,2);
for i=1:M
    robat(i,1)=data((N+1)*4+2*i+1);
    robat(i,2)=data((N+1)*4+2*i+2);     % yall Robat
end
V=zeros(2,M);

modified_point=transpose(robat(1,:));
for p=1:M
    
    t=transpose(robat(p,:)-robat(1,:));     % vector V
    V(:,p)=transpose(t);
end


k=0; % polynomyial
B=A;
L=1;
while size(B,1)~=0        % recognize obs
    value=true;
    k=k+1;
    obs{k}{1}=[B(1,1);B(1,2)];
    obs{k}{2}=[B(1,3);B(1,4)];
    R(L,:)=[B(1,1);B(1,2)];
    L=L+1;
    R(L,:)=[B(1,3);B(1,4)];
     L=L+1;
    c1=B(1,1);
    c2=B(1,2);
    c3=B(1,3);
    c4=B(1,4);
    r=3;
    B(1,:)=[];
  
   while value==true && size(B,1)~=0
    for j=1:size(B,1)
        if (c3==B(j,1)) && (c4==B(j,2))
                
                obs{k}{r}=[B(j,3);B(j,4)];
                c1=B(j,1);
                c2=B(j,2);
                c3=B(j,3);
                c4=B(j,4);

                R(L,:)=[B(j,3);B(j,4)];
                L=L+1;
                B(j,:)=[];
                r=r+1;
                break                          
           
        elseif c3==B(j,3) && c4==B(j,4) 
                obs{k}{r}=[B(j,1);B(j,2)];
                c1=B(j,3);
                c2=B(j,4);
                c3=B(j,1);
                c4=B(j,2);
                R(L,:)=[B(j,1);B(j,2)];
                L=L+1;
                
                B(j,:)=[];
                r=r+1;
                break
        elseif j==size(B,1)
            value=false ;
   
        end

    end
  
   end

   s=size(R,1);
   R(s,:)=[];
   L=L-1;

end

n_obs=size(obs,2);

min_point=zeros(1,n_obs);
for i=1:n_obs     % formation all new point for each obstacle and seperate X_min
    min_x=1000;
    edj=size(obs{1,i},2)-1;
    for j=1:edj
        for k=1:M
             new_point{i}(:,(j-1)*4+k)=obs{1,i}{1,j}+V(:,k);
             if min_x>new_point{i}(1,(j-1)*4+k)
                 min_x=new_point{i}(1,(j-1)*4+k);
                 min_point(i)=(j-1)*4+k;
             end
        end
    end

end

for i=1:n_obs
   n_con=size(new_point{i},2) ;
   q1=new_point{i}(:,min_point(i));
   qL=q1-[1;0];
   qc=q1;
   j=1;
   con{i}(1)=min_point(i);
   Poly{i}(:,1)=q1;
   while con{i}(j)~=min_point(i) || j==1
       
       alpha_min=360;
       for k=1:n_con
           qi=new_point{i}(:,k);
           v=qi-qc;
           v=cat(1,v,0);
           u=qL-qc;
           u=cat(1,u,0);
           cos=(dot(u,v))/(norm(u)*norm(v));
           K=[0;0;-1];
           sin=(dot(cross(u,v),K))/(norm(u)*norm(v));
           alpha=atan2(sin,cos);
           if alpha<0
               alpha=2*pi+alpha;
           end
           if alpha==0
               alpha=2*pi;
           end
           if alpha<alpha_min
               alpha_min=alpha;
               next=k;
           end
       end
       j=j+1;
       qL=qc;
       
     
       qc=new_point{i}(:,next);
       con{i}(j)=next;
       Poly{i}(:,j)=new_point{i}(:,next);
 
 
   end
   obs{i}=polyshape(Poly{i}(1,:),Poly{i}(2,:));
   plot(obs{i});
   hold on
 
end
k=1;

for i=1:size(con,2)
   for j=1:size(con{i},2)-1
       Y(k,:)=[new_point{i}(1,con{i}(j)),new_point{i}(2,con{i}(j)), new_point{i}(1,con{i}(j+1)),new_point{i}(2,con{i}(j+1))];
       k=k+1;   
   end


end
A=Y;
N=k-1;

