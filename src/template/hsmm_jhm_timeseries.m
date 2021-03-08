function [PAI,A,P,mu,Sigma,mixmat,stateseq,LL]=hsmm_jhm_timeseries(Q,M,feature1,IterationNo)
%IterationNo迭代次数，0时仅计算最优状态序列和似然概率，大于0时重估参数且计算最优状态序列和似然概率
[O,T,nex]=size(feature1);%时间序列特征的维数
D=T;
cov_type='full';
%初始状态概率向量、状态转移矩阵，平均初始化
PAI=ones(Q,1);
PAI=PAI./sum(PAI);
A=rand(Q);
% A=1-eye(Q);
% PAI=zeros(Q,1);
% PAI(1)=1;
% A=zeros(Q);
% for i=1:Q
%     A(i,i:Q)=1;
% end
A=A./(sum(A')'*ones(1,Q)); 
P=repmat((1:D).^2,Q,1);
P=P./(sum(P')'*ones(1,D));
[mu,Sigma]=mixgauss_init(Q*M,feature1,cov_type);
mu=reshape(mu,[O,Q,M]);
Sigma=reshape(Sigma,[O O Q M]);
mixmat=mk_stochastic(rand(Q,M));
%中间计算量初始化
ALPHA=zeros(Q,D);%前向变量，alpha_t(i,d)=P(q_t=i,tao_t=d|o_1_t-1)
b=zeros(Q,T); %b_*_i(o_t)=b_i(o_t)/P(o_t|o_1_t-1)
S=zeros(Q,T);%S_t(i)=P(tao_t=1,q_t+1=i|o_1_t)
E=zeros(Q,T);%E_t(i)=P(q_t=i,tao_t=1|o_1_t)
BETA=ones(Q,D);
Ex=ones(Q,D);
Sx=ones(Q,D);
GAMMA=zeros(Q,1);
Pest=zeros(Q,D);
Aest=zeros(Q,Q);
postmix=zeros(Q,M);
m=zeros(O,Q,M);
op=zeros(O,O,Q,M);
ip=zeros(Q,M);
PAIest=zeros(Q,1); 
Qest=zeros(T,1);
ir1=max(1,IterationNo);
LL=[];
data=num2cell(feature1,[1 2]);
for ir=1:ir1
    Aest(:)=0;
    Pest(:)=0;
    postmix(:)=0;
    m(:)=0;
    op(:)=0;
    ip(:)=0;
    lkh=0;  
    stateseq=[];
    for on=1:nex	 % for each observation sequence
        obs=data{on};	 % the n'th observation sequence
        [B,B2]=mixgauss_prob(obs,mu,Sigma,mixmat);
        % B(i,t) = Pr(y(t) | Q(t)=i) 
        % B2(i,k,t) = Pr(y(t) | Q(t)=i, M(t)=k) 
        %    starttime=clock;
        %++++++++++++++++++     Forward     +++++++++++++++++
        %---------------    Initialization    ---------------
        ALPHA(:)=0; ALPHA=repmat(PAI,1,D).*P;		%Equation (13)t=1时alpha
        r=(B(:,1)'*sum(ALPHA,2));			%Equation (3)t=1时r_t_-1
        b(:,1)=B(:,1)./r;				%Equation (2)t=1时b^*_i(o_t)
        E(:)=0; E(:,1)=b(:,1).*ALPHA(:,1);		%Equation (5)
        S(:)=0; S(:,1)=A'*E(:,1);			%Equation (6)
        lkh=lkh+log(r);
        %---------------    Induction    ---------------
        for t=2:T
            ALPHA=[repmat(S(:,t-1),1,D-1).*P(:,1:D-1)+repmat(b(:,t-1),1,D-1).*ALPHA(:,2:D),S(:,t-1).*P(:,D)];		%Equation (12)
            r=(B(:,t)'*sum(ALPHA,2));		%Equation (3)
            b(:,t)=B(:,t)./r;			%Equation (2)
            E(:,t)=b(:,t).*ALPHA(:,1);		%Equation (5)
            S(:,t)=A'*E(:,t);				%Equation (6)
            lkh=lkh+log(r);
        end
        %++++++++ To check if the likelihood is increased ++++++++
%         if ir>1
%             %    clock-starttime
%             if (lkh-lkh1)/T<0.001
%                 break
%             end
%         end
%         lkh1=lkh;
        %++++++++ Backward and Parameter Restimation ++++++++
        %---------------    Initialization    ---------------
        
        Aest=Aest+E(:,T)*ones(1,Q);  %Since T_{T|T}(m,n) = E_{T}(m) a_{mn}
        GAMMA=b(:,T).*sum(ALPHA,2);
       %% for estimate of B
        denom=B(:,T)+(B(:,T)==0);
        gamma2(:,:,T)=B2(:,:,T).*mixmat.*repmat(GAMMA,[1 M])./repmat(denom,[1 M]);
             
        [X,Qest(T)]=max(GAMMA);
        
        BETA=repmat(b(:,T),1,D);				%Equation (7)
        Ex=sum(P.*BETA,2);					%Equation (8)
        Sx=A*Ex;						%Equation (9)
        
        %---------------    Induction    ---------------
        for t=(T-1):-1:1
            %% for estimate of A
            Aest=Aest+E(:,t)*Ex';
            %% for estimate of P
            Pest=Pest+repmat(S(:,t),1,D).*BETA;
            %% for estimate of state at time t
            GAMMA=GAMMA+E(:,t).*Sx-S(:,t).*Ex;
            GAMMA(GAMMA<0)=0;           % eleminate errors due to inaccurace of the computation.
            [X,Qest(t)]=max(GAMMA);
            denom=B(:,t)+(B(:,t)==0);
            gamma2(:,:,t)=B2(:,:,t).*mixmat.*repmat(GAMMA,[1 M])./repmat(denom,[1 M]);
            BETA=repmat(b(:,t),1,D).*[Sx,BETA(:,1:D-1)];	%Equation (14)
            Ex=sum(P.*BETA,2);					%Equation (8)
            Sx=A*Ex;						%Equation (9)
        end
        postmix=postmix+sum(gamma2,3);
        for i=1:Q
            for k=1:M
                w=reshape(gamma2(i,k,:),[1 T]);
                wobs=obs.*repmat(w,[O 1]);
                m(:,i,k)=m(:,i,k)+sum(wobs,2);
                op(:,:,i,k)=op(:,:,i,k)+wobs*obs';
                ip(i,k)=ip(i,k)+sum(sum(wobs.*obs,2));
            end
        end
        Pest=Pest+repmat(PAI,1,D).*BETA;    %Since D_{1|T}(m,d) = \PAI(m) P_{m}(d) \Beta_{1}(m,d)
        PAIest=PAIest+GAMMA./sum(GAMMA);
        stateseq=[stateseq Qest];
    end								% End for multiple observation sequences
    LL=[LL lkh];
    if IterationNo>0            % re-estimate parameters
        PAI=PAIest./sum(PAIest);
        Aest=Aest.*A;   A=Aest./repmat(sum(Aest,2),1,Q);
       [mu2,Sigma2]=mixgauss_Mstep(postmix,m,op,ip,'cov_type',cov_type);
        mu=reshape(mu2,[O Q M]);
        Sigma=reshape(Sigma2,[O O Q M]); 
        Pest=Pest.*P;   P=Pest./repmat(sum(Pest,2),1,D);
    end
    %%
    % 
    % * ITEM1
    % * ITEM2
    % 
    ir
end