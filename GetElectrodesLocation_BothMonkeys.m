function [ PMd, PFC, dCd, dPut ,VS_Cd, VS_Put, GPi, Amy,SessionNumber ]=GetElectrodesLocation_BothMonkeys(SessionNumber )

DorsoVentralProbe=horzcat(1:2:31,2:2:32);
Probe32Chs=DorsoVentralProbe;
Probe64Chs=horzcat(Probe32Chs,Probe32Chs+32);


A1= 1:32 ;  A2= 33:64;   A3= 65:96;   B1= 129:160;   B2= 161:192 ;   B3 = 193:224 ;   B4 = 225:256;   C1 = 257:288;  C4 = 353:384;
%%% For Pumpy - M@nkey1
if SessionNumber<4

    dCd=Probe64Chs(1:40)+128; %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=Probe64Chs(41:64)+128;  % 22 Chs for the Ventral Striatum (VS)

    PMd=[];
    PFC=[];
    dPut=Probe64Chs(1:39);
    VS_Put=Probe64Chs(40:64);
    GPi=Probe32Chs+64;
    Amy=[];
end

if SessionNumber>=4 && SessionNumber<=8

    dCd=Probe64Chs(1:40); %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=Probe64Chs(41:64);  % 22 Chs for the Ventral Striatum (VS)
    PMd=B1;
    PFC=[];
    dPut=Probe64Chs(1:40)+192;
    VS_Put=Probe64Chs(41:64)+192;
    GPi=Probe32Chs+64;
    Amy=[];
end


if SessionNumber ==9
    del_Chs=149;
    PFC=setdiff(B1,del_Chs);
    dCd=Probe64Chs(1:40); %  22 Chs for the dorsal Caudate (dCd)
    VS_Cd=Probe64Chs(41:64);  % 22 Chs for the Ventral Striatum (VS)
    PMd=[];
    dPut=Probe64Chs+192;
    VS_Put=[];
    GPi=Probe32Chs+64;
    Amy=[];
end

if SessionNumber ==10
    del_Chs=[131 133 135 153];
    PFC=setdiff(B1,del_Chs);
    dCd=Probe64Chs(1:40); %  22 Chs for the dorsal Caudate (dCd)
    VS_Cd=Probe64Chs(41:64);  % 22 Chs for the Ventral Striatum (VS)
    PMd=[];
    %     PFC=B1;
    dPut=Probe64Chs+192;
    VS_Put=[];
    GPi=Probe32Chs+64;
    Amy=[];
end

if SessionNumber ==11
    PFC=B1;
    dCd=Probe64Chs(1:40); %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=Probe64Chs(41:64);  % 22 Chs for the Ventral Striatum (VS)
    PMd=[];
    dPut=Probe64Chs+192;
    VS_Put=[];
    GPi=Probe32Chs+64;
    Amy=[];
end

if SessionNumber ==12
    del_Chs=[135 138];
    PFC=setdiff(B1,del_Chs);
    dCd=Probe64Chs(1:40); %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=Probe64Chs(41:64);  % 22 Chs for the Ventral Striatum (VS)
    PMd=[];
    %     PFC=B1;
    dPut=Probe64Chs+192;
    VS_Put=[];
    GPi=Probe32Chs+64;
    Amy=[];
end

if SessionNumber ==13
    del_Chs=159;
    PFC=setdiff(B1,del_Chs);
    dCd=Probe64Chs(1:40); %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=Probe64Chs(41:64);  % 22 Chs for the Ventral Striatum (VS)
    PMd=[];
    %     PFC=B1;
    dPut=Probe64Chs+192;
    VS_Put=[];
    GPi=Probe32Chs+64;
    Amy=[];
end

if SessionNumber ==14
    del_Chs=[139 154 160];
    PFC=setdiff(B1,del_Chs);
    dCd=Probe64Chs(1:40); %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=Probe64Chs(41:64);  % 22 Chs for the Ventral Striatum (VS)
    PMd=[];
    %     PFC=B1;
    dPut=Probe64Chs+192;
    VS_Put=[];
    GPi=Probe32Chs+64;
    Amy=[];
end

if SessionNumber ==15
    del_Chs=[229 234];
    PFC=setdiff(B4,del_Chs);
    dCd=Probe64Chs(1:40); %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=Probe64Chs(41:64);  % 22 Chs for the Ventral Striatum (VS)
    PMd=B3;
    %     PFC=B4;
    dPut= Probe64Chs(1:32)+64 ;
    VS_Put= Probe32Chs(1:32)+128 ;
    GPi=[];
    Amy=[];
end

if SessionNumber ==16 || SessionNumber ==18 || SessionNumber ==19
    PFC=B4;
    dCd=Probe64Chs(1:40); %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=Probe64Chs(41:64);  % 22 Chs for the Ventral Striatum (VS)
    PMd=B3;
    %     PFC=B4;
    dPut= Probe64Chs(1:32)+64 ;
    VS_Put= Probe32Chs(1:32)+128 ;
    GPi=[];
    Amy=[];
end

if SessionNumber ==17
    del_Chs=241;
    PFC=setdiff(B4,del_Chs);
    dCd=Probe64Chs(1:40); %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=Probe64Chs(41:64);  % 22 Chs for the Ventral Striatum (VS)
    PMd=B3;
    %     PFC=B4;
    dPut= Probe64Chs(1:32)+64 ;
    VS_Put= Probe32Chs(1:32)+128 ;
    GPi=[];
    Amy=[];
end

if SessionNumber ==20
    del_Chs=[244 237 225];
    PFC=setdiff(B4,del_Chs);
    dCd=Probe64Chs(1:40); %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=Probe64Chs(41:64);  % 22 Chs for the Ventral Striatum (VS)
    PMd=B3;
    %     PFC=B4;
    dPut= Probe64Chs(1:32)+64 ;
    VS_Put= Probe32Chs(1:32)+128 ;
    GPi=[];
    Amy=[];
end
if SessionNumber ==21
    del_Chs=239;
    PFC=setdiff(B4,del_Chs);
    dCd=Probe64Chs(1:40); %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=Probe64Chs(41:64);  % 22 Chs for the Ventral Striatum (VS)
    PMd=B3;
    %     PFC=B4;
    dPut= Probe64Chs(1:32)+64 ;
    VS_Put= Probe32Chs(1:32)+128 ;
    GPi=[];
    Amy=[];
end


if SessionNumber>=22 && SessionNumber<=32
    dCd=[];
    VS_Cd=[];
    PMd=[];
    PFC=[];
    dPut=[];
    VS_Put=[];
    GPi=[];
    Amy=Probe64Chs;
end





%%%% For LUpe- M@nkey 2
if SessionNumber==1+32

    dCd=[]; %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=[];  % 22 Chs for the Ventral Striatum (VS)

    PMd=[];
    PFC=[];
    dPut=[];
    VS_Put=[];
    GPi=Probe32Chs+64;
    Amy=Probe64Chs;
end

if SessionNumber>=2+32 && SessionNumber<=3+32

    dCd=Probe64Chs(1:40)+128; %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=Probe64Chs(41:64)+128;  % 22 Chs for the Ventral Striatum (VS)
    PMd=[];
    PFC=[];
    dPut=Probe64Chs(1:40);
    VS_Put=Probe64Chs(41:64);
    GPi=Probe32Chs+64;
    Amy=[];
end

if SessionNumber>=4+32 && SessionNumber<=9+32

    dCd=Probe64Chs(1:40)+128; %  22 Chs for the dorsal Caudate (dCd)
    % m_Cd=Probe64Chs(23:42); % 20 Chs for the  medial  Caudate (mCd)
    VS_Cd=Probe64Chs(41:64)+128;  % 22 Chs for the Ventral Striatum (VS)
    PMd=[];
    PFC=[];
    dPut=[];
    VS_Put=[];
    GPi=Probe32Chs+64;
    Amy=Probe64Chs;
end


if SessionNumber>=10+32
    dCd    = Probe64Chs(1:40)  ;
    VS_Cd  = Probe64Chs(41:64) ;
    PMd    = Probe32Chs + 256  ;
    PFC    = Probe32Chs + 64   ;
    dPut   = Probe64Chs(1:40) + 192 ;
    VS_Put = Probe64Chs(41:64) + 192;
    GPi    = Probe32Chs + 352;
    Amy    = [];
end
end
