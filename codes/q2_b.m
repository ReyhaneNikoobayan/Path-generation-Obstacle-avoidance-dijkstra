clc;
clear;
close all;
data = importdata('input3.txt', ' ') ; 
N= data(1);

for i=1:N
    A(i,1)=data(4*i-2);
    A(i,2)=data(4*i-1);   % save point of obstacle
    A(i,3)=data(4*i);
    A(i,4)=data(4*i+1);
end

S=[data(N*4+2),data(N*4+3)];
F=[data(N*4+4),data(N*4+5)];      % save start and end point
start=S;
final=F;

plot([S(1),F(1)],[S(2),F(2)],'ro','LineWidth',2);
hold on

k=0; % polynomyial
B=A;
L=1;
while size(B,1)~=0             % organize obstacle and formation ross
    value=true;
    k=k+1;
    obs{k}(:,1)=[B(1,1);B(1,2)];
    obs{k}(:,2)=[B(1,3);B(1,4)];
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
                
                obs{k}(:,r)=[B(j,3);B(j,4)];
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
                obs{k}(:,r)=[B(j,1);B(j,2)];
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

R=cat(1,R,S) ;
R=cat(1,R,F) ;

n_obs=size(obs,2);
K=1;
for i=1:n_obs     % formation all side obs
    edj=size(obs{i},2)-1;
    for j=1:edj
        for q=1:edj
           if j==q
               continue
           end
           
           yall_obs(k,:)=[obs{i}(1,j),obs{i}(2,j),obs{i}(1,q),obs{i}(2,q)];
           k=k+1;
        end
    end
end
yall_obs(1,:)=[];
yall_obs(1,:)=[];
Yall=zeros(size(R,1),size(R,1));
for i=1:(size(R,1))       %recognize possible yall
    for j=1:(size(R,1))
        value=fun(R(i,:),R(j,:),yall_obs);
        Yall(i,j)=value;
    end
end
number_p=size(R,1);
value=ones(number_p,1)*inf;
value(number_p)=0;

path_1=[number_p] ;
j=1 ;

Yall2=Yall;
while j~=number_p    %dikestra
  min=1000;  
  for i=1:number_p
    if Yall2(path_1(j),i)~=0
        t=value(path_1(j))+ Yall2(path_1(j),i);
        if t<value(i)
            value(i)=t;
        end
        
        if value(i)<min
            min=value(i);
            next=i;
            
        end
    
    end

  end
  path_1=cat(2,path_1,next);
 
  for k=1:number_p
      Yall2(path_1(j),k)=0;
      Yall2(k,path_1(j))=0;
  end
  j=j+1;
end


final_path=[number_p-1];
j=1;

while final_path(j)~=number_p
    for i=1:number_p
        if (value(final_path(j))==(value(i)+Yall(final_path(j),i))) && Yall(final_path(j),i)~=0
           
           next=i;
           final_path=cat(2,final_path,next);
           plot([R(final_path(j),1),R(next,1)],[R(final_path(j),2),R(next,2)],'b','LineWidth',2);
           j=j+1;
           hold on
           break
        end
    end
end

for i=1:n_obs
    o=polyshape(obs{i}(1,:),obs{i}(2,:));
    plot(o);
    hold on
end

