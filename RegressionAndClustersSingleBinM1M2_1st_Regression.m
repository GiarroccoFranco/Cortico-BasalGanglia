clearvars, clc
% close all
cd('C:\Users\giarroccof2\OneDrive - National Institutes of Health\Franco\NeuralData\') ;
Sessions = importdata('RecordingSessionsM1M2_Final.txt');
Folder=cd('C:\Users\giarroccof2\OneDrive - National Institutes of Health\Franco\NeuralData\') ;


Test='TestPumpy2_';
Year='2022';


% Sessions2Anal=[1:3 5:21];
Sessions2Anal=1:length(Sessions);
% Sessions2Anal=[1:3 5];

% EyeDirFS= nan(34,139,8);
% ArmDirFS= nan(34,139,8);
% EyeRWFS=nan(34,139,8);
% ArmRWFS= nan(34,139,8);
% EyeSARSAFS= nan(34,139,8);
% ArmSARSAFS= nan(34,139,8);
Bs_EyeArm_s=nan(2000,6,8);
ps_EyeArm_s=nan(2000,6,8);


AllSesspValue_ValueRew_Eye = nan(2000,65,8);
AllSesspValueDir_Eye= nan(2000,65,8);
AllSesspValueRw_Eye= nan(2000,65,8);
AllSess_pValueMotSyst_Eye= nan(2000,65,8);
AllSess_pValue_Rew_Eye= nan(2000,65,8);
AllSesspValue_DirMotSyst_Eye= nan(2000,65,8);
AllSesspValue_DirValue_Eye= nan(2000,65,8);
AllSesspValue_MotorSistValue_Eye= nan(2000,65,8);
AllSesspValue_RewDir_Eye= nan(2000,65,8);
AllSesspValue_RewMotSyst_Eye= nan(2000,65,8);

AllSesspSarsa_Eye= nan(2000,65,8);
                BetaDirEye=nan(2000,65,8);
                BetaRWEye=nan(2000,65,8);
                BetaSARSAEye=nan(2000,65,8);
                BetaRewEye=nan(2000,65,8);

                BetaDirArm=nan(2000,65,8);
                BetaRWArm=nan(2000,65,8);
                BetaSARSAArm=nan(2000,65,8);
                BetaRewArm=nan(2000,65,8);
AllSesspNF_Arm  = nan(2000,65,8);
AllSesspTr_Arm = nan(2000,65,8);
AllSesspNF_Eye = nan(2000,65,8);
AllSesspTr_Eye= nan(2000,65,8);
%
for nSession= Sessions2Anal
% for  nSession= 33
    nSession
    Session=[];
    Session=Sessions(nSession);
    subpath = fullfile(Folder);  

if nSession>32
    namefolder=strcat('0',num2str(Session));
    cd(strcat(subpath,'\',namefolder));
   load SessionSARSAValues.mat
   Sarsa = SessionSARSAValues;
         load TrialsMarkers.mat

   TrialsMarkers = TrialsMarkers;
end
if nSession<33
    StrSess=num2str(Session);
    subpath = fullfile(Folder, strcat(Test,StrSess(3:6),Year));
cd(subpath)
   load SARSASessionValues.mat
   Sarsa = SARSASessionValues;
      load TrialsMarkers_StimOn_100_50.mat
      TrialsMarkers=TrialsMarkers_StimOn_100_50;

end
   load SessionData_StimOn_250_50.mat;

   load SessionStimValues.mat


    SessionData = SessionData_StimOn_250_50;
    TrialsMarkers = TrialsMarkers;

    Value = SessionStimValues;

    % Trials markers (Reward - Direction of Movement - Chosen object - block - etc...)
    Directions=[]; %#ok<NASGU>
    Directions= FindDirection(TrialsMarkers);
    N_Block=TrialsMarkers.BlockCode;
    Reward=TrialsMarkers.Reward_Output;
    StimulusRew=TrialsMarkers.HighRewProbStimSelected ;
    Block=TrialsMarkers.HandBlocks;
    NovelTrialsHand=find(TrialsMarkers.NovelBlocksHand  ==1);
    NovelTrialsEye=find(TrialsMarkers.NovelBlocksEye ==1);

    NovelTrialsOnly=union(NovelTrialsHand,NovelTrialsEye);

    N_Block_Eye=N_Block(NovelTrialsEye);
    Bs=unique(N_Block,"stable");
    allBls=zeros(size(N_Block));

    for nb = 1: size(Bs,2)
        hg=[]; hg=find(N_Block==Bs(nb));
        allBls(hg)=nb;

    end

    Eye_Bs=unique(N_Block_Eye,"stable");
    all_Eye_tr=zeros(size(N_Block_Eye));

    for Eye_nb = 1: size(Eye_Bs,2)
        hg_eye=[]; hg_eye=find(N_Block_Eye==Eye_Bs(Eye_nb));
        all_Eye_tr(hg_eye)=Eye_nb;

    end


    N_Block_Hand=N_Block(NovelTrialsHand);
    Hand_Bs=unique(N_Block_Hand,"stable");
    all_Hand_tr=zeros(size(N_Block_Hand));

    for Hand_nb = 1: size(Hand_Bs,2)
        hg_Hand=[]; hg_Hand=find(N_Block_Hand==Hand_Bs(Hand_nb));
        all_Hand_tr(hg_Hand)=Hand_nb;

    end

    Novel_Trials=min([size(NovelTrialsEye,2) size(NovelTrialsHand,2) ]);
    Alltrials=1:length(Reward);
    Familiar_Hand=find(TrialsMarkers.NovelBlocksHand  ==0);
    Familiar_Eye=find(TrialsMarkers.NovelBlocksEye  ==0);
    



    Novel_vs_Familiar= []; Novel_vs_Familiar=zeros(length(Reward),1); Novel_vs_Familiar=Novel_vs_Familiar-1; Novel_vs_Familiar(NovelTrialsHand)=1; Novel_vs_Familiar(NovelTrialsEye)=1;
    nTrials=zeros(size(N_Block,2),1);

    Left  = find ( Directions== 1 );
    Right = find ( Directions== 0 );

    RTs=TrialsMarkers.RTs;

    HandTrials=find(Block==1); HandTrials_left=intersect(NovelTrialsHand,Left); HandTrials_right=intersect(NovelTrialsHand,Right);
    EyeTrials=find(Block==0);  EyeTrials_left=intersect(NovelTrialsEye,Left); EyeTrials_right=intersect(NovelTrialsEye,Right);
    TrialsToAnalize=   [];

    ImageIDs= DefineIDs (N_Block,StimulusRew);
 
BlockCount=N_Block-min(N_Block);
All_Trials_WithinBlock=TrialsMarkers.TrialWithinBlock;
uniqueTrials = unique(TrialsMarkers.TrialWithinBlock, 'stable'); % Unique trials in the input order
blockVector = zeros(size(TrialsMarkers.TrialWithinBlock)); % Preallocate for block numbers
currentBlock = 1; % Block index

% Loop through the trialNumbers to assign block numbers
for i = 1:length(TrialsMarkers.TrialWithinBlock)
    % Reset when trial number restarts (new block)
    if TrialsMarkers.TrialWithinBlock(i) == uniqueTrials(1) && i > 1
        currentBlock = currentBlock + 1;
    end
    blockVector(i) = currentBlock;
end

    % n_bin=-1240:20:1520; % for 30ms bin
    % n_bin=-1380:20:1500; % for 20s bin
    % n_bin=-1380:20:1500; % for 30ms bin
    % n_bin=-1600:20:1500; % for 30ms bin Mov On
    n_bin=SessionData.Times;
    TimeUsed=SessionData.Times;
    TimeIdx=ismember(SessionData.Times,n_bin);
    TimeStamp=find(TimeIdx==1);

    [ PMd,   PFC,   dCd, dPut ,VS_Cd, VS_Put, GPi, Amy, numberofsess ]=GetElectrodesLocation_BothMonkeys(nSession );

    % Neurons=[];
    % Neurons=NeuronsSessions.Neurons(nSession,:);
    %
    % if Neurons(1)<8
    %     PFC=[];
    % end
    % if Neurons(2)<8
    %     PMd=[];
    % end
    % if Neurons(3)<100
    %     Amy=[];
    % end
    % if Neurons(4)<8
    %     GPi=[];
    % end
    % if Neurons(5)<100
    %     VS_Put=[];
    % end
    % if Neurons(6)<8
    %     dPut=[];
    % end
    % if Neurons(7)<100
    %     VS_Cd=[];
    % end
    %
    % if Neurons(8)<8
    %     dCd=[];
    % end

    Alltrials=1:length(Reward);

    ET=1:15; LT=16:30;
    Earlytrials=find(ismember(TrialsMarkers.TrialWithinBlock,ET)==1);
    Latetrials=find(ismember(TrialsMarkers.TrialWithinBlock,LT)==1);

    Early_Eye=intersect(NovelTrialsEye,Earlytrials);
    Early_Arm=intersect(NovelTrialsHand,Earlytrials);

    Late_Eye=intersect(NovelTrialsEye,Latetrials);
    Late_Arm=intersect(NovelTrialsHand,Latetrials);



    TrialsToAnalize=NovelTrialsOnly;  %% HandTrials NovelTrialsEye EyeTrials NovelTrialsHand  FamiliarTrials Familiar_IDX_Eye Familiar_IDX_Hand


    % 
    % Value=Value(TrialsToAnalize);
    % Sarsa=Sarsa(TrialsToAnalize);
    % SV_Range=[(min (Value)) (max (Value))];
    % 
    % 
    % Sarsa_Range=[(min (Sarsa)) (max (Sarsa))];
    % low_SV=find(Value<=0.5);
    % % Med_SV=find(Value<=0.75 & Value>0.6 )
    % High_SV=find(Value>0.5 );
    % 
    % low_SARSA=find(Sarsa<=(max (Sarsa)/2));
    % % Med_SV=find(Value<=0.75 & Value>0.6 )
    % High_SARSA=find(Sarsa>(max (Sarsa)/2));
    % 
    %  HSa_Arm=intersect(High_SARSA, NovelTrialsHand); LSa_Arm=intersect(low_SARSA, NovelTrialsHand);
    % HSa_Eye=intersect(High_SARSA, NovelTrialsEye); LSa_Eye=intersect(low_SARSA, NovelTrialsEye);
    % 
    % HSv_Arm=intersect(High_SV, NovelTrialsHand); LSv_Arm=intersect(low_SV, NovelTrialsHand);
    % HSv_Eye=intersect(High_SV, NovelTrialsEye); LSv_Eye=intersect(low_SV, NovelTrialsEye);

    [DecData_PMd ]=CreateDataRegression_2(SessionData, TrialsToAnalize, TimeStamp, PMd);
    [DecData_PFC ]=CreateDataRegression_2(SessionData, TrialsToAnalize, TimeStamp, PFC);
    [DecData_dPut ]=CreateDataRegression_2(SessionData, TrialsToAnalize,  TimeStamp, dPut);
    [DecData_dCd ]=CreateDataRegression_2(SessionData, TrialsToAnalize, TimeStamp, dCd);
    [DecData_Vs_Put ]=CreateDataRegression_2(SessionData, TrialsToAnalize, TimeStamp, VS_Put);
    [DecData_Vs_Cd ]=CreateDataRegression_2(SessionData, TrialsToAnalize, TimeStamp, VS_Cd);
    [DecData_GPi ]=CreateDataRegression_2(SessionData, TrialsToAnalize, TimeStamp, GPi);
    [DecData_Amy]=CreateDataRegression_2(SessionData, TrialsToAnalize, TimeStamp, Amy);
    data={};
    data={ DecData_PMd, DecData_PFC, DecData_dPut, DecData_dCd, DecData_Vs_Put, DecData_Vs_Cd, DecData_GPi, DecData_Amy};

    for REG =  1:size(data,2)

        DataMat=data{1,REG};

        if isempty(DataMat)
            nneurons(nSession,REG)=0;
        elseif ~isempty(DataMat)
            nneurons(nSession,REG)=size(DataMat,3);

            % MpredSARSA=[]; MpredDirection=[]; MpredValue=[];
            % for vlen=1:size(TrialsToAnalize,2)
            %     for neu1=1:size(DataMat,2)
            % 
            %         MpredSARSA(vlen,neu1,:)=Sarsa(vlen);
            %         MpredDirection(vlen,neu1,:)=Direction(vlen);
            %         MpredValue(vlen,neu1,:)=Value(vlen);
            %     end
            % end

            BetaDir_Eye=[]; BetaRw_Eye=[]; BetaMotSyst_Eye=[];  Beta_Rew_Eye=[]; Beta_DirMotSyst_Eye=[];  
            Beta_DirValue_Eye=[]; Beta_MotorSistValue_Eye=[]; Beta_RewDir_Eye=[];   Beta_RewMotSyst_Eye=[];


            Beta_ObjID_Eye =[];  Beta_ValueRew_Eye =[]; Beta_ObjIDMotSyst_Eye =[];
            pValueDir_Eye=[]; pValueRw_Eye=[]; pValueMotSyst_Eye=[];  pValue_Rew_Eye=[]; pValue_DirMotSyst_Eye=[];  
            pValue_DirValue_Eye=[]; pValue_MotorSistValue_Eye=[]; pValue_RewDir_Eye=[];   pValue_RewMotSyst_Eye=[];


 pValue_ObjID_Eye =[];  pValue_ValueRew_Eye =[]; pValue_ObjIDMotSyst_Eye =[];
           

zero_dir=find(Directions==0); 
Directions(zero_dir)=-1;
            for   neu=1:size(DataMat,3)
                parfor bin=1:size(DataMat,2) %% Use parfor here

                    Bdir=[];  Bdir=[]; Bsarsa=[];

                 
                  if nSession <33
  
%                           X_nested_e = [Directions' , Value,Block',Reward',TrialsMarkers.RTs',allBls'];
                          X_nested_e = [Directions(NovelTrialsOnly)' , Value(NovelTrialsOnly),Block(NovelTrialsOnly)',Reward(NovelTrialsOnly)',TrialsMarkers.RTs(NovelTrialsOnly)',ImageIDs(NovelTrialsOnly)'];
% ImageIDs
                  elseif nSession >32

%                           X_nested_e = [Directions' , Value',Block',Reward',TrialsMarkers.RTs',allBls'];

                          X_nested_e = [Directions(NovelTrialsOnly)' , Value(NovelTrialsOnly)',Block(NovelTrialsOnly)',Reward(NovelTrialsOnly)',TrialsMarkers.RTs(NovelTrialsOnly)',ImageIDs(NovelTrialsOnly)'];



                  end

                    B_Eye = fitlm(X_nested_e,DataMat(:,bin,neu),'interactions' ,"CategoricalVars", [1 3 4 ],...
                        'VarNames',{'Dir','Value','MotSyst','Rew','RT','ObjectID','Y'});


                    BetaDir_Eye  (neu,bin)=B_Eye.Coefficients{2,1};
                    BetaRw_Eye  (neu,bin)=B_Eye.Coefficients{3,1};
                    BetaMotSyst_Eye  (neu,bin)=B_Eye.Coefficients{4,1};
                    Beta_Rew_Eye  (neu,bin)=B_Eye.Coefficients{5,1};
                    Beta_ObjID_Eye  (neu,bin)=B_Eye.Coefficients{7,1};
                    Beta_DirValue_Eye  (neu,bin)=B_Eye.Coefficients{8,1};
                    Beta_DirMotSyst_Eye  (neu,bin)=B_Eye.Coefficients{9,1};
                    Beta_RewDir_Eye  (neu,bin)=B_Eye.Coefficients{10,1};
                    Beta_MotorSistValue_Eye  (neu,bin)=B_Eye.Coefficients{13,1};
                    Beta_ValueRew_Eye  (neu,bin)=B_Eye.Coefficients{14,1};
                    Beta_RewMotSyst_Eye  (neu,bin)=B_Eye.Coefficients{17,1};
                    Beta_ObjIDMotSyst_Eye  (neu,bin)=B_Eye.Coefficients{19,1};


                    pValueDir_Eye  (neu,bin)=B_Eye.Coefficients{2,4};
                    pValueRw_Eye  (neu,bin)=B_Eye.Coefficients{3,4};
                    pValueMotSyst_Eye  (neu,bin)=B_Eye.Coefficients{4,4};
                    pValue_Rew_Eye  (neu,bin)=B_Eye.Coefficients{5,4};
                    pValue_ObjID_Eye  (neu,bin)=B_Eye.Coefficients{7,4};
                    pValue_DirValue_Eye  (neu,bin)=B_Eye.Coefficients{8,4};
                    pValue_DirMotSyst_Eye  (neu,bin)=B_Eye.Coefficients{9,4};
                    pValue_RewDir_Eye  (neu,bin)=B_Eye.Coefficients{10,4};
                    pValue_MotorSistValue_Eye  (neu,bin)=B_Eye.Coefficients{13,4};
                    pValue_ValueRew_Eye  (neu,bin)=B_Eye.Coefficients{14,4};
                    pValue_RewMotSyst_Eye  (neu,bin)=B_Eye.Coefficients{17,4};
                    pValue_ObjIDMotSyst_Eye  (neu,bin)=B_Eye.Coefficients{19,4};




                  

                end
            end


            if nSession==1
                StNeu=sum(nneurons(:,REG));

                StN=0;

                BetaDirEye (StN+1:StNeu,:,REG)  =    BetaDir_Eye;
                BetaRWEye (StN+1:StNeu,:,REG)  =    BetaRw_Eye;
                BetaSARSAEye (StN+1:StNeu,:,REG)  =    BetaMotSyst_Eye;
                BetaRewEye (StN+1:StNeu,:,REG)  =    Beta_Rew_Eye;
                BetaObjIDEye (StN+1:StNeu,:,REG)  =    Beta_ObjID_Eye;
                BetaValueRewEye (StN+1:StNeu,:,REG)  =    Beta_ValueRew_Eye;

                BetaDirMotSystEye (StN+1:StNeu,:,REG)  =    Beta_DirMotSyst_Eye;
                BetaDirValueEye (StN+1:StNeu,:,REG)  =    Beta_DirValue_Eye;
                BetaMotorSistValueEye (StN+1:StNeu,:,REG)  =    Beta_MotorSistValue_Eye;
                BetaRewDirEye (StN+1:StNeu,:,REG)  =    Beta_RewDir_Eye;
                BetaRewMotSystEye(StN+1:StNeu,:,REG)  =    Beta_RewMotSyst_Eye;
                BetaObjIDMotSystEye(StN+1:StNeu,:,REG)  =   Beta_ObjIDMotSyst_Eye;


                AllSesspValueDir_Eye(StN+1:StNeu,:,REG)=pValueDir_Eye;
                AllSesspValueRw_Eye(StN+1:StNeu,:,REG)=pValueRw_Eye;
                AllSess_pValueMotSyst_Eye(StN+1:StNeu,:,REG)=pValueMotSyst_Eye;
                AllSess_pValue_Rew_Eye(StN+1:StNeu,:,REG)=pValue_Rew_Eye;
                AllSess_pValue_ObjID_Eye(StN+1:StNeu,:,REG)=pValue_ObjID_Eye;

                AllSesspValue_ValueRew_Eye(StN+1:StNeu,:,REG)=pValue_ValueRew_Eye;
                AllSesspValue_ObjIDMotSyst_Eye(StN+1:StNeu,:,REG)=pValue_ObjIDMotSyst_Eye;

               


                AllSesspValue_DirMotSyst_Eye(StN+1:StNeu,:,REG)=pValue_DirMotSyst_Eye;
                AllSesspValue_DirValue_Eye(StN+1:StNeu,:,REG)=pValue_DirValue_Eye;
                AllSesspValue_MotorSistValue_Eye(StN+1:StNeu,:,REG)=pValue_MotorSistValue_Eye;
                AllSesspValue_RewDir_Eye(StN+1:StNeu,:,REG)=pValue_RewDir_Eye;
                AllSesspValue_RewMotSyst_Eye(StN+1:StNeu,:,REG)=pValue_RewMotSyst_Eye;




            else
                StNeu=sum(nneurons(1:nSession-1,REG));
                StNeu2=nneurons(nSession,REG);

                BetaDirEye (StNeu+1:StNeu+StNeu2,:,REG)  =    BetaDir_Eye;
                BetaRWEye (StNeu+1:StNeu+StNeu2,:,REG)  =    BetaRw_Eye;
                BetaSARSAEye (StNeu+1:StNeu+StNeu2,:,REG)  =    BetaMotSyst_Eye;
                BetaRewEye (StNeu+1:StNeu+StNeu2,:,REG)  =    Beta_Rew_Eye;
                BetaObjIDEye (StNeu+1:StNeu+StNeu2,:,REG)  =    Beta_ObjID_Eye;
               BetaValueRewEye (StNeu+1:StNeu+StNeu2,:,REG)   =    Beta_ValueRew_Eye;
               
                BetaDirMotSystEye (StNeu+1:StNeu+StNeu2,:,REG)  =    Beta_DirMotSyst_Eye;
                BetaDirValueEye (StNeu+1:StNeu+StNeu2,:,REG)  =    Beta_DirValue_Eye;
                BetaMotorSistValueEye (StNeu+1:StNeu+StNeu2,:,REG)  =    Beta_MotorSistValue_Eye;
                BetaRewDirEye (StNeu+1:StNeu+StNeu2,:,REG)  =    Beta_RewDir_Eye;
                BetaRewMotSystEye(StNeu+1:StNeu+StNeu2,:,REG)  =    Beta_RewMotSyst_Eye;
                 BetaObjIDMotSystEye(StNeu+1:StNeu+StNeu2,:,REG) =   Beta_ObjIDMotSyst_Eye;

                AllSess_pValue_ObjID_Eye(StNeu+1:StNeu+StNeu2,:,REG)=pValue_ObjID_Eye;
                AllSesspValueDir_Eye(StNeu+1:StNeu+StNeu2,:,REG)=pValueDir_Eye;
                AllSesspValueRw_Eye(StNeu+1:StNeu+StNeu2,:,REG)=pValueRw_Eye;
                AllSess_pValueMotSyst_Eye(StNeu+1:StNeu+StNeu2,:,REG)=pValueMotSyst_Eye;
                AllSess_pValue_Rew_Eye(StNeu+1:StNeu+StNeu2,:,REG)=pValue_Rew_Eye;
                AllSesspValue_DirMotSyst_Eye(StNeu+1:StNeu+StNeu2,:,REG)=pValue_DirMotSyst_Eye;
                AllSesspValue_DirValue_Eye(StNeu+1:StNeu+StNeu2,:,REG)=pValue_DirValue_Eye;
                AllSesspValue_MotorSistValue_Eye(StNeu+1:StNeu+StNeu2,:,REG)=pValue_MotorSistValue_Eye;
                AllSesspValue_RewDir_Eye(StNeu+1:StNeu+StNeu2,:,REG)=pValue_RewDir_Eye;
                AllSesspValue_RewMotSyst_Eye(StNeu+1:StNeu+StNeu2,:,REG)=pValue_RewMotSyst_Eye;
                AllSesspValue_ValueRew_Eye(StNeu+1:StNeu+StNeu2,:,REG)=pValue_ValueRew_Eye;
                AllSesspValue_ObjIDMotSyst_Eye(StNeu+1:StNeu+StNeu2,:,REG)=pValue_ObjIDMotSyst_Eye;
 
                DirEye_p =[]; RwEye_p=[]; SarsaEye_p=[];  DirArm_p=[];  RwArm_p=[];   SarsaArm_p=[];


            end

        end
    end

    % Bs_EyeArm_Sess  {1,nSession}=Bs_EyeArm;
end  %% cicle for Sessions

% AllPSessions_Arm= { AllSesspDir_Arm , AllSess_pRw_Arm , AllSesspSarsa_Arm ,  AllSesspNF_Arm , AllSesspTr_Arm};
AllPSessions_Eye= { AllSesspValueDir_Eye , AllSesspValueRw_Eye , AllSess_pValueMotSyst_Eye , ...
    AllSess_pValue_Rew_Eye , AllSesspValue_DirMotSyst_Eye, AllSesspValue_DirValue_Eye, ... 
    AllSesspValue_MotorSistValue_Eye, AllSesspValue_RewDir_Eye, AllSesspValue_RewMotSyst_Eye, ...
    AllSesspValue_ValueRew_Eye   };


AllPSessions = { AllPSessions_Eye};


% AllBetasSessions_Arm= { BetaDirArm , BetaRWArm , BetaSARSAArm ,  BetaRewArm};
% AllBetasSessions_Eye= { BetaDirEye , BetaRWEye , BetaSARSAEye ,  BetaRewEye };
% 0902('AllPSessions','AllPSessions')

 
keyboard

% 0902('Bs_EyeArm_s','Bs_EyeArm_s')
% 0902('ps_EyeArm_s','ps_EyeArm_s')
% 
% 0902('nneurons','nneurons')

%%
% load Bs_EyeArm_s
% load ps_EyeArm_s
% load AllPSessions

%%
%% =========================== 1. PLOT SIGNIFICANCE  =============================
%% =======================================================================




% Colors = [ [0 120 0]/255;     
%            [160 220 70]/255;
%            [27 161 226]/255;
%            [90 55 210]/255;
%            [195 59 100]/255;
%            [255 120 220]/255;
%            [150 150 150]/255;
%            [255 150 0]/255 ];
Colors = [ [54 140 66]/255;     
           [210 212 113]/255;
           [59 127 137]/255;
           [175 149 132]/255;
           [67 170 175]/255;
           [232 174 135]/255;
           [140 140 140]/255;
           [243 168 168]/255 ];

predictorNames = {'Direction','Value','MSyst','Outcome', ...
    'DirMSyst', 'DirValue','ValueMSyst','DirOutcome','OutcomeMSyst','ValueOutcome'};





% ========================= 
% plot_all_predictorsBothMonkeys_main(AllPSessions_Eye, 'main - both monkeys', Colors, predictorNames, TimeUsed);
% plot_all_predictorsBothMonkeys(AllPSessions_Eye, 'EYE - both monkeys', Colors, predictorNames, TimeUsed);

plot_all_predictorsBothMonkeys_main1(AllPSessions_Eye, '2monkeys', Colors, predictorNames, TimeUsed);
%%
Object_alignment = AllPSessions_Eye;
% save('Object_alignment',"Object_alignment")

%% ================== 1.2 SPLIT INTO MONKEY 1 AND MONKEY 2 ======================
%% =======================================================================

nAreas = 8;
nPredictors = 10;

% AllPSessions_Arm_M1 = cell(1,5);
% AllPSessions_Arm_M2 = cell(1,5);
AllPSessions_Eye_M1 = cell(1,5);
AllPSessions_Eye_M2 = cell(1,5);

% Total neurons per monkey per area
nM1 = sum(nneurons(1:32,:), 1);       % 1 × 8
nM2 = sum(nneurons(33:end,:), 1);     % 1 × 8

for pred = 1:nPredictors

%     pMatArm = AllPSessions_Arm{pred};    % 2000 × 65 × 8
    pMatEye = AllPSessions_Eye{pred};

%     pMatArm_M1 = nan(2000,65,8);
%     pMatArm_M2 = nan(2000,65,8);
    pMatEye_M1 = nan(2000,65,8);
    pMatEye_M2 = nan(2000,65,8);

    for area = 1:nAreas

        % Row ranges for this area
        idx_M1_end = nM1(area);
        idx_M2_end = nM1(area) + nM2(area);

        % Extract from the full-stack matrix
        M1_rows = 1:idx_M1_end;
        M2_rows = idx_M1_end+1 : idx_M2_end;

        % ARM
%         pMatArm_M1(M1_rows,:,area) = pMatArm(M1_rows,:,area);
%         pMatArm_M2(1:length(M2_rows),:,area) = pMatArm(M2_rows,:,area);

        % EYE
        pMatEye_M1(M1_rows,:,area) = pMatEye(M1_rows,:,area);
        pMatEye_M2(1:length(M2_rows),:,area) = pMatEye(M2_rows,:,area);

    end

    % Store
%     AllPSessions_Arm_M1{pred} = pMatArm_M1;
%     AllPSessions_Arm_M2{pred} = pMatArm_M2;
    AllPSessions_Eye_M1{pred} = pMatEye_M1;
    AllPSessions_Eye_M2{pred} = pMatEye_M2;

end
% plot_all_predictors(AllPSessions_Arm_M1, 'ARM — Monkey 1', Colors, predictorNames, TimeUsed);
% plot_all_predictors(AllPSessions_Arm_M2, 'ARM — Monkey 2', Colors, predictorNames, TimeUsed);


plot_all_predictorsBothMonkeys_main1(AllPSessions_Eye_M1, 'Monkey 1', Colors, predictorNames, TimeUsed);
% plot_all_predictorsBothMonkeys_main1(AllPSessions_Eye_M2, 'Monkey 2', Colors, predictorNames, TimeUsed);


%%
areaLabels = {'PMd','vPFC','Put','Cd','lVS','mVS','GPi','Amy'};

computeAndPlotSustainedFractions(...
    AllPSessions_Eye, ...
    predictorNames, ...
    areaLabels, ...
    TimeUsed, ...
    Colors, ...
    0, ...    % tStart in ms
    500, ... % tEnd in ms
    1)        % minSepBins
%%
% areaLabels = {'PMd','vPFC','Put','Cd','lVS','mVS','GPi','Amy'};
% 
% for ds = 1
%     computeAndPlotSustainedFractions_v3(...
%         AllPSessions_Eye, predictorNames, areaLabels, ...
%         TimeUsed, Colors, 0, 1200, ds)
% end

%%
computeAndPlotSustainedFractions_v4(...
        AllPSessions_Eye, predictorNames, areaLabels, ...
        TimeUsed, Colors, -600, 1200)

%%


areaLabels = {'PMd','vPFC','Put','Cd','lVS','mVS','GPi','Amy'};

computeAndPlotSustainedFractions_v2(...
    AllPSessions_Eye, predictorNames, areaLabels, ...
    TimeUsed, Colors, 0, 1000)
%%

computeAndPlotFractions_v3(AllPSessions_Eye_M1, predictorNames, ...
    areaLabels, TimeUsed, Colors, -0, 500)
%%   
% ============================================================
% FIND PEAK CODING BIN FOR EACH AREA, REGRESSOR, EFFECTOR
%  - Pooled across monkeys
%  - Separately for Monkey 1 (sessions 1–34) and Monkey 2 (35–52)
% ============================================================

nPredictors = 5;   % e.g., 5 regressors
[~, nBins, nAreas] = size(AllPSessions{1});

pvalsign = 0.05;

% ---------- definizione scimmie ----------
nSessions   = size(nneurons,1);
idxM1_sess  = 1:32;
idxM2_sess  = 33:nSessions;

% ---------- pre-computiamo gli indici dei neuroni M1 / M2 per area ----------
idxM1_neu_all = cell(nAreas,1);
idxM2_neu_all = cell(nAreas,1);

for a = 1:nAreas

    idxStart = 1;
    idxM1 = [];
    idxM2 = [];

    for s = 1:nSessions
        nThis = nneurons(s,a);
        if nThis == 0
            continue
        end

        idxEnd = idxStart + nThis - 1;

        if ismember(s, idxM1_sess)
            idxM1 = [idxM1, idxStart:idxEnd]; %#ok<AGROW>
        else
            idxM2 = [idxM2, idxStart:idxEnd]; %#ok<AGROW>
        end

        idxStart = idxEnd + 1;
    end

    idxM1_neu_all{a} = idxM1;
    idxM2_neu_all{a} = idxM2;
end

% ---------- OUTPUT STRUCTURES ----------

% pooled
% peakBin.arm      = nan(nAreas, nPredictors);
peakBin.eye      = nan(nAreas, nPredictors);
% fracMat.arm      = cell(nPredictors,1);
fracMat.eye      = cell(nPredictors,1);
% MaxFractionCoding.Arm = nan(nAreas, nPredictors);
MaxFractionCoding.Eye = nan(nAreas, nPredictors);
% Monkey 1
% peakBin.arm_M1   = nan(nAreas, nPredictors);
peakBin.eye_M1   = nan(nAreas, nPredictors);
% fracMat.arm_M1   = cell(nPredictors,1);
fracMat.eye_M1   = cell(nPredictors,1);

% Monkey 2
% peakBin.arm_M2   = nan(nAreas, nPredictors);
peakBin.eye_M2   = nan(nAreas, nPredictors);
% fracMat.arm_M2   = cell(nPredictors,1);
fracMat.eye_M2   = cell(nPredictors,1);

% ============================================================
% LOOP OVER PREDICTORS
% ============================================================
for v = 1:nPredictors

%     pArm = AllPSessions_Arm{v};   % N × T × Area (pooled)
    pEye = AllPSessions_Eye{v};

    % prealloc fraction matrices
%     fracMat.arm{v}    = nan(nAreas, nBins);  % pooled
    fracMat.eye{v}    = nan(nAreas, nBins);

%     fracMat.arm_M1{v} = nan(nAreas, nBins);  % Monkey 1
    fracMat.eye_M1{v} = nan(nAreas, nBins);

%     fracMat.arm_M2{v} = nan(nAreas, nBins);  % Monkey 2
    fracMat.eye_M2{v} = nan(nAreas, nBins);

    % ---------- LOOP OVER AREAS ----------
    for a = 1:nAreas

%         pA = squeeze(pArm(:,:,a));   % N × T
        pE = squeeze(pEye(:,:,a));   % N × T

        % ====== POOLED (M1+M2) ======
%         nRealA = sum(~isnan(pA(:,1)));
        nRealE = sum(~isnan(pE(:,1)));

%         if nRealA > 0
%             frac_arm_pooled = sum(pA(1:nRealA,:) < pvalsign, 1) ./ nRealA;
%         else
%             frac_arm_pooled = nan(1, nBins);
%         end

        if nRealE > 0
            frac_eye_pooled = sum(pE(1:nRealE,:) < pvalsign, 1) ./ nRealE;
        else
            frac_eye_pooled = nan(1, nBins);
        end

%         fracMat.arm{v}(a,:) = frac_arm_pooled;
        fracMat.eye{v}(a,:) = frac_eye_pooled;

%         [MAx_Cod_Arm, maxBinArm_pooled] = max(frac_arm_pooled(1:57));
        [MAx_Cod_Eye, maxBinEye_pooled] = max(frac_eye_pooled(1:57));

%         peakBin.arm(a,v) = maxBinArm_pooled;
        peakBin.eye(a,v) = maxBinEye_pooled;
%         MaxFractionCoding.Arm(a,v) = MAx_Cod_Arm;
        MaxFractionCoding.Eye(a,v) = MAx_Cod_Eye;
        % ====== MONKEY 1 ======
        idxM1 = idxM1_neu_all{a};
        if ~isempty(idxM1)
%             pA_M1 = pA(idxM1, :);
            pE_M1 = pE(idxM1, :);

%             nM1A = sum(~isnan(pA_M1(:,1)));
            nM1E = sum(~isnan(pE_M1(:,1)));

%             if nM1A > 0
%                 frac_arm_M1 = sum(pA_M1(1:nM1A,:) < pvalsign, 1) ./ nM1A;
%             else
%                 frac_arm_M1 = nan(1, nBins);
%             end

            if nM1E > 0
                frac_eye_M1 = sum(pE_M1(1:nM1E,:) < pvalsign, 1) ./ nM1E;
            else
                frac_eye_M1 = nan(1, nBins);
            end
        else
%             frac_arm_M1 = nan(1, nBins);
            frac_eye_M1 = nan(1, nBins);
        end

%         fracMat.arm_M1{v}(a,:) = frac_arm_M1;
        fracMat.eye_M1{v}(a,:) = frac_eye_M1;

%         if all(isnan(frac_arm_M1))
%             peakBin.arm_M1(a,v) = NaN;
%         else
%             [~, maxBinArm_M1] = max(frac_arm_M1(1:57));
%             peakBin.arm_M1(a,v) = maxBinArm_M1;
%         end

        if all(isnan(frac_eye_M1))
            peakBin.eye_M1(a,v) = NaN;
        else
            [~, maxBinEye_M1] = max(frac_eye_M1(1:57));
            peakBin.eye_M1(a,v) = maxBinEye_M1;
        end

        % ====== MONKEY 2 ======
        idxM2 = idxM2_neu_all{a};
        if ~isempty(idxM2)
%             pA_M2 = pA(idxM2, :);
            pE_M2 = pE(idxM2, :);

%             nM2A = sum(~isnan(pA_M2(:,1)));
            nM2E = sum(~isnan(pE_M2(:,1)));

%             if nM2A > 0
%                 frac_arm_M2 = sum(pA_M2(1:nM2A,:) < pvalsign, 1) ./ nM2A;
%             else
%                 frac_arm_M2 = nan(1, nBins);
%             end

            if nM2E > 0
                frac_eye_M2 = sum(pE_M2(1:nM2E,:) < pvalsign, 1) ./ nM2E;
            else
                frac_eye_M2 = nan(1, nBins);
            end
        else
%             frac_arm_M2 = nan(1, nBins);
            frac_eye_M2 = nan(1, nBins);
        end

%         fracMat.arm_M2{v}(a,:) = frac_arm_M2;
        fracMat.eye_M2{v}(a,:) = frac_eye_M2;

%         if all(isnan(frac_arm_M2))
%             peakBin.arm_M2(a,v) = NaN;
%         else
%             [~, maxBinArm_M2] = max(frac_arm_M2(1:57));
%             peakBin.arm_M2(a,v) = maxBinArm_M2;
%         end

        if all(isnan(frac_eye_M2))
            peakBin.eye_M2(a,v) = NaN;
        else
            [~, maxBinEye_M2] = max(frac_eye_M2(1:57));
            peakBin.eye_M2(a,v) = maxBinEye_M2;
        end

    end % area
end % predictor


% ---- Inputs ----
dataEye = MaxFractionCoding.Eye(:,1:4);   % ignore 5th column
% dataArm = MaxFractionCoding.Arm(:,1:4);
%%  BarPLot Fraction of coding neurons for fig 2



varLabels = {'Choice Direction','Stimulus Value','Action Value','Reward'};

areaLabels = { ...
    'PMd','PFC','dPut','dCd','VS-put','VS-cd','GPi','Amygdala'};

Colors = [ ...
    54 140 66;
    210 212 113;
    59 127 137;
    175 149 132;
    67 170 175;
    232 174 135;
    140 140 140;
    243 168 168] / 255;

% ---- Figure ----
figure('Color','w','Position',[200 200 1200 600]);
yheigh = [0 .7; ...
    0 .35;
    0 .35;
    0 .7];
for v = 1:4
    
    % ---------- EYE (top row) ----------
    subplot(2,4,v); hold on;
    
    b = bar(dataEye(:,v), 'FaceColor','flat');
    b.CData = Colors;
    
    ylim(yheigh(v,:));
    title(varLabels{v});
    
    if v == 1
        ylabel('Eye');
    end
    
    set(gca,'XTick',1:8,'XTickLabel','', ...
        'XTickLabelRotation',45);
    box off;
    
    
    % ---------- ARM (bottom row) ----------
    subplot(2,4,v+4); hold on;
    
    b = bar(dataArm(:,v), 'FaceColor','flat');
    b.CData = Colors;
    
    ylim(yheigh(v,:));
    
    if v == 1
        ylabel('Arm');
    end
    
    set(gca,'XTick',1:8,'XTickLabel','', ...
        'XTickLabelRotation',45);
    box off;
end


%%

% ============================================================
% Eye vs Arm gradient + bias analysis with permutation tests
% ============================================================

% ----- Inputs -----
% dataEye: 8 x 4
% dataArm: 8 x 4

varLabels = {'Choice Direction','Stimulus Value','Action Value','Reward'};

Colors = [ ...
    54 140 66;
    210 212 113;
    59 127 137;
    175 149 132;
    67 170 175;
    232 174 135;
    140 140 140;
    243 168 168] / 255;

nAreas = size(dataEye,1);
nVars  = size(dataEye,2);

nPerm = 1000;   % number of permutations

figure('Color','w','Position',[200 200 500 500]);

rescale_data =  0 ;


for v = 1:nVars
    if rescale_data == 1
    fEye = normalize(dataEye(:,v),'range');
    fArm = normalize(dataArm(:,v),'range');
    else
    fEye = dataEye(:,v);
    fArm = dataArm(:,v);
    end
    % --------------------------------------------------------
    % Observed statistics
    % --------------------------------------------------------
    
    % Spearman correlation (gradient similarity)
    rho_obs = corr(fEye, fArm, 'Type','Spearman', 'Rows','complete');
    
    % Mean bias (Arm - Eye)
    delta_obs = mean(fArm - fEye, 'omitnan');
    
    % --------------------------------------------------------
    % Permutation tests (shuffle Eye across areas)
    % --------------------------------------------------------
    
    rho_null   = nan(nPerm,1);
    delta_null = nan(nPerm,1);
    
    for i = 1:nPerm
        idx = randperm(nAreas);
        
        rho_null(i) = corr(fEye(idx), fArm, ...
            'Type','Spearman', 'Rows','complete');
        
        delta_null(i) = mean(fArm - fEye(idx), 'omitnan');
    end
    
    % Two-sided permutation p-values
    p_rho   = (sum(abs(rho_null)   >= abs(rho_obs))   + 1) / (nPerm + 1);
    p_delta = (sum(abs(delta_null) >= abs(delta_obs)) + 1) / (nPerm + 1);
    
    % --------------------------------------------------------
    % Plot
    % --------------------------------------------------------
    
    subplot(2,2,v); hold on;
    
    % Scatter (one point per area)
    for a = 1:nAreas
        plot(fEye(a), fArm(a), 'o', ...
            'MarkerFaceColor', Colors(a,:), ...
            'MarkerEdgeColor', Colors(a,:), ...
            'MarkerSize', 7);
    end
    
    % Identity line
    mn = min([fEye; fArm]);
    mx = max([fEye; fArm]);
%     plot([mn mx], [mn mx], 'k-', 'LineWidth', 0.25);
    
    axis square
    %  xlim([mn mx]);
    %  ylim([mn mx])

if rescale_data == 0
    if v== 2 || v == 3
    xlim([.10 .40]);
    ylim([.10 .40]);
%       plot([.15 .35], [.15 .35], 'k--', 'LineWidth', 0.5);

      ticks = [.1 .2  .3 .4 ];


set(gca, ...
    'XTick', ticks, ...
    'YTick', ticks, ...
    'TickDir','out', ...
    'FontSize',9);
    else
    xlim([.15 .75]);
    ylim([.15 .75]);   
%     plot([.15 .75], [.15 .75], 'k--', 'LineWidth', 0.5);
 ticks = [.15 .35  .55  .75 ];


set(gca, ...
    'XTick', ticks, ...
    'YTick', ticks, ...
    'TickDir','out', ...
    'FontSize',9);
    end
end
if rescale_data == 1
 xlim([0 1]);
    ylim([0 1]);
end

    xlabel('Eye fraction of coding neurons')
    ylabel('Arm fraction of coding neurons' ,'FontSize',9)
    title(varLabels{v},"FontSize",9,"FontWeight","normal")

    
    % --------------------------------------------------------
    % Annotations
    % --------------------------------------------------------
    
    txt = {
        sprintf('\\rho = %.2f (p_{perm}=%.3g)', rho_obs, p_rho)
        % sprintf('\\Delta = %.3f (p_{perm}=%.3g)', delta_obs, p_delta)
        };
    
    text(0.05, 0.95, txt, ...
        'Units','normalized', ...
        'HorizontalAlignment','left', ...
        'VerticalAlignment','top', ...
        'FontSize', 9);
    
    box off
end


%%
PeakArm= peakBin.arm(:,1:4);  
PeakEye= peakBin.eye(:,1:4);  

% ============================================================
% Peak timing comparison across areas (Eye vs Arm)
% Spearman rho (rank-based) + permutation test
% ============================================================

% REQUIRED INPUTS IN WORKSPACE:
% PeakEye   : 8 x 4 matrix (areas x variables), peak BIN indices
% PeakArm   : 8 x 4 matrix (areas x variables), peak BIN indices
% time      : 1 x 65 vector, e.g. -1200:50:2000
% varLabels : 1 x 4 cell array
time = -1200:50:2000 ;
Colors = [ ...
    54 140 66;
    210 212 113;
    59 127 137;
    175 149 132;
    67 170 175;
    232 174 135;
    140 140 140;
    243 168 168] / 255;

nPerm = 1000;

% ---- GLOBAL axis limits (shared across subplots) ----
allTimes = time([PeakEye(:); PeakArm(:)]);
allTimes = allTimes(~isnan(allTimes));
tmin = min(allTimes);
tmax = max(allTimes);

figure('Color','w','Position',[200 200 500 500]);

for v = 1:4

    % ---- Extract peak bins ----
    pEye = PeakEye(:,v);
    pArm = PeakArm(:,v);

    % ---- Convert bins to time (FORCE column vectors) ----
    tEye = time(pEye(:));
    tArm = time(pArm(:));

    % ---- Remove areas with missing peaks ----
    valid = ~isnan(tEye) & ~isnan(tArm);
    tEye = tEye(valid);
    tArm = tArm(valid);
    col  = Colors(valid,:);

    nValid = numel(tEye);
    if nValid < 3
        warning('Too few valid areas for variable %d', v);
        continue
    end

    % ---- Spearman rho via ranks (robust) ----
    rEye = tiedrank(tEye(:));
    rArm = tiedrank(tArm(:));

    rho = corr(rEye(:), rArm(:));

    % ---- Permutation test (shuffle Arm labels) ----
    rho_null = nan(nPerm,1);
    for k = 1:nPerm
        idx = randperm(nValid);
        rho_null(k) = corr(rEye(:), rArm(idx(:)));
    end

    p_perm = (sum(abs(rho_null) >= abs(rho)) + 1) / (nPerm + 1);

    % ---- Plot ----
    subplot(2,2,v); hold on

    % Scatter points (one per area)
    for a = 1:nValid
        plot(tEye(a), tArm(a), 'o', ...
            'MarkerFaceColor', col(a,:), ...
            'MarkerEdgeColor', col(a,:), ...
            'MarkerSize', 7);
    end

    % Identity line
    % plot([tmin tmax], [tmin tmax], 'k--', 'LineWidth', 0.75);

    axis square
    % xlim([tmin tmax])
    % ylim([tmin tmax])
    xlim([-700 1400])
    ylim([-700 1400])
   
ticks = [-700 -350 0 350 700 1050 1400 ];


set(gca, ...
    'XTick', ticks, ...
    'YTick', ticks, ...
    'TickDir','out', ...
    'FontSize',9);

axis square
xline(0, 'k--', 'LineWidth', 0.5);
yline(0, 'k--', 'LineWidth', 0.5);

    xlabel('Eye peak time (ms)')
    ylabel('Arm peak time (ms)' ,'FontSize',8)
    title(varLabels{v},"FontSize",8,"FontWeight","normal")

    text(0.05,0.95, ...
        sprintf('\\rho = %.2f, p_{perm} = %.3g', rho, p_perm), ...
        'Units','normalized', ...
        'HorizontalAlignment','left', ...
        'VerticalAlignment','top', ...
        'FontSize',8);

    box off
end




%%


% 
% figure('Color','w','Position',[300 300 500 400]);
% 
% for v = 1:4
%     subplot(2,2,v); hold on
% 
%     % Extract times as before
%     pEye = PeakEye(:,v);
%     pArm = PeakArm(:,v);
% 
%     tEye = time(pEye(:));
%     tArm = time(pArm(:));
% 
%     valid = ~isnan(tEye) & ~isnan(tArm);
%     tEye = tEye(valid);
%     tArm = tArm(valid);
%     col  = Colors(valid,:);
% 
%     DeltaT = tArm - tEye;
% 
%     % Plot points
%     for a = 1:numel(DeltaT)
%         plot(1, DeltaT(a), 'o', ...
%             'MarkerFaceColor', col(a,:), ...
%             'MarkerEdgeColor', col(a,:), ...
%             'MarkerSize', 7);
%     end
% 
%     % Zero line
%     yline(0,'k--');
% 
%     % Median line
%     plot(1, median(DeltaT), 'ks', 'MarkerFaceColor','k');
% 
%     % Optional stats (non-parametric, N=8)
%     p_sr = signrank(DeltaT);
% 
%     xlim([0.8 1.2])
%     ylabel('\Delta peak time (Arm − Eye) [ms]')
%     title(varLabels{v})
% 
%     text(0.05,0.9, sprintf('signrank p = %.3g', p_sr), ...
%         'Units','normalized', 'FontSize',9);
% 
%     box off
%     set(gca,'XTick',[])
% end



%%
% =================== FRACTION IN PEAK BIN + BINOMIAL TEST ===================

pMats_Arm = { AllSesspDir_Arm,  AllSess_pRw_Arm,  AllSesspSarsa_Arm,  AllSesspNF_Arm };
pMats_Eye = { AllSesspDir_Eye,  AllSess_pRw_Eye,  AllSesspSarsa_Eye,  AllSesspNF_Eye };

predictorNames = {'Direction','Stimulus Value','Action Value','Reward'};
areaLabels     = {'PMd','vPFC','Put','Cd','lVS','mVS','GPi','Amy'};

nAreas      = 8;
nPredictors = 4;

alpha = 0.05;   % binomial test threshold
pvalsign = 0.05; % soglia per dire che un neurone è "significante" nel bin

% ------------------------------------------------
% COSTRUZIONE INDICI NEURONI M1 / M2 PER AREA
% ------------------------------------------------
nSessions   = size(nneurons,1);
idxM1_sess  = 1:32;
idxM2_sess  = 33:nSessions;

idxM1_neu_all = cell(nAreas,1);
idxM2_neu_all = cell(nAreas,1);

for a = 1:nAreas

    idxStart = 1;
    idxM1 = [];
    idxM2 = [];

    for s = 1:nSessions
        nThis = nneurons(s,a);
        if nThis == 0
            continue
        end

        idxEnd = idxStart + nThis - 1;

        if ismember(s, idxM1_sess)
            idxM1 = [idxM1, idxStart:idxEnd]; %#ok<AGROW>
        else
            idxM2 = [idxM2, idxStart:idxEnd]; %#ok<AGROW>
        end

        idxStart = idxEnd + 1;
    end

    idxM1_neu_all{a} = idxM1;
    idxM2_neu_all{a} = idxM2;
end

% -------------------------------------------------------------------------
% 1) POOLED (MONKEY 1 + MONKEY 2)  --> il tuo codice originale
% -------------------------------------------------------------------------

frac_EyeOnly = nan(nAreas, nPredictors);
frac_ArmOnly = nan(nAreas, nPredictors);
frac_Both    = nan(nAreas, nPredictors);

pval_EyeOnly = nan(nAreas, nPredictors);
pval_ArmOnly = nan(nAreas, nPredictors);
pval_Both    = nan(nAreas, nPredictors);

for v = 1:nPredictors

    pArm_full = pMats_Arm{v};
    pEye_full = pMats_Eye{v};

    for area = 1:nAreas

        pArm = squeeze(pArm_full(:,:,area));   % neurons × time
        pEye = squeeze(pEye_full(:,:,area));

        nReal = sum(~isnan(pArm(:,1)));
        if nReal == 0
            continue
        end

        % ------ TAKE ONLY THE PEAK BIN (POOLED) ------
        bA = peakBin.arm(area,v);
        bE = peakBin.eye(area,v);

        if isnan(bA) || isnan(bE)
            continue
        end

        armSig = pArm(1:nReal, bA) < pvalsign;
        eyeSig = pEye(1:nReal, bE) < pvalsign;

        % ------ CATEGORIES ------
        eyeOnly = sum( eyeSig & ~armSig );
        armOnly = sum( armSig & ~eyeSig );
        both    = sum( eyeSig &  armSig );

        frac_EyeOnly(area,v) = eyeOnly / nReal;
        frac_ArmOnly(area,v) = armOnly / nReal;
        frac_Both(area,v)    = both    / nReal;

        % ------ BINOMIAL TEST (p = alpha) ------
        pval_EyeOnly(area,v) = 1 - binocdf(eyeOnly - 1, nReal, alpha);
        pval_ArmOnly(area,v) = 1 - binocdf(armOnly - 1, nReal, alpha);
        pval_Both(area,v)    = 1 - binocdf(both    - 1, nReal, alpha^2);

    end
end

colEye  = [0.85 0.33 0.10];
colArm  = [0.30 0.75 0.93];
colBoth = [0.40 0.40 0.40];

%% =================== BINOMIAL CRITICAL FRACTION THRESHOLDS ===================

% Preallocate
critFrac_EOAO  = nan(nAreas,1);   % same for Eye-only and Arm-only
critFrac_Both  = nan(nAreas,1);

% Loop across areas
for area = 1:nAreas

    % --- determine nReal exactly as in the main analysis ---
    % (use predictor 1 arbitrarily; nReal is the same across predictors)
    pArm = squeeze(pMats_Arm{1}(:,:,area));
    nReal = sum(~isnan(pArm(:,1)));

    if nReal == 0
        continue
    end

    % ================= EO / AO threshold =================
    p0 = alpha;   % 0.05
    kCrit = NaN;

    for k = 0:nReal
        pval = 1 - binocdf(k-1, nReal, p0);   % P(X >= k)
        if pval <= 0.05
            kCrit = k;
            break
        end
    end

    critFrac_EOAO(area) = kCrit / nReal;

    % ================= BOTH threshold =================
    p0 = alpha^2;   % 0.0025
    kCrit = NaN;

    for k = 0:nReal
        pval = 1 - binocdf(k-1, nReal, p0);
        if pval <= 0.05
            kCrit = k;
            break
        end
    end

    critFrac_Both(area) = kCrit / nReal;

end

maxthresh_AOEO = max(critFrac_EOAO);
minthresh_AOEO = min(critFrac_EOAO);
meanthresh_AOEO = mean(critFrac_EOAO);

maxthresh_Both = max(critFrac_Both);
minthresh_Both = min(critFrac_Both);
maxthresh_Both = max(critFrac_Both);

%%
% ============================= BAR PLOT POOLED =============================
figure('Position',[100 000 1000 600]);
myv= [0 .5;
0 .25;
0 .25;
0 .5];
for v = 1:nPredictors
subplot(2,2,v)
    % figure('Position',[300 300 780 420]);
    dataToPlot = [ frac_EyeOnly(:,v), frac_ArmOnly(:,v), frac_Both(:,v) ];
    hBar = bar(dataToPlot, 'grouped'); hold on;

    set(hBar(1),'FaceColor',colEye);      % eye-only
    set(hBar(2),'FaceColor',colArm);      % arm-only
    set(hBar(3),'FaceColor',[0 0 0]);     % both

    ylabel('Fraction of neurons');
    title(sprintf('%s (Pooled)', predictorNames{v}));
    set(gca,'XTick',1:nAreas,'XTickLabel',areaLabels,'TickDir','out');
  
     box off;
ylim([ myv(v,:)])
    % ----------------- ADD SIGNIFICANCE STARS -----------------
    for area = 1:nAreas
        x1 = area - 0.25;
        x2 = area;
        x3 = area + 0.25;

        y1 = dataToPlot(area,1);
        y2 = dataToPlot(area,2);
        y3 = dataToPlot(area,3);

        % Eye-only
        if pval_EyeOnly(area,v) > 0.05
            text(x1, y1+0.02, 'n.s.','HorizontalAlignment','center','FontSize',8)
        end
        if pval_EyeOnly(area,v) < 0.001
            text(x1, y1+0.02, '***','HorizontalAlignment','center','FontSize',12)
        elseif pval_EyeOnly(area,v) < 0.01
            text(x1, y1+0.02, '**', 'HorizontalAlignment','center','FontSize',12)
        elseif pval_EyeOnly(area,v) < 0.05
            text(x1, y1+0.02, '*',  'HorizontalAlignment','center','FontSize',12)
        end

        % Arm-only
        if pval_ArmOnly(area,v) > 0.05
            text(x2, y2+0.02, 'n.s.','HorizontalAlignment','center','FontSize',8)
        end
        if pval_ArmOnly(area,v) < 0.001
            text(x2, y2+0.02, '***','HorizontalAlignment','center','FontSize',12)
        elseif pval_ArmOnly(area,v) < 0.01
            text(x2, y2+0.02, '**', 'HorizontalAlignment','center','FontSize',12)
        elseif pval_ArmOnly(area,v) < 0.05
            text(x2, y2+0.02, '*',  'HorizontalAlignment','center','FontSize',12)
        end

        % Both
        if pval_Both(area,v) > 0.05
            text(x3, y3+0.02, 'n.s.','HorizontalAlignment','center','FontSize',8)
        end
        if pval_Both(area,v) < 0.001
            text(x3, y3+0.02, '***','HorizontalAlignment','center','FontSize',12)
        elseif pval_Both(area,v) < 0.01
            text(x3, y3+0.02, '**', 'HorizontalAlignment','center','FontSize',12)
        elseif pval_Both(area,v) < 0.05
            text(x3, y3+0.02, '*',  'HorizontalAlignment','center','FontSize',12)
        end
    end
       if v==1
    legend({'Eye-only','Arm-only','Both'})
          % title('both monkeys')
       end
 yline ( maxthresh_AOEO);
  yline ( minthresh_AOEO);

  yline ( maxthresh_Both);
  yline ( minthresh_Both);

end
%%


%% ========================================================================
%   PEARSON CHI-SQUARE TEST (CONTROL ANALYSIS)
%   EO vs BOTH  and  AO vs BOTH
%   H0: equal proportions (EO = BOTH or AO = BOTH)
% ========================================================================

pvalChi_EO_vs_Both = nan(nAreas, nPredictors);
pvalChi_AO_vs_Both = nan(nAreas, nPredictors);

dirChi_EO_vs_Both  = zeros(nAreas, nPredictors);  % +1: EO > BOTH, -1: BOTH > EO
dirChi_AO_vs_Both  = zeros(nAreas, nPredictors);  % +1: AO > BOTH, -1: BOTH > AO

for v = 1:nPredictors

    pArm_full = pMats_Arm{v};
    pEye_full = pMats_Eye{v};

    for area = 1:nAreas

        pArm = squeeze(pArm_full(:,:,area));
        pEye = squeeze(pEye_full(:,:,area));

        nReal = sum(~isnan(pArm(:,1)));
        if nReal == 0
            continue
        end

        bA = peakBin.arm(area,v);
        bE = peakBin.eye(area,v);
        if isnan(bA) || isnan(bE)
            continue
        end

        armSig = pArm(1:nReal, bA) < pvalsign;
        eyeSig = pEye(1:nReal, bE) < pvalsign;

        EO   = sum( eyeSig & ~armSig );
        AO   = sum( armSig & ~eyeSig );
        BOTH = sum( eyeSig &  armSig );

        % ================= EO vs BOTH =================
        obs = [EO, BOTH];
        m   = sum(obs);

        if m > 0
            expct = [m/2, m/2];

            % Pearson chi-square statistic
            chi2 = sum((obs - expct).^2 ./ expct);

            % p-value (df = 1)
            pvalChi_EO_vs_Both(area,v) = 1 - chi2cdf(chi2, 1);

            if EO > BOTH
                dirChi_EO_vs_Both(area,v) = +1;
            elseif BOTH > EO
                dirChi_EO_vs_Both(area,v) = -1;
            end
        end

        % ================= AO vs BOTH =================
        obs = [AO, BOTH];
        m   = sum(obs);

        if m > 0
            expct = [m/2, m/2];

            chi2 = sum((obs - expct).^2 ./ expct);
            pvalChi_AO_vs_Both(area,v) = 1 - chi2cdf(chi2, 1);

            if AO > BOTH
                dirChi_AO_vs_Both(area,v) = +1;
            elseif BOTH > AO
                dirChi_AO_vs_Both(area,v) = -1;
            end
        end

    end
end

%% ========================================================================
%   PLOT: PEARSON CHI-SQUARE CONTROL
%   EO vs BOTH  and  AO vs BOTH
% ========================================================================

figure('Position',[200 200 1100 600])

for v = 1:nPredictors

    subplot(2,2,v); hold on;
    title(sprintf('%s: Motor-specific vs Shared (\\chi^2 control)', ...
        predictorNames{v}), ...
        'FontSize',12,'FontWeight','bold');

    % -------------------------
    % Build bar data
    % -------------------------
    dataToPlot = [ ...
        frac_EyeOnly(:,v), ...
        frac_ArmOnly(:,v), ...
        frac_Both(:,v) ];

    hBar = bar(dataToPlot,'grouped'); hold on;

    % Colors (same as binomial plot)
    colEye  = [0.85 0.33 0.10];
    colArm  = [0.30 0.75 0.93];
    colBoth = [0 0 0];

    set(hBar(1),'FaceColor',colEye);   % Eye-only
    set(hBar(2),'FaceColor',colArm);   % Arm-only
    set(hBar(3),'FaceColor',colBoth);  % Both

    % Axes
    set(gca,'XTick',1:nAreas, ...
            'XTickLabel',areaLabels, ...
            'FontSize',10, ...
            'XTickLabelRotation',45, ...
            'TickDir','out');

    ylabel('Fraction of neurons');
    ylim([0 max(dataToPlot(:))*1.35]);
    box off;

    % -------------------------
    % Add χ² significance stars
    % -------------------------
    for area = 1:nAreas

        % ---------- EO vs BOTH ----------
        p = pvalChi_EO_vs_Both(area,v);
        if ~isnan(p) && p < 0.05

            if p < 0.001
                stars = '***';
            elseif p < 0.01
                stars = '**';
            else
                stars = '*';
            end

            if dirChi_EO_vs_Both(area,v) == +1
                % EO > BOTH → orange stars on EO bar
                x = hBar(1).XEndPoints(area);
                y = dataToPlot(area,1);
                text(x, y+0.02, stars, ...
                    'Color',colEye, ...
                    'HorizontalAlignment','center', ...
                    'FontSize',10);

            elseif dirChi_EO_vs_Both(area,v) == -1
                % BOTH > EO → black stars on BOTH bar
                x = hBar(3).XEndPoints(area);
                y = dataToPlot(area,3);
                text(x, y+0.02, stars, ...
                    'Color',[0 0 0], ...
                    'HorizontalAlignment','center', ...
                    'FontSize',10);
            end
        end

        % ---------- AO vs BOTH ----------
        p = pvalChi_AO_vs_Both(area,v);
        if ~isnan(p) && p < 0.05

            if p < 0.001
                stars = '***';
            elseif p < 0.01
                stars = '**';
            else
                stars = '*';
            end

            if dirChi_AO_vs_Both(area,v) == +1
                % AO > BOTH → blue stars on AO bar
                x = hBar(2).XEndPoints(area);
                y = dataToPlot(area,2);
                text(x, y+0.02, stars, ...
                    'Color',colArm, ...
                    'HorizontalAlignment','center', ...
                    'FontSize',10);

            elseif dirChi_AO_vs_Both(area,v) == -1
                % BOTH > AO → gray stars on BOTH bar
                x = hBar(3).XEndPoints(area);
                y = dataToPlot(area,3);
                text(x, y+0.03, stars, ...
                    'Color',[0.5 0.5 0.5], ...
                    'HorizontalAlignment','center', ...
                    'FontSize',10);
            end
        end

    end

    if v == 1
        legend({'Eye-only','Arm-only','Both'}, 'Location','best');
    end

end









%% =================== FRACTION WITH >= nConsec CONSECUTIVE BINS + BARPLOT (NON OVERLAPPING) ===================
% Requires in workspace:
%   pMats_Arm, pMats_Eye  (each is 1x4 cell; each cell is neurons x time x area p-values)
%   predictorNames        (1x4 cell)
%   areaLabels            (1x8 cell)
%
% Notes:
% - NaNs correspond to non-existing neurons or invalid bins; they are EXCLUDED from criteria and
%   non-existing neurons are not counted in nReal.
% - Chance lines are computed as probability a neuron meets the criterion by chance in the
%   analyzed window (after NaN removal, and after optional downsampling).



%% ---------------- USER PARAMETERS ----------------
alpha    = 0.05;   % per-bin p-value threshold for "significant" from regression
pvalsign = 0.05;   % same as alpha here, keep for readability

binWin = 15:50;    % analysis window (e.g., 36 bins)
nConsec = 2;        % minimum # consecutive significant bins (e.g., 2 => 500 ms if bins are 250 ms stepped by 50 ms)

% Downsampling option: keep bins 5,10,15,... in ORIGINAL indexing.
% This reduces overlap effects and is equivalent to analyzing a coarser sampling of time.
useDownsample = true;
dsStep = 5;         % keep bins where mod(originalBin, dsStep)==0 (e.g., 5,10,15,...)
% Example with binWin=15:50 and dsStep=5 => keeps 15,20,25,30,35,40,45,50

% Plot options
myv = [0 .5;
       0 .25;
       0 .25;
       0 .5];   % y-lims per predictor panel (edit as needed)

addChi2Stars = true;     % stars for EO vs Both and AO vs Both (optional)
starYOffset  = 0.02;     % vertical offset for stars
starFontSize = 12;

% Colors (match your style)
colEye  = [0.85 0.33 0.10];
colArm  = [0.30 0.75 0.93];
colBoth = [0.00 0.00 0.00];  % black

% ---------------- CONSTANTS ----------------
nAreas      = 8;
nPredictors = 4;

% =================== MAIN: FRACTIONS ===================

frac_EyeOnly = nan(nAreas, nPredictors);
frac_ArmOnly = nan(nAreas, nPredictors);
frac_Both    = nan(nAreas, nPredictors);

n_EyeOnly = nan(nAreas, nPredictors);
n_ArmOnly = nan(nAreas, nPredictors);
n_Both    = nan(nAreas, nPredictors);
nReal_mat = nan(nAreas, nPredictors);

% Helper: neuron has >= n consecutive TRUE bins anywhere (rows independent)
hasConsecRun = @(sigMat, n) any( conv2(double(sigMat), ones(1,n), 'valid') >= n, 2 );

for v = 1:nPredictors

    pArm_full = pMats_Arm{v};   % neurons x time x area
    pEye_full = pMats_Eye{v};

    for area = 1:nAreas

        pArm = squeeze(pArm_full(:,:,area));   % neurons x time
        pEye = squeeze(pEye_full(:,:,area));   % neurons x time

        % Real neurons: non-existing neurons are NaN at time bin 1 (your convention)
        nReal = sum(~isnan(pArm(:,1)));
        if nReal == 0
            continue
        end

        pArm = pArm(1:nReal, :);
        pEye = pEye(1:nReal, :);

        % Restrict to window (original bins)
        pArmW = pArm(:, binWin);
        pEyeW = pEye(:, binWin);

        % Remove invalid time bins (assumed consistent across neurons; safe version commented)
        validBins = ~isnan(pArmW(1,:)) & ~isnan(pEyeW(1,:));
        % validBins = all(~isnan(pArmW),1) & all(~isnan(pEyeW),1); % ultra-safe

        pArmW = pArmW(:, validBins);
        pEyeW = pEyeW(:, validBins);

        % Optional downsampling: keep original bin indices 5,10,15,...
        if useDownsample
            dsMask_inBinWin = (mod(binWin, dsStep) == 0);    % mask relative to original binWin
            dsMask_inBinWin = dsMask_inBinWin(validBins);    % align with NaN-masked columns

            pArmW = pArmW(:, dsMask_inBinWin);
            pEyeW = pEyeW(:, dsMask_inBinWin);
        end

        % If too few bins remain, no neuron can meet criterion
        if size(pArmW,2) < nConsec
            eyeOnly = 0; armOnly = 0; both = 0;
        else
            % Significance matrices
            sigArm = (pArmW < pvalsign);
            sigEye = (pEyeW < pvalsign);

            % Coding criterion: >= nConsec consecutive significant bins anywhere in window
            armCoding = hasConsecRun(sigArm, nConsec);
            eyeCoding = hasConsecRun(sigEye, nConsec);

            % Categories (disjoint)
            eyeOnly = sum( eyeCoding & ~armCoding );
            armOnly = sum( armCoding & ~eyeCoding );
            both    = sum( eyeCoding &  armCoding );
        end

        % Save counts + fractions
        n_EyeOnly(area,v) = eyeOnly;
        n_ArmOnly(area,v) = armOnly;
        n_Both(area,v)    = both;
        nReal_mat(area,v) = nReal;

        frac_EyeOnly(area,v) = eyeOnly / nReal;
        frac_ArmOnly(area,v) = armOnly / nReal;
        frac_Both(area,v)    = both    / nReal;

    end
end

% =================== CHANCE LINES (ANALOG OF 0.05 AND 0.0025) ===================
% chance_EOAO(area,v) = P(neuron meets criterion by chance)
% chance_Both(area,v) = P(meets criterion by chance in BOTH systems) ~= chance_EOAO^2

chance_EOAO = nan(nAreas, nPredictors);
chance_Both = nan(nAreas, nPredictors);

for v = 1:nPredictors
    pArm_full = pMats_Arm{v};
    pEye_full = pMats_Eye{v};

    for area = 1:nAreas

        pArm = squeeze(pArm_full(:,:,area));
        pEye = squeeze(pEye_full(:,:,area));

        nReal = sum(~isnan(pArm(:,1)));
        if nReal == 0
            continue
        end

        pArm = pArm(1:nReal, :);
        pEye = pEye(1:nReal, :);

        pArmW = pArm(:, binWin);
        pEyeW = pEye(:, binWin);

        validBins = ~isnan(pArmW(1,:)) & ~isnan(pEyeW(1,:));
        pArmW = pArmW(:, validBins);
        pEyeW = pEyeW(:, validBins);

        if useDownsample
            dsMask_inBinWin = (mod(binWin, dsStep) == 0);
            dsMask_inBinWin = dsMask_inBinWin(validBins);
            pArmW = pArmW(:, dsMask_inBinWin);
            pEyeW = pEyeW(:, dsMask_inBinWin);
        end

        Tvalid = size(pArmW,2);

        if Tvalid < nConsec
            p_run = 0;
        else
            p_run = prob_at_least_one_run(Tvalid, nConsec, alpha);
        end

        chance_EOAO(area,v) = p_run;
        chance_Both(area,v) = p_run^2;

    end
end

% =================== OPTIONAL: Chi-square comparison EO vs Both and AO vs Both ===================
% This is a pragmatic “difference between proportions” test; it matches the spirit of your
% previous figure-level statement (embodied vs shared). You can disable via addChi2Stars=false.

p_chi_EO_vs_Both = nan(nAreas, nPredictors);
p_chi_AO_vs_Both = nan(nAreas, nPredictors);

if addChi2Stars
    for v = 1:nPredictors
        for area = 1:nAreas
            nReal = nReal_mat(area,v);
            if isnan(nReal) || nReal == 0
                continue
            end

            EO = n_EyeOnly(area,v);
            AO = n_ArmOnly(area,v);
            BO = n_Both(area,v);

            % Compare EO vs Both as two proportions out of nReal
            % Use a 2x2 table: [EO, BO; nReal-EO, nReal-BO]
            % (same approach many people use in quick figure χ² comparisons)
            tbl1 = [EO, BO; nReal-EO, nReal-BO];
            [~, p1] = chi2independence_p(tbl1);
            p_chi_EO_vs_Both(area,v) = p1;

            tbl2 = [AO, BO; nReal-AO, nReal-BO];
            [~, p2] = chi2independence_p(tbl2);
            p_chi_AO_vs_Both(area,v) = p2;
        end
    end
end

% =================== BAR PLOT ===================

figure('Position',[100 100 1000 600]);

for v = 1:nPredictors
    subplot(2,2,v);

    dataToPlot = [ frac_EyeOnly(:,v), frac_ArmOnly(:,v), frac_Both(:,v) ];
    hBar = bar(dataToPlot, 'grouped'); hold on;

    set(hBar(1),'FaceColor',colEye);
    set(hBar(2),'FaceColor',colArm);
    set(hBar(3),'FaceColor',colBoth);

    ylabel('Fraction of neurons');
    if useDownsample
        title(sprintf('%s (>= %d consec; win=%d:%d; keep %d,%d,...)', ...
            predictorNames{v}, nConsec, binWin(1), binWin(end), dsStep, 2*dsStep));
    else
        title(sprintf('%s (>= %d consecutive bins; win=%d:%d)', ...
            predictorNames{v}, nConsec, binWin(1), binWin(end)));
    end

    set(gca,'XTick',1:nAreas,'XTickLabel',areaLabels,'TickDir','out');
    box off;
    ylim(myv(v,:));

    if v==1
        legend({'Eye-only','Arm-only','Both'}, 'Location','best');
    end

    % ---- Chance lines (analog of your old 0.05 and 0.0025) ----
    yline(max(chance_EOAO(:,v)), '-', 'LineWidth', 1);
    yline(min(chance_EOAO(:,v)), '-', 'LineWidth', 1);

    yline(max(chance_Both(:,v)), '--', 'LineWidth', 1);
    yline(min(chance_Both(:,v)), '--', 'LineWidth', 1);

    % ---- Optional χ² stars (EO vs Both and AO vs Both) ----
    if addChi2Stars
        for area = 1:nAreas

            x1 = area - 0.25;  % EO bar center
            x2 = area;         % AO bar center
            x3 = area + 0.25;  % Both bar center (not used for stars here)

            y1 = dataToPlot(area,1);
            y2 = dataToPlot(area,2);

            p1 = p_chi_EO_vs_Both(area,v);
            p2 = p_chi_AO_vs_Both(area,v);

            % EO vs Both
            if ~isnan(p1)
                s = p_to_stars(p1);
                if ~isempty(s)
                    text(x1, y1 + starYOffset, s, 'HorizontalAlignment','center', 'FontSize', starFontSize);
                end
            end

            % AO vs Both
            if ~isnan(p2)
                s = p_to_stars(p2);
                if ~isempty(s)
                    text(x2, y2 + starYOffset, s, 'HorizontalAlignment','center', 'FontSize', starFontSize);
                end
            end

        end
    end

end


%%
% -------------------------------------------------------------------------
% 2) MONKEY 1
% -------------------------------------------------------------------------
y_axis_values = [0 .6;
    0 .3;
    0 .3;
    0 .6];
frac_EyeOnly_M1 = nan(nAreas, nPredictors);
frac_ArmOnly_M1 = nan(nAreas, nPredictors);
frac_Both_M1    = nan(nAreas, nPredictors);

pval_EyeOnly_M1 = nan(nAreas, nPredictors);
pval_ArmOnly_M1 = nan(nAreas, nPredictors);
pval_Both_M1    = nan(nAreas, nPredictors);

for v = 1:nPredictors

    pArm_full = pMats_Arm{v};
    pEye_full = pMats_Eye{v};

    for area = 1:nAreas

        pArm = squeeze(pArm_full(:,:,area));   % neurons × time
        pEye = squeeze(pEye_full(:,:,area));

        idxM1 = idxM1_neu_all{area};
        if isempty(idxM1)
            continue
        end

        pArm_M1 = pArm(idxM1,:);
        pEye_M1 = pEye(idxM1,:);

        nReal_M1 = sum(~isnan(pArm_M1(:,1)));
        if nReal_M1 == 0
            continue
        end

        % ------ PEAK BIN PER MONKEY 1 ------
        bA = peakBin.arm_M1(area,v);
        bE = peakBin.eye_M1(area,v);

        if isnan(bA) || isnan(bE)
            continue
        end

        armSig = pArm_M1(1:nReal_M1, bA) < pvalsign;
        eyeSig = pEye_M1(1:nReal_M1, bE) < pvalsign;

        eyeOnly = sum( eyeSig & ~armSig );
        armOnly = sum( armSig & ~eyeSig );
        both    = sum( eyeSig &  armSig );

        frac_EyeOnly_M1(area,v) = eyeOnly / nReal_M1;
        frac_ArmOnly_M1(area,v) = armOnly / nReal_M1;
        frac_Both_M1(area,v)    = both    / nReal_M1;

        pval_EyeOnly_M1(area,v) = 1 - binocdf(eyeOnly - 1, nReal_M1, alpha);
        pval_ArmOnly_M1(area,v) = 1 - binocdf(armOnly - 1, nReal_M1, alpha);
        pval_Both_M1(area,v)    = 1 - binocdf(both    - 1, nReal_M1, alpha^2);

    end
end


%% =================== BINOMIAL CRITICAL FRACTION THRESHOLDS (MONKEY 1) ===================

% Preallocate
critFrac_EOAO_M1 = nan(nAreas,1);   % same threshold for Eye-only and Arm-only
critFrac_Both_M1 = nan(nAreas,1);

% Loop across areas
for area = 1:nAreas

    % --- determine nReal_M1 exactly as in Monkey 1 analysis ---
    % use predictor 1 arbitrarily (nReal_M1 is predictor-independent)
    pArm = squeeze(pMats_Arm{1}(:,:,area));

    idxM1 = idxM1_neu_all{area};
    if isempty(idxM1)
        continue
    end

    pArm_M1 = pArm(idxM1,:);
    nReal_M1 = sum(~isnan(pArm_M1(:,1)));

    if nReal_M1 == 0
        continue
    end

    % ================= EO / AO threshold (p0 = alpha) =================
    p0 = alpha;   % e.g. 0.05 or 0.01
    kCrit = NaN;

    for k = 0:nReal_M1
        pval = 1 - binocdf(k-1, nReal_M1, p0);   % P(X >= k)
        if pval <= 0.05        % same criterion you used before
            kCrit = k;
            break
        end
    end

    critFrac_EOAO_M1(area) = kCrit / nReal_M1;

    % ================= BOTH threshold (p0 = alpha^2) =================
    p0 = alpha^2;   % e.g. 0.0025 if alpha = 0.05
    kCrit = NaN;

    for k = 0:nReal_M1
        pval = 1 - binocdf(k-1, nReal_M1, p0);
        if pval <= 0.05
            kCrit = k;
            break
        end
    end

    critFrac_Both_M1(area) = kCrit / nReal_M1;

end
maxthresh_AOEO_M1 = max(critFrac_EOAO_M1);
maxthresh_Both_M1 = max(critFrac_Both_M1);

%%



% ============================= BAR PLOT M1 =============================
 figure('Position',[100 000 1000 600]);

for v = 1:nPredictors
subplot(2,2,v)

    % figure('Position',[300 300 780 420]);
    dataToPlot = [ frac_EyeOnly_M1(:,v), frac_ArmOnly_M1(:,v), frac_Both_M1(:,v) ];
    hBar = bar(dataToPlot, 'grouped'); hold on;

    set(hBar(1),'FaceColor',colEye);      
    set(hBar(2),'FaceColor',colArm);      
    set(hBar(3),'FaceColor',[0 0 0]);     

    ylabel('Fraction of neurons');
    title(sprintf('%s (Monkey 1)', predictorNames{v}));
    set(gca,'XTick',1:nAreas,'XTickLabel',areaLabels,'TickDir','out');
  
    box off;
    for area = 1:nAreas
        x1 = area - 0.25;
        x2 = area;
        x3 = area + 0.25;

        y1 = dataToPlot(area,1);
        y2 = dataToPlot(area,2);
        y3 = dataToPlot(area,3);

        if isnan(y1), y1 = 0; end
        if isnan(y2), y2 = 0; end
        if isnan(y3), y3 = 0; end

        % Eye-only
        if pval_EyeOnly_M1(area,v) > 0.05
            text(x1, y1+0.02, 'n.s.','HorizontalAlignment','center','FontSize',8)
        end
        if pval_EyeOnly_M1(area,v) < 0.001
            text(x1, y1+0.02, '***','HorizontalAlignment','center','FontSize',12)
        elseif pval_EyeOnly_M1(area,v) < 0.01
            text(x1, y1+0.02, '**', 'HorizontalAlignment','center','FontSize',12)
        elseif pval_EyeOnly_M1(area,v) < 0.05
            text(x1, y1+0.02, '*',  'HorizontalAlignment','center','FontSize',12)
        end

        % Arm-only
        if pval_ArmOnly_M1(area,v) > 0.05
            text(x2, y2+0.02, 'n.s.','HorizontalAlignment','center','FontSize',8)
        end
        if pval_ArmOnly_M1(area,v) < 0.001
            text(x2, y2+0.02, '***','HorizontalAlignment','center','FontSize',12)
        elseif pval_ArmOnly_M1(area,v) < 0.01
            text(x2, y2+0.02, '**', 'HorizontalAlignment','center','FontSize',12)
        elseif pval_ArmOnly_M1(area,v) < 0.05
            text(x2, y2+0.02, '*',  'HorizontalAlignment','center','FontSize',12)
        end

        % Both
        if pval_Both_M1(area,v) > 0.05
            text(x3, y3+0.02, 'n.s.','HorizontalAlignment','center','FontSize',8)
        end
        if pval_Both_M1(area,v) < 0.001
            text(x3, y3+0.02, '***','HorizontalAlignment','center','FontSize',12)
        elseif pval_Both_M1(area,v) < 0.01
            text(x3, y3+0.02, '**', 'HorizontalAlignment','center','FontSize',12)
        elseif pval_Both_M1(area,v) < 0.05
            text(x3, y3+0.02, '*',  'HorizontalAlignment','center','FontSize',12)
        end
    end

       if v==1
    legend({'Eye-only','Arm-only','Both'})
          % title('monkey 1')
       end
       ylim(y_axis_values(v,:))
        yline ( maxthresh_AOEO_M1);
  yline ( maxthresh_Both_M1);
end







%% ========== MONKEY 1 ==============================================================
%   PEARSON CHI-SQUARE TEST (CONTROL ANALYSIS)
%   EO vs BOTH  and  AO vs BOTH
%   H0: equal proportions (EO = BOTH or AO = BOTH)
% ========================================================================


pvalChi_EO_vs_Both_M1 = nan(nAreas, nPredictors);
pvalChi_AO_vs_Both_M1 = nan(nAreas, nPredictors);

dirChi_EO_vs_Both_M1  = zeros(nAreas, nPredictors);  % +1: EO > BOTH, -1: BOTH > EO
dirChi_AO_vs_Both_M1  = zeros(nAreas, nPredictors);  % +1: AO > BOTH, -1: BOTH > AO

for v = 1:nPredictors

    pArm_full = pMats_Arm{v};
    pEye_full = pMats_Eye{v};

    for area = 1:nAreas

        pArm = squeeze(pArm_full(:,:,area));
        pEye = squeeze(pEye_full(:,:,area));
        
        
        idxM1 = idxM1_neu_all{area};
        if isempty(idxM1)
            continue
        end
        pArm_M1 = pArm(idxM1,:);
        pEye_M1 = pEye(idxM1,:);

        nReal_M1 = sum(~isnan(pArm_M1(:,1)));
        if nReal_M1 == 0
            continue
        end

        bA = peakBin.arm_M1(area,v);
        bE = peakBin.eye_M1(area,v);

        if isnan(bA) || isnan(bE)
            continue
        end

        armSig = pArm_M1(1:nReal_M1, bA) < pvalsign;
        eyeSig = pEye_M1(1:nReal_M1, bE) < pvalsign;

        EO_M1   = sum( eyeSig & ~armSig );
        AO_M1   = sum( armSig & ~eyeSig );
        BOTH_M1 = sum( eyeSig &  armSig );

        % ================= EO vs BOTH =================
        obs = [EO_M1, BOTH_M1];
        m   = sum(obs);

        if m > 0
            expct = [m/2, m/2];

            % Pearson chi-square statistic
            chi2 = sum((obs - expct).^2 ./ expct);

            % p-value (df = 1)
            pvalChi_EO_vs_Both_M1(area,v) = 1 - chi2cdf(chi2, 1);

            if EO_M1 > BOTH_M1
                dirChi_EO_vs_Both_M1(area,v) = +1;
            elseif BOTH_M1 > EO_M1
                dirChi_EO_vs_Both_M1(area,v) = -1;
            end
        end

        % ================= AO vs BOTH =================
        obs = [AO_M1, BOTH_M1];
        m   = sum(obs);

        if m > 0
            expct = [m/2, m/2];

            chi2 = sum((obs - expct).^2 ./ expct);
            pvalChi_AO_vs_Both_M1(area,v) = 1 - chi2cdf(chi2, 1);

            if AO_M1 > BOTH_M1
                dirChi_AO_vs_Both_M1(area,v) = +1;
            elseif BOTH_M1 > AO_M1
                dirChi_AO_vs_Both_M1(area,v) = -1;
            end
        end

    end
end

%% ========================================================================
%   PLOT: PEARSON CHI-SQUARE CONTROL
%   EO vs BOTH  and  AO vs BOTH
% ========================================================================

figure('Position',[200 200 1100 600])

for v = 1:nPredictors

    subplot(2,2,v); hold on;
    title(sprintf('%s: Motor-specific vs Shared (\\chi^2 control)', ...
        predictorNames{v}), ...
        'FontSize',12,'FontWeight','bold');

    % -------------------------
    % Build bar data
    % -------------------------
    dataToPlot_M1 = [ ...
        frac_EyeOnly_M1(:,v), ...
        frac_ArmOnly_M1(:,v), ...
        frac_Both_M1(:,v) ];

    hBar = bar(dataToPlot_M1,'grouped'); hold on;

    % Colors (same as binomial plot)
    colEye  = [0.85 0.33 0.10];
    colArm  = [0.30 0.75 0.93];
    colBoth = [0 0 0];

    set(hBar(1),'FaceColor',colEye);   % Eye-only
    set(hBar(2),'FaceColor',colArm);   % Arm-only
    set(hBar(3),'FaceColor',colBoth);  % Both

    % Axes
    set(gca,'XTick',1:nAreas, ...
            'XTickLabel',areaLabels, ...
            'FontSize',10, ...
            'XTickLabelRotation',45, ...
            'TickDir','out');

    ylabel('Fraction of neurons');
    ylim([0 max(dataToPlot_M1(:))*1.35]);
    box off;

    % -------------------------
    % Add χ² significance stars
    % -------------------------
    for area = 1:nAreas

        % ---------- EO vs BOTH ----------
        p = pvalChi_EO_vs_Both_M1(area,v);
        if ~isnan(p) && p < 0.05

            if p < 0.001
                stars = '***';
            elseif p < 0.01
                stars = '**';
            else
                stars = '*';
            end

            if dirChi_EO_vs_Both_M1(area,v) == +1
                % EO > BOTH → orange stars on EO bar
                x = hBar(1).XEndPoints(area);
                y = dataToPlot_M1(area,1);
                text(x, y+0.02, stars, ...
                    'Color',colEye, ...
                    'HorizontalAlignment','center', ...
                    'FontSize',10);

            elseif dirChi_EO_vs_Both_M1(area,v) == -1
                % BOTH > EO → black stars on BOTH bar
                x = hBar(3).XEndPoints(area);
                y = dataToPlot_M1(area,3);
                text(x, y+0.02, stars, ...
                    'Color',[0 0 0], ...
                    'HorizontalAlignment','center', ...
                    'FontSize',10);
            end
        end

        % ---------- AO vs BOTH ----------
        p = pvalChi_AO_vs_Both_M1(area,v);
        if ~isnan(p) && p < 0.05

            if p < 0.001
                stars = '***';
            elseif p < 0.01
                stars = '**';
            else
                stars = '*';
            end

            if dirChi_AO_vs_Both_M1(area,v) == +1
                % AO > BOTH → blue stars on AO bar
                x = hBar(2).XEndPoints(area);
                y = dataToPlot_M1(area,2);
                text(x, y+0.02, stars, ...
                    'Color',colArm, ...
                    'HorizontalAlignment','center', ...
                    'FontSize',10);

            elseif dirChi_AO_vs_Both_M1(area,v) == -1
                % BOTH > AO → gray stars on BOTH bar
                x = hBar(3).XEndPoints(area);
                y = dataToPlot_M1(area,3);
                text(x, y+0.03, stars, ...
                    'Color',[0.5 0.5 0.5], ...
                    'HorizontalAlignment','center', ...
                    'FontSize',10);
            end
        end

    end

    if v == 1
        legend({'Eye-only','Arm-only','Both'}, 'Location','best');
    end

end












%%
% -------------------------------------------------------------------------
% 3) MONKEY 2

% -------------------------------------------------------------------------
y_axis_values = [0 .6;
    0 .3;
    0 .3;
    0 .6];
frac_EyeOnly_M2 = nan(nAreas, nPredictors);
frac_ArmOnly_M2 = nan(nAreas, nPredictors);
frac_Both_M2    = nan(nAreas, nPredictors);

pval_EyeOnly_M2 = nan(nAreas, nPredictors);
pval_ArmOnly_M2 = nan(nAreas, nPredictors);
pval_Both_M2    = nan(nAreas, nPredictors);

for v = 1:nPredictors

    pArm_full = pMats_Arm{v};
    pEye_full = pMats_Eye{v};

    for area = 1:nAreas

        pArm = squeeze(pArm_full(:,:,area));   % neurons × time
        pEye = squeeze(pEye_full(:,:,area));

        idxM2 = idxM2_neu_all{area};
        if isempty(idxM2)
            continue
        end

        pArm_M2 = pArm(idxM2,:);
        pEye_M2 = pEye(idxM2,:);

        nReal_M2 = sum(~isnan(pArm_M2(:,1)));
        if nReal_M2 == 0
            continue
        end

        % ------ PEAK BIN PER MONKEY 1 ------
        bA = peakBin.arm_M2(area,v);
        bE = peakBin.eye_M2(area,v);

        if isnan(bA) || isnan(bE)
            continue
        end

        armSig = pArm_M2(1:nReal_M2, bA) < pvalsign;
        eyeSig = pEye_M2(1:nReal_M2, bE) < pvalsign;

        eyeOnly = sum( eyeSig & ~armSig );
        armOnly = sum( armSig & ~eyeSig );
        both    = sum( eyeSig &  armSig );

        frac_EyeOnly_M2(area,v) = eyeOnly / nReal_M2;
        frac_ArmOnly_M2(area,v) = armOnly / nReal_M2;
        frac_Both_M2(area,v)    = both    / nReal_M2;

        pval_EyeOnly_M2(area,v) = 1 - binocdf(eyeOnly - 1, nReal_M2, alpha);
        pval_ArmOnly_M2(area,v) = 1 - binocdf(armOnly - 1, nReal_M2, alpha);
        pval_Both_M2(area,v)    = 1 - binocdf(both    - 1, nReal_M2, alpha^2);

    end
end


%% =================== BINOMIAL CRITICAL FRACTION THRESHOLDS (MONKEY 2) ===================

% Preallocate
critFrac_EOAO_M2 = nan(nAreas,1);   % same threshold for Eye-only and Arm-only
critFrac_Both_M2 = nan(nAreas,1);

% Loop across areas
for area = 1:nAreas

    % --- determine nReal_M2 exactly as in Monkey 1 analysis ---
    % use predictor 1 arbitrarily (nReal_M2 is predictor-independent)
    pArm = squeeze(pMats_Arm{1}(:,:,area));

    idxM2 = idxM2_neu_all{area};
    if isempty(idxM2)
        continue
    end

    pArm_M2 = pArm(idxM2,:);
    nReal_M2 = sum(~isnan(pArm_M2(:,1)));

    if nReal_M2 == 0
        continue
    end

    % ================= EO / AO threshold (p0 = alpha) =================
    p0 = alpha;   % e.g. 0.05 or 0.01
    kCrit = NaN;

    for k = 0:nReal_M2
        pval = 1 - binocdf(k-1, nReal_M2, p0);   % P(X >= k)
        if pval <= 0.05        % same criterion you used before
            kCrit = k;
            break
        end
    end

    critFrac_EOAO_M2(area) = kCrit / nReal_M2;

    % ================= BOTH threshold (p0 = alpha^2) =================
    p0 = alpha^2;   % e.g. 0.0025 if alpha = 0.05
    kCrit = NaN;

    for k = 0:nReal_M2
        pval = 1 - binocdf(k-1, nReal_M2, p0);
        if pval <= 0.05
            kCrit = k;
            break
        end
    end

    critFrac_Both_M2(area) = kCrit / nReal_M2;

end


%%



% ============================= BAR PLOT M2 =============================
 figure('Position',[100 000 1000 600]);

for v = 1:nPredictors
subplot(2,2,v)

    % figure('Position',[300 300 780 420]);
    dataToPlot = [ frac_EyeOnly_M2(:,v), frac_ArmOnly_M2(:,v), frac_Both_M2(:,v) ];
    hBar = bar(dataToPlot, 'grouped'); hold on;

    set(hBar(1),'FaceColor',colEye);      
    set(hBar(2),'FaceColor',colArm);      
    set(hBar(3),'FaceColor',[0 0 0]);     

    ylabel('Fraction of neurons');
    title(sprintf('%s (Monkey 1)', predictorNames{v}));
    set(gca,'XTick',1:nAreas,'XTickLabel',areaLabels,'TickDir','out');
  
    box off;
    for area = 1:nAreas
        x1 = area - 0.25;
        x2 = area;
        x3 = area + 0.25;

        y1 = dataToPlot(area,1);
        y2 = dataToPlot(area,2);
        y3 = dataToPlot(area,3);

        if isnan(y1), y1 = 0; end
        if isnan(y2), y2 = 0; end
        if isnan(y3), y3 = 0; end

        % Eye-only
        if pval_EyeOnly_M2(area,v) > 0.05
            text(x1, y1+0.02, 'n.s.','HorizontalAlignment','center','FontSize',8)
        end
        if pval_EyeOnly_M2(area,v) < 0.001
            text(x1, y1+0.02, '***','HorizontalAlignment','center','FontSize',12)
        elseif pval_EyeOnly_M2(area,v) < 0.01
            text(x1, y1+0.02, '**', 'HorizontalAlignment','center','FontSize',12)
        elseif pval_EyeOnly_M2(area,v) < 0.05
            text(x1, y1+0.02, '*',  'HorizontalAlignment','center','FontSize',12)
        end

        % Arm-only
        if pval_ArmOnly_M2(area,v) > 0.05
            text(x2, y2+0.02, 'n.s.','HorizontalAlignment','center','FontSize',8)
        end
        if pval_ArmOnly_M2(area,v) < 0.001
            text(x2, y2+0.02, '***','HorizontalAlignment','center','FontSize',12)
        elseif pval_ArmOnly_M2(area,v) < 0.01
            text(x2, y2+0.02, '**', 'HorizontalAlignment','center','FontSize',12)
        elseif pval_ArmOnly_M2(area,v) < 0.05
            text(x2, y2+0.02, '*',  'HorizontalAlignment','center','FontSize',12)
        end

        % Both
        if pval_Both_M2(area,v) > 0.05
            text(x3, y3+0.02, 'n.s.','HorizontalAlignment','center','FontSize',8)
        end
        if pval_Both_M2(area,v) < 0.001
            text(x3, y3+0.02, '***','HorizontalAlignment','center','FontSize',12)
        elseif pval_Both_M2(area,v) < 0.01
            text(x3, y3+0.02, '**', 'HorizontalAlignment','center','FontSize',12)
        elseif pval_Both_M2(area,v) < 0.05
            text(x3, y3+0.02, '*',  'HorizontalAlignment','center','FontSize',12)
        end
    end

       if v==1
    legend({'Eye-only','Arm-only','Both'})
          % title('monkey 1')
       end
       ylim(y_axis_values(v,:))
end







%% ========== MONKEY 2 ==============================================================
%   PEARSON CHI-SQUARE TEST (CONTROL ANALYSIS)
%   EO vs BOTH  and  AO vs BOTH
%   H0: equal proportions (EO = BOTH or AO = BOTH)
% ========================================================================


pvalChi_EO_vs_Both_M2 = nan(nAreas, nPredictors);
pvalChi_AO_vs_Both_M2 = nan(nAreas, nPredictors);

dirChi_EO_vs_Both_M2  = zeros(nAreas, nPredictors);  % +1: EO > BOTH, -1: BOTH > EO
dirChi_AO_vs_Both_M2  = zeros(nAreas, nPredictors);  % +1: AO > BOTH, -1: BOTH > AO

for v = 1:nPredictors

    pArm_full = pMats_Arm{v};
    pEye_full = pMats_Eye{v};

    for area = 1:nAreas

        pArm = squeeze(pArm_full(:,:,area));
        pEye = squeeze(pEye_full(:,:,area));
        
        
        idxM2 = idxM2_neu_all{area};
        if isempty(idxM2)
            continue
        end
        pArm_M2 = pArm(idxM2,:);
        pEye_M2 = pEye(idxM2,:);

        nReal_M2 = sum(~isnan(pArm_M2(:,1)));
        if nReal_M2 == 0
            continue
        end

        bA = peakBin.arm_M2(area,v);
        bE = peakBin.eye_M2(area,v);

        if isnan(bA) || isnan(bE)
            continue
        end

        armSig = pArm_M2(1:nReal_M2, bA) < pvalsign;
        eyeSig = pEye_M2(1:nReal_M2, bE) < pvalsign;

        EO_M2   = sum( eyeSig & ~armSig );
        AO_M2   = sum( armSig & ~eyeSig );
        BOTH_M2 = sum( eyeSig &  armSig );

        % ================= EO vs BOTH =================
        obs = [EO_M2, BOTH_M2];
        m   = sum(obs);

        if m > 0
            expct = [m/2, m/2];

            % Pearson chi-square statistic
            chi2 = sum((obs - expct).^2 ./ expct);

            % p-value (df = 1)
            pvalChi_EO_vs_Both_M2(area,v) = 1 - chi2cdf(chi2, 1);

            if EO_M2 > BOTH_M2
                dirChi_EO_vs_Both_M2(area,v) = +1;
            elseif BOTH_M2 > EO_M2
                dirChi_EO_vs_Both_M2(area,v) = -1;
            end
        end

        % ================= AO vs BOTH =================
        obs = [AO_M2, BOTH_M2];
        m   = sum(obs);

        if m > 0
            expct = [m/2, m/2];

            chi2 = sum((obs - expct).^2 ./ expct);
            pvalChi_AO_vs_Both_M2(area,v) = 1 - chi2cdf(chi2, 1);

            if AO_M2 > BOTH_M2
                dirChi_AO_vs_Both_M2(area,v) = +1;
            elseif BOTH_M2 > AO_M2
                dirChi_AO_vs_Both_M2(area,v) = -1;
            end
        end

    end
end

%% ========================================================================
%   PLOT: PEARSON CHI-SQUARE CONTROL
%   EO vs BOTH  and  AO vs BOTH
% ========================================================================

figure('Position',[200 200 1100 600])

for v = 1:nPredictors

    subplot(2,2,v); hold on;
    title(sprintf('%s: Motor-specific vs Shared (\\chi^2 control)', ...
        predictorNames{v}), ...
        'FontSize',12,'FontWeight','bold');

    % -------------------------
    % Build bar data
    % -------------------------
    dataToPlot_M2 = [ ...
        frac_EyeOnly_M2(:,v), ...
        frac_ArmOnly_M2(:,v), ...
        frac_Both_M2(:,v) ];

    hBar = bar(dataToPlot_M2,'grouped'); hold on;

    % Colors (same as binomial plot)
    colEye  = [0.85 0.33 0.10];
    colArm  = [0.30 0.75 0.93];
    colBoth = [0 0 0];

    set(hBar(1),'FaceColor',colEye);   % Eye-only
    set(hBar(2),'FaceColor',colArm);   % Arm-only
    set(hBar(3),'FaceColor',colBoth);  % Both

    % Axes
    set(gca,'XTick',1:nAreas, ...
            'XTickLabel',areaLabels, ...
            'FontSize',10, ...
            'XTickLabelRotation',45, ...
            'TickDir','out');

    ylabel('Fraction of neurons');
    ylim([0 max(dataToPlot_M2(:))*1.35]);
    box off;

    % -------------------------
    % Add χ² significance stars
    % -------------------------
    for area = 1:nAreas

        % ---------- EO vs BOTH ----------
        p = pvalChi_EO_vs_Both_M2(area,v);
        if ~isnan(p) && p < 0.05

            if p < 0.001
                stars = '***';
            elseif p < 0.01
                stars = '**';
            else
                stars = '*';
            end

            if dirChi_EO_vs_Both_M2(area,v) == +1
                % EO > BOTH → orange stars on EO bar
                x = hBar(1).XEndPoints(area);
                y = dataToPlot_M2(area,1);
                text(x, y+0.02, stars, ...
                    'Color',colEye, ...
                    'HorizontalAlignment','center', ...
                    'FontSize',10);

            elseif dirChi_EO_vs_Both_M2(area,v) == -1
                % BOTH > EO → black stars on BOTH bar
                x = hBar(3).XEndPoints(area);
                y = dataToPlot_M2(area,3);
                text(x, y+0.02, stars, ...
                    'Color',[0 0 0], ...
                    'HorizontalAlignment','center', ...
                    'FontSize',10);
            end
        end

        % ---------- AO vs BOTH ----------
        p = pvalChi_AO_vs_Both_M2(area,v);
        if ~isnan(p) && p < 0.05

            if p < 0.001
                stars = '***';
            elseif p < 0.01
                stars = '**';
            else
                stars = '*';
            end

            if dirChi_AO_vs_Both_M2(area,v) == +1
                % AO > BOTH → blue stars on AO bar
                x = hBar(2).XEndPoints(area);
                y = dataToPlot_M2(area,2);
                text(x, y+0.02, stars, ...
                    'Color',colArm, ...
                    'HorizontalAlignment','center', ...
                    'FontSize',10);

            elseif dirChi_AO_vs_Both_M2(area,v) == -1
                % BOTH > AO → gray stars on BOTH bar
                x = hBar(3).XEndPoints(area);
                y = dataToPlot_M2(area,3);
                text(x, y+0.03, stars, ...
                    'Color',[0.5 0.5 0.5], ...
                    'HorizontalAlignment','center', ...
                    'FontSize',10);
            end
        end

    end

    if v == 1
        legend({'Eye-only','Arm-only','Both'}, 'Location','best');
    end

end




%%

% =================== VALUE INT INDEX ===================
% Fraction of value-coding neurons that encode BOTH stimulus and action value
% (intersection / union), within the same motor system

ValueIntegration_Eye = nan(nAreas,1);
ValueIntegration_Arm = nan(nAreas,1);

for area = 1:nAreas

    % ---- Extract p-matrices ----
    % Predictor indices:
    % 2 = Stimulus (Object) Value
    % 3 = Action Value
    pEye_Stim = squeeze(pMats_Eye{2}(:,:,area));   % neurons x time
    pEye_Act  = squeeze(pMats_Eye{3}(:,:,area));

    pArm_Stim = squeeze(pMats_Arm{2}(:,:,area));
    pArm_Act  = squeeze(pMats_Arm{3}(:,:,area));

    nReal = sum(~isnan(pEye_Stim(:,1)));
    if nReal == 0
        continue
    end

    % ---- Peak bins ----
    bE_Stim = peakBin.eye(area,2);
    bE_Act  = peakBin.eye(area,3);

    bA_Stim = peakBin.arm(area,2);
    bA_Act  = peakBin.arm(area,3);

    if any(isnan([bE_Stim bE_Act bA_Stim bA_Act]))
        continue
    end

    % ---- Significant neurons ----
    eyeStimSig = pEye_Stim(1:nReal, bE_Stim) < pvalsign;
    eyeActSig  = pEye_Act (1:nReal, bE_Act ) < pvalsign;

    armStimSig = pArm_Stim(1:nReal, bA_Stim) < pvalsign;
    armActSig  = pArm_Act (1:nReal, bA_Act ) < pvalsign;

    % ---- Union and intersection ----
    eyeUnion = eyeStimSig | eyeActSig;
    eyeInter = eyeStimSig & eyeActSig;

    armUnion = armStimSig | armActSig;
    armInter = armStimSig & armActSig;

    % ---- Integration index ----
    if sum(eyeUnion) > 0
        ValueIntegration_Eye(area) = sum(eyeInter) / sum(eyeUnion);
    end

    if sum(armUnion) > 0
        ValueIntegration_Arm(area) = sum(armInter) / sum(armUnion);
    end
end
figure('Color','w','Position',[300 300 500 300]); hold on

b = bar([ValueIntegration_Eye ValueIntegration_Arm], 'grouped');

set(gca,'XTick',1:nAreas,'XTickLabel',areaLabels,'TickDir','out')
% ylabel('Value integration index')
ylim([0 1])

colEye = [0.85 0.33 0.10];   % orange
colArm = [0.30 0.75 0.93];   % blue
b(1).FaceColor = colEye;   % Eye
b(2).FaceColor = colArm;   % Arm
legend({'Eye','Arm'},'Location','northwest')
% title('Integration of Object and Action Value Coding')

box off
%%
% =================== VALUE–CHOICE OVERLAP (JACCARD) ===================
% Within the same motor system (Eye and Arm), per area:
% V = (Stimulus Value OR Action Value)
% D = Choice Direction
% Jaccard = |V ∩ D| / |V ∪ D|

ValueChoiceJacc_Eye = nan(nAreas,1);
ValueChoiceJacc_Arm = nan(nAreas,1);

for area = 1:nAreas

    % ---- Extract p-matrices ----
    % Predictor indices:
    % 1 = Direction
    % 2 = Stimulus Value
    % 3 = Action Value
    pEye_Dir  = squeeze(pMats_Eye{1}(:,:,area));   % neurons x time
    pEye_Stim = squeeze(pMats_Eye{2}(:,:,area));
    pEye_Act  = squeeze(pMats_Eye{3}(:,:,area));

    pArm_Dir  = squeeze(pMats_Arm{1}(:,:,area));
    pArm_Stim = squeeze(pMats_Arm{2}(:,:,area));
    pArm_Act  = squeeze(pMats_Arm{3}(:,:,area));

    % Consistent neuron count (pooled)
    nReal = sum(~isnan(pEye_Dir(:,1)));
    if nReal == 0
        continue
    end

    % ---- Peak bins ----
    bE_Dir  = peakBin.eye(area,1);
    bE_Stim = peakBin.eye(area,2);
    bE_Act  = peakBin.eye(area,3);

    bA_Dir  = peakBin.arm(area,1);
    bA_Stim = peakBin.arm(area,2);
    bA_Act  = peakBin.arm(area,3);

    if any(isnan([bE_Dir bE_Stim bE_Act bA_Dir bA_Stim bA_Act]))
        continue
    end

    % ---- Significant neurons at peak bins ----
    eyeDirSig  = pEye_Dir (1:nReal, bE_Dir ) < pvalsign;
    eyeStimSig = pEye_Stim(1:nReal, bE_Stim) < pvalsign;
    eyeActSig  = pEye_Act (1:nReal, bE_Act ) < pvalsign;

    armDirSig  = pArm_Dir (1:nReal, bA_Dir ) < pvalsign;
    armStimSig = pArm_Stim(1:nReal, bA_Stim) < pvalsign;
    armActSig  = pArm_Act (1:nReal, bA_Act ) < pvalsign;

    % ---- Define sets ----
    eyeValue = eyeStimSig | eyeActSig;   % V (Eye)
    eyeDir   = eyeDirSig;               % D (Eye)

    armValue = armStimSig | armActSig;  % V (Arm)
    armDir   = armDirSig;               % D (Arm)

    % ---- Jaccard overlap ----
    eyeUnion = eyeValue | eyeDir;
    eyeInter = eyeValue & eyeDir;

    armUnion = armValue | armDir;
    armInter = armValue & armDir;

    if sum(eyeUnion) > 0
        ValueChoiceJacc_Eye(area) = sum(eyeInter) / sum(eyeUnion);
    end

    if sum(armUnion) > 0
        ValueChoiceJacc_Arm(area) = sum(armInter) / sum(armUnion);
    end
end

colEye = [0.85 0.33 0.10];   % orange
colArm = [0.30 0.75 0.93];   % blue

figure('Color','w','Position',[300 300 520 300]); hold on

b = bar([ValueChoiceJacc_Eye ValueChoiceJacc_Arm], 'grouped');

b(1).FaceColor = colEye;   % Eye
b(2).FaceColor = colArm;   % Arm

set(gca,'XTick',1:nAreas,'XTickLabel',areaLabels)
ylabel('Overlap fraction (both / union)')
ylim([0 1])
legend({'Eye','Arm'},'Location','northwest')
title('Overlap of Value and Choice Direction Coding')

box off



%% =================== STIM–ACTION VALUE OVERLAP (JACCARD) ===================
% Within the same motor system (Eye and Arm), per area:
% S = Stimulus (Object) Value significant neurons
% A = Action Value significant neurons
% Jaccard = |S ∩ A| / |S ∪ A|
%
% Uses PEAK BIN for each predictor separately (same logic as your Value–Choice code).

StimActJacc_Eye = nan(nAreas,1);
StimActJacc_Arm = nan(nAreas,1);

% (Optional) extra descriptive overlaps
% fraction of Stim that is also Action, and fraction of Action that is also Stim
FracStimAlsoAct_Eye = nan(nAreas,1);
FracActAlsoStim_Eye = nan(nAreas,1);
FracStimAlsoAct_Arm = nan(nAreas,1);
FracActAlsoStim_Arm = nan(nAreas,1);

for area = 1:nAreas

    % Predictor indices (your convention):
    % 2 = Stimulus Value
    % 3 = Action Value
    pEye_Stim = squeeze(pMats_Eye{2}(:,:,area));  % neurons x time
    pEye_Act  = squeeze(pMats_Eye{3}(:,:,area));

    pArm_Stim = squeeze(pMats_Arm{2}(:,:,area));
    pArm_Act  = squeeze(pMats_Arm{3}(:,:,area));

    % ---- Real neuron mask (safer than 1:nReal) ----
    % Use Eye matrices as reference, or combine Eye+Arm if you prefer strict consistency.
    realMask = ~isnan(pEye_Stim(:,1)) & ~isnan(pEye_Act(:,1));
    nReal = sum(realMask);
    if nReal == 0
        continue
    end

    % ---- Peak bins (separate peak per predictor) ----
    bE_Stim = peakBin.eye(area,2);
    bE_Act  = peakBin.eye(area,3);

    bA_Stim = peakBin.arm(area,2);
    bA_Act  = peakBin.arm(area,3);

    if any(isnan([bE_Stim bE_Act bA_Stim bA_Act]))
        continue
    end

    % ---- Significant neurons at their predictor-specific peak bins ----
    eyeStimSig = pEye_Stim(realMask, bE_Stim) < pvalsign;
    eyeActSig  = pEye_Act (realMask, bE_Act ) < pvalsign;

    armStimSig = pArm_Stim(realMask, bA_Stim) < pvalsign;
    armActSig  = pArm_Act (realMask, bA_Act ) < pvalsign;

    % ---- Jaccard overlap ----
    eyeUnion = eyeStimSig | eyeActSig;
    eyeInter = eyeStimSig & eyeActSig;

    armUnion = armStimSig | armActSig;
    armInter = armStimSig & armActSig;

    if sum(eyeUnion) > 0
        StimActJacc_Eye(area) = sum(eyeInter) / sum(eyeUnion);
    end
    if sum(armUnion) > 0
        StimActJacc_Arm(area) = sum(armInter) / sum(armUnion);
    end

    % ---- Optional: conditional overlaps (helpful to interpret low Jaccard) ----
    if sum(eyeStimSig) > 0
        FracStimAlsoAct_Eye(area) = sum(eyeInter) / sum(eyeStimSig);
    end
    if sum(eyeActSig) > 0
        FracActAlsoStim_Eye(area) = sum(eyeInter) / sum(eyeActSig);
    end

    if sum(armStimSig) > 0
        FracStimAlsoAct_Arm(area) = sum(armInter) / sum(armStimSig);
    end
    if sum(armActSig) > 0
        FracActAlsoStim_Arm(area) = sum(armInter) / sum(armActSig);
    end
end

% ============================= BAR PLOT (JACCARD) =============================
colEye = [0.85 0.33 0.10];   % orange
colArm = [0.30 0.75 0.93];   % blue

figure('Color','w','Position',[300 300 520 300]); hold on

b = bar([StimActJacc_Eye StimActJacc_Arm], 'grouped');
b(1).FaceColor = colEye;   % Eye
b(2).FaceColor = colArm;   % Arm

set(gca,'XTick',1:nAreas,'XTickLabel',areaLabels,'TickDir','out')
ylabel('Jaccard overlap (intersection / union)')
ylim([0 1])
legend({'Eye','Arm'},'Location','northwest')
title('Overlap of Stimulus Value and Action Value Coding')
box off


%%



%% ================================================================
%  VALUE → CHOICE DIRECTION WITH PEAK BINS (POOLED MONKEYS)
%  Uses peakBin.arm/peakBin.eye for Value and Direction
% ================================================================

% p-matrices for Value and Choice Direction (same as embodied plot)
% 1: Direction        -> AllSesspDir_*
% 2: Stimulus Value   -> AllSess_pRw_*
% 3: Action Value     -> AllSesspSarsa_*
% (Reward non usato qui)

pDir_Eye = AllSesspDir_Eye;   % N x T x Area
pDir_Arm = AllSesspDir_Arm;

pSV_Eye  = AllSess_pRw_Eye;   % Stimulus Value
pSV_Arm  = AllSess_pRw_Arm;

pAV_Eye  = AllSesspSarsa_Eye; % Action Value
pAV_Arm  = AllSesspSarsa_Arm;

varNames = { 'Stimulus Value → Choice Direction', ...
             'Action Value → Choice Direction' };

% Value predictor indices in peakBin
idx_SV = 2;    % Stimulus Value
idx_AV = 3;    % Action Value
analysis_vars = [idx_SV, idx_AV];

alpha = 0.05;  % used only for p-value interpretation (non entra nella formula binomiale)

% Colors for CD categories (same-motor, other-motor, both)
col_same  = [1 1 1];   % same motor system
col_other = [0.5 0.5 0.5];   % other motor system
col_both  = [0.00 0.00 0.00];   % both
% figure('Position',[700 500 1000 900])
for area = 1:nAreas
figure('Position',[700 100 150 400])
    
    sgtitle(areaLabels{area}, 'FontSize',10,'FontWeight','bold');

    for k = 1:2

        pred = analysis_vars(k);  % 2 = SV, 3 = AV

        % ---------- Select Value p-matrices ----------
        if pred == 2
            pV_eye_full = pSV_Eye(:,:,area);
            pV_arm_full = pSV_Arm(:,:,area);
        else
            pV_eye_full = pAV_Eye(:,:,area);
            pV_arm_full = pAV_Arm(:,:,area);
        end

        % ---------- Choice Direction p-matrices ----------
        pCD_eye_full = pDir_Eye(:,:,area);
        pCD_arm_full = pDir_Arm(:,:,area);

        % ---------- Number of real neurons ----------
        N = sum(~isnan(pV_arm_full(:,1)));
        if N == 0
            continue
        end

        % ---------- Peak bins ----------
        % Value peaks (eye / arm) for this predictor & area
        bValE = peakBin.eye(area, pred);
        bValA = peakBin.arm(area, pred);

        % Choice Direction peaks (eye / arm) for predictor 1 (Direction)
        bCDE  = peakBin.eye(area, 1);
        bCDA  = peakBin.arm(area, 1);

        if isnan(bValE) || isnan(bValA) || isnan(bCDE) || isnan(bCDA)
            % nothing to do if any peak is missing
            continue
        end

        % ---------- VALUE significance at peak bin ----------
        val_eye = pV_eye_full(1:N, bValE) < 0.05;
        val_arm = pV_arm_full(1:N, bValA) < 0.05;

        % ---------- CHOICE-DIRECTION significance at peak bin ----------
        cd_eye = pCD_eye_full(1:N, bCDE) < 0.05;
        cd_arm = pCD_arm_full(1:N, bCDA) < 0.05;

        cd_eyeOnly  = cd_eye & ~cd_arm;
        cd_armOnly  = cd_arm & ~cd_eye;
        cd_both     = cd_eye &  cd_arm;

        % =================== VALUE GROUPS ===================
        % G1: Value eye-only
        % G2: Value arm-only

        G1 = find( val_eye & ~val_arm );   % value eye-only
        G2 = find( val_arm & ~val_eye );   % value arm-only

        groups = {G1, 'Value eye-only'; ...
                  G2, 'Value arm-only'};

        % ================= OBSERVED FRACTIONS (intersection) =================
        % obs_vals(g,1) = P(neuron ∈ Value_group_g AND CD_eyeOnly)
        % obs_vals(g,2) = P(neuron ∈ Value_group_g AND CD_armOnly)
        % obs_vals(g,3) = P(neuron ∈ Value_group_g AND CD_both)

        obs_vals = zeros(2,3);

        for g = 1:2
            Gidx = groups{g,1};
            if isempty(Gidx)
                obs_vals(g,:) = 0;
            else
                obs_vals(g,1) = sum(cd_eyeOnly(Gidx))  / N;
                obs_vals(g,2) = sum(cd_armOnly(Gidx))  / N;
                obs_vals(g,3) = sum(cd_both(Gidx))     / N;
            end
        end

        % ================== CHANCE FRACTIONS (independence) ==================
        % P(Value_eyeOnly)   = |G1| / N
        % P(Value_armOnly)   = |G2| / N
        % P(CD_eyeOnly)      = |cd_eyeOnly| / N
        % P(CD_armOnly)      = |cd_armOnly| / N
        % P(CD_both)         = |cd_both| / N
        %
        % Under independence, P(Value_group_g AND CD_cat) = P(Value_group_g)*P(CD_cat)

        p_valEyeOnly = numel(G1) / N;
        p_valArmOnly = numel(G2) / N;

        p_CD_eyeOnly = sum(cd_eyeOnly) / N;
        p_CD_armOnly = sum(cd_armOnly) / N;
        p_CD_both    = sum(cd_both)    / N;

        chance_vals = [ ...
            p_valEyeOnly * [p_CD_eyeOnly, p_CD_armOnly, p_CD_both]; ...
            p_valArmOnly * [p_CD_eyeOnly, p_CD_armOnly, p_CD_both] ];

        % ======================= PLOT ============================
        subplot(2,1,k); hold on

        b = bar(obs_vals,'grouped','FaceAlpha',1);
     

            set(b(1),'FaceColor',col_same );   % CD same-motor?
            set(b(2),'FaceColor',col_other);   % CD other-motor
            set(b(3),'FaceColor',col_both );   % CD both
        
        % x positions dei bar
        numGroups = size(obs_vals,1);
        numBars   = size(obs_vals,2);

        % Disegna linee di chance (opzionale)
        % dx = 0.1;
        % for j = 1:numBars
        %     xBars = b(j).XEndPoints;
        %     for g = 1:numGroups
        %         y = chance_vals(g,j);
        %         plot([xBars(g)-dx, xBars(g)+dx], ...
        %              [y y], 'k--','LineWidth',1);
        %     end
        % end

        % ================= ADD P-VALUES (binomial) ==================
        % Testiamo se l'intersezione osservata è > chance
        for g = 1:numGroups
            for j = 1:numBars
                k_obs = round(obs_vals(g,j) * N);   % numero neuroni osservati
                p_exp = chance_vals(g,j);           % probabilità attesa

                if p_exp > 0
                    pval = 1 - binocdf(k_obs-1, N, p_exp);
                else
                    pval = 1;
                end

                if pval < 0.001
                    stars = '***';
                elseif pval < 0.01
                    stars = '**';
                elseif pval < 0.05
                    stars = '*';
                else
                    stars = '';
                end

                if ~isempty(stars)
                    x = b(j).XEndPoints(g);
                    y = obs_vals(g,j);
                    text(x, y + 0.005, stars, ...
                        'HorizontalAlignment','center', ...
                        'FontSize',8,'FontWeight','bold');
                end
            end
        end

        set(gca,'XTick',1:2, ...
                'XTickLabel',{groups{:,2}}, ...
                'FontSize',8)

        ylabel('Fraction of neurons','FontSize',8)
        title(varNames{k},'FontSize',8,'FontWeight','bold')

        maxY = max([obs_vals(:); chance_vals(:)]);
        if maxY == 0
            maxY = 0.01;
        end
        ylim([0, maxY*1.4])
        if k==1
            legend({'CD same-motor','CD other-motor','CD both'}, ...
                'Location','northeast','Box','off','FontSize',7);
        end
        % if k==1
        %  legend({'Choice Dir. eye-only','Choice Dir. arm-only','Choice Dir. both'}, ...
        %        'Location','northeast','Box','off','FontSize',7);
        % end
    end % k (SV / AV)
end % area






%% SCATTER PLOT

ColorsCoding = struct( ...
    'arm',   [ 0.20 0.45 0.85 ], ...   
    'eye',   [ 1.00 0.55 0.15 ], ...   
    'both',  [ .2 .2 .2 ], ...   
    'none',  [ 0.6  0.6  0.6 ]);      

predictorNames = {'Direction','Stimulus Value','Action Value','Reward'};
areaLabels = {'PMd','vPFC','Put','Cd','lVS','mVS','GPi','Amy'};

pMats_Arm = { AllSesspDir_Arm,  AllSess_pRw_Arm,  AllSesspSarsa_Arm,  AllSesspNF_Arm };
pMats_Eye = { AllSesspDir_Eye,  AllSess_pRw_Eye,  AllSesspSarsa_Eye,  AllSesspNF_Eye };

betasArm = AllBetasSessions_Arm;
betasEye = AllBetasSessions_Eye;

for area = 1:nAreas

    figure('Position',[800 100 500 150])
    sgtitle(areaLabels{area}, 'FontSize',6)

    for v = 1:4

        % -----------------------------
        % 1. Estraggo p-values e betas
        % -----------------------------
        pA  = squeeze(pMats_Arm{v}(:,:,area));
        pE  = squeeze(pMats_Eye{v}(:,:,area));

        BArm = squeeze(betasArm{v}(:,:,area));
        BEye = squeeze(betasEye{v}(:,:,area));

        nReal = sum(~isnan(pA(:,1)));

        % -----------------------------
        % 2. Bin del picco
        % -----------------------------
        bA = peakBin.arm(area,v);
        bE = peakBin.eye(area,v);

        % -----------------------------
        % 3. Significatività nel bin del picco
        % -----------------------------
        armSigNeuron = pA(1:nReal, bA) < 0.05;
        eyeSigNeuron = pE(1:nReal, bE) < 0.05;

        % -----------------------------
        % 4. Betas nel bin del picco
        % -----------------------------
        betaA = BArm(1:nReal, bA);
        betaE = BEye(1:nReal, bE);

        % -----------------------------
        % 5. TRIM dei beta fuori range [-1, 1]
        % -----------------------------
        bad = betaA < -1 | betaA > 1 | betaE < -1 | betaE > 1;

        betaA(bad) = NaN;
        betaE(bad) = NaN;

        % opzionale: li marchiamo come "none"
        armSigNeuron(bad) = false;
        eyeSigNeuron(bad) = false;

        % -----------------------------
        % 6. Classificazione neuroni
        % -----------------------------
        cat = strings(nReal,1);
        cat( armSigNeuron & ~eyeSigNeuron ) = "arm";
        cat( eyeSigNeuron & ~armSigNeuron ) = "eye";
        cat( armSigNeuron &  eyeSigNeuron ) = "both";
        cat( ~armSigNeuron & ~eyeSigNeuron ) = "none";

        % -----------------------------
        % 7. SCATTER PLOT
        % -----------------------------
        subplot(1,4,v); hold on;
        title(predictorNames{v}, 'FontSize',5,'FontWeight','normal')
        xlabel('Beta'); ylabel('Beta')
        xline(0,'k'); yline(0,'k');

        ordered = ["none","both","eye","arm"];
        for c = ordered
            idx = (cat == c);
            scatter(betaE(idx), betaA(idx), ...
                4, ColorsCoding.(c), 'filled', 'MarkerFaceAlpha', 0.75);
        end

        % -----------------------------
        % 8. Regressione su neuroni validi
        % -----------------------------
        valid = ~isnan(betaA) & ~isnan(betaE);

        X = betaE(valid);
        Y = betaA(valid);

        if numel(X) > 3
            mdl = fitlm(X,Y);
            xx = linspace(min(X), max(X), 100);
            [yy, yCI] = predict(mdl, xx');

            plot(xx, yy, 'r','LineWidth',.75)
            plot(xx, yCI(:,1), 'r--')
            plot(xx, yCI(:,2), 'r--')

            R = corr(X,Y,'rows','complete');
            text(0.05, 0.95, sprintf('r = %.2f',R), ...
                 'Units','normalized','FontSize',5,'FontWeight','normal');
        end
           set(gca, 'TickDir','out', ...
                    'FontSize',5);

        axis square
        grid off

    end

     filename = areaLabels{area};
%             exportgraphics(f, filename, 'Resolution', 500);
%             close all;
% print(filename,'-dpdf'	,'-vector');
end




%%

%% for two tailed binomial ex. test
% ========================================================================
%   TWO-TAILED EXACT BINOMIAL TEST
%   EO vs BOTH  and  AO vs BOTH
%   H0: p = 0.5
%   HA: p ≠ 0.5
% ========================================================================

pval_EO_vs_Both = nan(nAreas, nPredictors);
pval_AO_vs_Both = nan(nAreas, nPredictors);

dir_EO_vs_Both  = zeros(nAreas, nPredictors);  % +1: EO > BOTH, -1: BOTH > EO
dir_AO_vs_Both  = zeros(nAreas, nPredictors);  % +1: AO > BOTH, -1: BOTH > AO

for v = 1:nPredictors

    pArm_full = pMats_Arm{v};
    pEye_full = pMats_Eye{v};

    for area = 1:nAreas

        pArm = squeeze(pArm_full(:,:,area));
        pEye = squeeze(pEye_full(:,:,area));

        nReal = sum(~isnan(pArm(:,1)));
        if nReal == 0
            continue
        end

        bA = peakBin.arm(area,v);
        bE = peakBin.eye(area,v);
        if isnan(bA) || isnan(bE)
            continue
        end

        armSig = pArm(1:nReal, bA) < pvalsign;
        eyeSig = pEye(1:nReal, bE) < pvalsign;

        EO   = sum( eyeSig & ~armSig );
        AO   = sum( armSig & ~eyeSig );
        BOTH = sum( eyeSig &  armSig );

        % ---------------- EO vs BOTH ----------------
        m = EO + BOTH;
        if m > 0
            X = EO;
            p = 2 * min( ...
                binocdf(X, m, 0.5), ...
                1 - binocdf(X-1, m, 0.5) );
            pval_EO_vs_Both(area,v) = p;

            if EO > BOTH
                dir_EO_vs_Both(area,v) = +1;
            elseif BOTH > EO
                dir_EO_vs_Both(area,v) = -1;
            end
        end

        % ---------------- AO vs BOTH ----------------
        m = AO + BOTH;
        if m > 0
            X = AO;
            p = 2 * min( ...
                binocdf(X, m, 0.5), ...
                1 - binocdf(X-1, m, 0.5) );
            pval_AO_vs_Both(area,v) = p;

            if AO > BOTH
                dir_AO_vs_Both(area,v) = +1;
            elseif BOTH > AO
                dir_AO_vs_Both(area,v) = -1;
            end
        end

    end
end

% ========================================================================
%   PLOT: TWO-TAILED EO/AO vs BOTH
% ========================================================================

figure('Position',[200 200 1100 600])

for v = 1:nPredictors

    subplot(2,2,v); hold on;
    title(sprintf('%s: Motor-specific vs Shared (two-tailed)', ...
        predictorNames{v}), 'FontSize',12,'FontWeight','bold');

    dataToPlot = [ ...
        frac_EyeOnly(:,v), ...
        frac_ArmOnly(:,v), ...
        frac_Both(:,v) ];

    hBar = bar(dataToPlot,'grouped'); hold on;

    % Colors
    colEye  = [0.85 0.33 0.10];
    colArm  = [0.30 0.75 0.93];
    colBoth = [0 0 0];

    set(hBar(1),'FaceColor',colEye);
    set(hBar(2),'FaceColor',colArm);
    set(hBar(3),'FaceColor',colBoth);

    set(gca,'XTick',1:nAreas,'XTickLabel',areaLabels, ...
        'FontSize',10,'XTickLabelRotation',45);
    ylabel('Fraction of neurons');
    ylim([0 max(dataToPlot(:))*1.35]);

    % ----------------- STARS -----------------
    for area = 1:nAreas

        % ---------- EO vs BOTH ----------
        p = pval_EO_vs_Both(area,v);
        if ~isnan(p) && p < 0.05

            stars = '*';
            if p < 0.001
                stars = '***';
            elseif p < 0.01
                stars = '**';
            end

            if dir_EO_vs_Both(area,v) == +1
                % EO > BOTH → orange on EO
                x = hBar(1).XEndPoints(area);
                y = dataToPlot(area,1);
                text(x, y+0.02, stars, 'Color',colEye, ...
                    'HorizontalAlignment','center','FontSize',10);

            elseif dir_EO_vs_Both(area,v) == -1
                % BOTH > EO → black on BOTH
                x = hBar(3).XEndPoints(area);
                y = dataToPlot(area,3);
                text(x, y+0.02, stars, 'Color',[0 0 0], ...
                    'HorizontalAlignment','center','FontSize',10);
            end
        end

        % ---------- AO vs BOTH ----------
        p = pval_AO_vs_Both(area,v);
        if ~isnan(p) && p < 0.05

            stars = '*';
            if p < 0.001
                stars = '***';
            elseif p < 0.01
                stars = '**';
            end

            if dir_AO_vs_Both(area,v) == +1
                % AO > BOTH → blue on AO
                x = hBar(2).XEndPoints(area);
                y = dataToPlot(area,2);
                text(x, y+0.02, stars, 'Color',colArm, ...
                    'HorizontalAlignment','center','FontSize',10);

            elseif dir_AO_vs_Both(area,v) == -1
                % BOTH > AO → gray on BOTH
                x = hBar(3).XEndPoints(area);
                y = dataToPlot(area,3);
                text(x, y+0.03, stars, 'Color',[0.5 0.5 0.5], ...
                    'HorizontalAlignment','center','FontSize',10);
            end
        end

    end

    if v == 1
        legend({'Eye-only','Arm-only','Both'});
    end
end




%%
% ========================================================================
%   EMBODIED > MOTOR-INVARIANT TEST (NEW ANALYSIS)
%   One-tailed binomial test:
%       H0: p_embodied = p_both
%       HA: p_embodied > p_both
% ========================================================================

pval_Eye_vs_Both = nan(nAreas, nPredictors);
pval_Arm_vs_Both = nan(nAreas, nPredictors);

% Loop across predictors and areas
for v = 1:nPredictors

    pArm_full = pMats_Arm{v};
    pEye_full = pMats_Eye{v};

    for area = 1:nAreas

        % Extract matrices
        pArm = squeeze(pArm_full(:,:,area));
        pEye = squeeze(pEye_full(:,:,area));

        % Count valid neurons
        nReal = sum(~isnan(pArm(:,1)));
        if nReal == 0
            continue
        end

        % Get peak bins (pooled)
        bA = peakBin.arm(area,v);
        bE = peakBin.eye(area,v);

        if isnan(bA) || isnan(bE)
            continue
        end

        % Find significant neurons in those bins
        armSig = pArm(1:nReal, bA) < pvalsign;
        eyeSig = pEye(1:nReal, bE) < pvalsign;

        % Categories
        EO   = sum( eyeSig & ~armSig );   % eye-only
        AO   = sum( armSig & ~eyeSig );   % arm-only
        BOTH = sum( eyeSig &  armSig );   % both

        % ====== Eye-only vs Both ======
        m = EO + BOTH;   % number of neurons in the comparison set
%         p0 = (alpha*(1-alpha)) / (alpha*(1-alpha) + alpha^2);

        if m > 0
            X = EO;
            pval_Eye_vs_Both(area,v) = 1 - binocdf(X - 1, m, 0.5);
%     pval_Eye_vs_Both(area,v) = 1 - binocdf(EO - 1, m, p0);

        end

        % ====== Arm-only vs Both ======
        m = AO + BOTH;
        if m > 0
            X = AO;
            pval_Arm_vs_Both(area,v) = 1 - binocdf(X - 1, m, 0.5);
%     pval_Eye_vs_Both(area,v) = 1 - binocdf(EO - 1, m, p0);

        end

    end
end


% ========================================================================
%   PLOT NEW FIGURE — EMBODIED (Eye-only, Arm-only) vs MOTOR-INVARIANT
%   Now with bars + colored stars
% ========================================================================

figure('Position',[200 200 1100 600])

for v = 1:nPredictors

    subplot(2,2,v); hold on;
    title(sprintf('%s: Embodied > Motor-invariant', predictorNames{v}), ...
          'FontSize',12,'FontWeight','bold');

    % -------------------------
    % Build bar data
    % -------------------------
    dataToPlot = [ ...
        frac_EyeOnly(:,v), ...
        frac_ArmOnly(:,v), ...
        frac_Both(:,v) ];

    hBar = bar(dataToPlot,'grouped'); 
    hold on;

    % Color bars
    set(hBar(1),'FaceColor',[0.85 0.33 0.10]);   % orange eye-only
    set(hBar(2),'FaceColor',[0.30 0.75 0.93]);   % blue arm-only
    set(hBar(3),'FaceColor',[0 0 0]);            % black both

    % Axes
    set(gca,'XTick',1:nAreas,'XTickLabel',areaLabels, ...
            'FontSize',10,'XTickLabelRotation',45);
    ylabel('Fraction of neurons');

    ylim([0 max(dataToPlot(:))*1.3]);

    % -------------------------
    % Add stars for significance
    % -------------------------
    for area = 1:nAreas

        % --- Eye-only vs Both -----------------------------------------
        p = pval_Eye_vs_Both(area,v);
        y = dataToPlot(area,1);     
        x = hBar(1).XEndPoints(area); 

        if ~isnan(p)
            if p < 0.001
                text(x, y+0.02, '***', 'Color',[0.85 0.33 0.10], ...
                     'HorizontalAlignment','center','FontSize',8);
            elseif p < 0.01
                text(x, y+0.02, '**', 'Color',[0.85 0.33 0.10], ...
                     'HorizontalAlignment','center','FontSize',8);
            elseif p < 0.05
                text(x, y+0.02, '*', 'Color',[0.85 0.33 0.10], ...
                     'HorizontalAlignment','center','FontSize',8);
            end
        end

        % --- Arm-only vs Both -----------------------------------------
        p = pval_Arm_vs_Both(area,v);
        y = dataToPlot(area,2);
        x = hBar(2).XEndPoints(area);

        if ~isnan(p)
            if p < 0.001
                text(x, y+0.02, '***', 'Color',[0.30 0.75 0.93], ...
                     'HorizontalAlignment','center','FontSize',8);
            elseif p < 0.01
                text(x, y+0.02, '**', 'Color',[0.30 0.75 0.93], ...
                     'HorizontalAlignment','center','FontSize',8);
            elseif p < 0.05
                text(x, y+0.02, '*', 'Color',[0.30 0.75 0.93], ...
                     'HorizontalAlignment','center','FontSize',8);
            end
        end

    end

    if v==1
        legend({'Eye-only','Arm-only','Both'})
    end

end






%%
function plot_all_predictorsBothMonkeys_main1(AllPSessions, titleName, Colors, predictorNames, TimeUsed)
if titleName == 'Monkey 1' 
    minConsecBins = 4;
yAxisMax = [.45; .45; .45; 3; .70; .45; .45; 3; 3; 3  ];
end
if titleName == 'Monkey 2' 
    minConsecBins = 2;
yAxisMax = [.25; .25; .45; 3; .45; .25; .25; 3; 3; 3  ];
elseif titleName == '2monkeys' 
    minConsecBins = 4;
yAxisMax = [.3; .3; .45; .3; .7; .3; .3; .3; .3; .3  ];
end
figure('Position',[200 50 350 700])
alpha = 0.05;
p0    = 0.05;
xmin_plot = TimeUsed(13);
xmax_plot = TimeUsed(61);
nRows = 4;
nCols = 3;
nPred = size(predictorNames,2);
minConsecBins = 4;  % minimum consecutive significant bins to show dots

% ========== LAYOUT PARAMETERS ==========
leftMargin   = 0.10;
rightMargin  = 0.04;
topMargin    = 0.07;
bottomMargin = 0.05;
hGap         = 0.05;
vGap         = 0.08;
dotFrac      = 0.30;
dotGap       = 0.005;

totalW = 1 - leftMargin - rightMargin;
totalH = 1 - topMargin - bottomMargin;
subH   = (totalH - (nRows-1)*vGap) / (nRows * (1 + dotFrac));
subW   = (totalW - (nCols-1)*hGap) / nCols;

for pred = 1:nPred

    col = mod(pred-1, nCols) + 1;
    row = floor((pred-1) / nCols) + 1;

    left   = leftMargin + (col-1) * (subW + hGap);
    bottom = 1 - topMargin - row * subH * (1+dotFrac) - (row-1) * vGap;

    ax = axes('Position', [left bottom subW subH]);
    hold on

    pMat = AllPSessions{pred};
    T    = length(TimeUsed);

    % Y limits per panel
    ymax = yAxisMax(pred);

    H_all = zeros(8, T);

    for area = 1:8
        tmp   = squeeze(pMat(:,:,area));
        nReal = sum(~isnan(tmp(:,1)));
        if nReal == 0
            continue
        end

        sigFrac          = sum(tmp < 0.05, 1) ./ nReal;
        sigFrac_smoothed = smoothdata(sigFrac, 'gaussian', 10);

        H = zeros(1,T);
        for t = 1:T
            k    = sum(tmp(1:nReal, t) < 0.05);
            pval = 1 - binocdf(k-1, nReal, p0);
            H(t) = (pval < alpha);
        end
        H_all(area,:) = H;

        plot(ax, TimeUsed, sigFrac_smoothed, ...
             'LineWidth', 0.8, 'Color', Colors(area,:))
    end

    % ========== AXES FORMATTING ==========
    ylim(ax, [0 ymax])
    yticks(ax, [0 ymax])
    xlim(ax, [xmin_plot xmax_plot])
    set(ax, 'TickDir', 'out', ...
            'FontSize', 7, ...
            'Clipping', 'on', ...
            'XTick', -600:600:1800, ...
            'XTickLabel', {'-.6','0','.6','1.2','1.8'},...
             'YTick', 0:.05:.7, ...
            'YTickLabel', {'0','0.5','.1','.15','.2','.25','.3','.35','.4','.45','.5','.55','.6','.65','.7'})
    title(ax, predictorNames{pred}, 'FontSize', 8)
    xlabel(ax, 'Time (ms)', 'FontSize', 7)
    line(ax, [xmin_plot xmax_plot], [0.05 0.05], ...
         'Color', [0.6 0.6 0.6], 'LineStyle', '--', 'LineWidth', 0.5)

    % ========== ASTERISK OVERLAY AXES ==========
    axPos      = get(ax, 'Position');
    dotRegionH = axPos(4) * dotFrac;

    ax2 = axes('Position', ...
               [axPos(1), ...
                axPos(2) + axPos(4) + dotGap, ...
                axPos(3), ...
                dotRegionH - dotGap]);
    hold(ax2, 'on')

    set(ax2, 'XLim', [xmin_plot xmax_plot], ...
             'YLim', [0 8], ...
             'Visible', 'off', ...
             'Clipping', 'on')

    for area = 1:8
        sigBins = find(H_all(area,:) == 1);
        if isempty(sigBins)
            continue
        end

        % ========== CONSECUTIVE BINS FILTER ==========
        % Find runs of consecutive significant bins
        % Keep only bins belonging to runs >= minConsecBins long
        H_area      = H_all(area,:);
        H_filtered  = zeros(1, T);

        % Find start and end of each consecutive run
        dH     = diff([0 H_area 0]);
        starts = find(dH == 1);
        ends   = find(dH == -1) - 1;

        for r = 1:length(starts)
            runLength = ends(r) - starts(r) + 1;
            if runLength >= minConsecBins
                H_filtered(starts(r):ends(r)) = 1;
            end
        end

        % Apply x range filter on top of consecutive filter
        validBins = find(H_filtered == 1 & ...
                         TimeUsed >= xmin_plot & ...
                         TimeUsed <= xmax_plot);

        if isempty(validBins)
            continue
        end

        plot(ax2, TimeUsed(validBins), ...
             repmat(area - 0.5, 1, length(validBins)), ...
             '.', 'MarkerSize', 4, 'Color', Colors(area,:))
    end

    axes(ax) %#ok<LAXES>

end

sgtitle(titleName, 'FontSize', 10)
end
%% ========================== FUNCTIONs TO PLOT =================================
function plot_all_predictorsBothMonkeys_main(AllPSessions, titleName, Colors, predictorNames, TimeUsed)

figure('Position',[200 0 500 730])
axis square

alpha   =   0.05  ;      % binomial significance level
p0      =   0.05  ;      % chance probability per bin (same as real test)

for pred   =   1: size(predictorNames,2)


    subplot(4,3,pred)
    hold on

    pMat =  AllPSessions{pred};   % 2000 × T × 8
    T    =  length(TimeUsed);

    for area = 1:8

        tmp    =  squeeze(pMat(:,:,area));   % 2000 × T
        nReal  =  sum(~isnan(tmp(:,1)));   % number of neurons

        if nReal == 0
            continue
        end

        % ========== Compute fraction significant (unsmoothed) ==========
        sigFrac = sum(tmp < 0.05, 1) ./ nReal;

        % ========== Smooth only for plotting ==========
        sigFrac_smoothed = smoothdata(sigFrac, 'gaussian', 8);

        % ========== BINOMIAL TEST ==========
        % Test: is sigFrac(bin) significantly above chance p0?
        % H(bin) = 1 if significant
        H = zeros(1,T);
        for t = 1:T
            % #sig neurons in this bin
            k = sum(tmp(1:nReal, t) < 0.05);
            % Binomial test: P(X >= k | nReal, p0)
            pval = 1 - binocdf(k-1, nReal, p0);
            H(t) = (pval < alpha);
        end

        % ========== PLOT (BASE LINE) ==========
        plot(TimeUsed, sigFrac_smoothed, 'LineWidth', 0.5, 'Color', Colors(area,:));

        % ========== HIGHLIGHT SIGNIFICANT SEGMENTS ==========
        sigIdx = find(H==1);

        if ~isempty(sigIdx)
            % Find continuous chunks
            d = diff(sigIdx);
            edges = [1, find(d>1)+1];
            ends  = [find(d>1), length(sigIdx)];

            for c = 1:length(edges)
                idxChunk = sigIdx(edges(c):ends(c));
                plot(TimeUsed(idxChunk), sigFrac_smoothed(idxChunk), ...
                    'LineWidth', 2, 'Color', Colors(area,:));
            end
        end
    end

 % ==================== CUSTOM Y-LIMITS ====================
    if  pred == 1 || pred == 2 ||  pred == 4 || pred == 6 ||  pred == 7 ||  pred == 8 ||  pred == 9
        ylim([0 0.3]);

        ticks = [0  .3 ];
        set(gca, ...
            'YTick', ticks, ...
            'TickDir','out', ...
            'FontSize',9);






    elseif  pred == 3 
        ylim([0 0.45]);

        ticks = [0 .45  ];
        set(gca, ...
            'YTick', ticks, ...
            'TickDir','out', ...
            'FontSize',9);
    else
        ylim([0 0.7]);

        ticks = [0   .7 ];
        set(gca, ...
            'YTick', ticks, ...
            'TickDir','out', ...
            'FontSize',9);
    end

    set(gca,'XTick',-600:600:1200,'XTickLabel',{'-.6','0','.6','1.2'},'FontSize',9);


    xlim([TimeUsed(13) TimeUsed(49)])
    title(predictorNames{pred})
    xlabel('Time (ms)','FontSize',9)
%     ylabel('fraction of coding neurons','FontSize',9)
line([TimeUsed(1) TimeUsed(end)], [0.05 0.05])


end

sgtitle(titleName)

end

function plot_all_predictors(AllPSessions, titleName, Colors, predictorNames, TimeUsed)

figure('Position',[200 200 1400 350])

alpha = 0.05;      % binomial significance level
p0    = 0.05;      % chance probability per bin (same as real test)

for pred = 1:5

    subplot(1,5,pred)
    hold on

    pMat = AllPSessions{pred};   % 2000 × T × 8
    T = length(TimeUsed);

    for area = 1:8

        tmp = squeeze(pMat(:,:,area));   % 2000 × T
        nReal = sum(~isnan(tmp(:,1)));   % number of neurons
        
        if nReal == 0
            continue
        end

        % ========== Compute fraction significant (unsmoothed) ==========
        sigFrac = sum(tmp < 0.05, 1) ./ nReal;

        % ========== Smooth only for plotting ==========
        sigFrac_smoothed = smoothdata(sigFrac, 'gaussian', 5);

        % ========== BINOMIAL TEST ==========
        % Test: is sigFrac(bin) significantly above chance p0?
        % H(bin) = 1 if significant
        H = zeros(1,T);
        for t = 1:T
            % #sig neurons in this bin
            k = sum(tmp(1:nReal, t) < 0.05);
            % Binomial test: P(X >= k | nReal, p0)
            pval = 1 - binocdf(k-1, nReal, p0);
            H(t) = (pval < alpha);
        end

        % ========== PLOT (BASE LINE) ==========
        plot(TimeUsed, sigFrac_smoothed, 'LineWidth', 1.5, 'Color', Colors(area,:));

        % ========== HIGHLIGHT SIGNIFICANT SEGMENTS ==========
        sigIdx = find(H==1);

        if ~isempty(sigIdx)
            % Find continuous chunks
            d = diff(sigIdx);
            edges = [1, find(d>1)+1];
            ends  = [find(d>1), length(sigIdx)];

            for c = 1:length(edges)
                idxChunk = sigIdx(edges(c):ends(c));
                plot(TimeUsed(idxChunk), sigFrac_smoothed(idxChunk), ...
                    'LineWidth', 4, 'Color', Colors(area,:));
            end
        end
    end

    % ==================== CUSTOM Y-LIMITS ====================
    if pred == 1 || pred == 4
        ylim([0 0.75]);
    else
        ylim([0 0.45]);
    end

    xlim([TimeUsed(1) TimeUsed(end)])
    title(predictorNames{pred})
    xlabel('Time (ms)')
    ylabel('Fraction sig. neurons')
end

sgtitle(titleName)

end



%%





%% =======================================================================
%     FUNCTION TO COMPUTE FRACTIONS FOR ANY DATASET
% =======================================================================

function [frac_EyeOnly, frac_ArmOnly, frac_Both] = ...
    computeFractions(pMats_Arm, pMats_Eye, TimeUsed, nAreas, nPredictors, minConsecBins)

frac_EyeOnly = nan(nAreas, nPredictors);
frac_ArmOnly = nan(nAreas, nPredictors);
frac_Both    = nan(nAreas, nPredictors);

for v = 1:nPredictors
    
    if v == 1
        tStart = 0; tEnd = 1000;
    elseif v==2 || v==3
        tStart = -1000; tEnd = 1000;
    else
        tStart = 1000; tEnd = 2000;
    end

    idxWin = (TimeUsed >= tStart) & (TimeUsed <= tEnd);

    pArm_full = pMats_Arm{v};
    pEye_full = pMats_Eye{v};

    for area = 1:nAreas

        pArm = squeeze(pArm_full(:,:,area));
        pEye = squeeze(pEye_full(:,:,area));

        nReal = sum(~isnan(pArm(:,1)));
        if nReal == 0
            continue
        end

        pArm_win = pArm(1:nReal, idxWin);
        pEye_win = pEye(1:nReal, idxWin);

        armSig = pArm_win < 0.05;
        eyeSig = pEye_win < 0.05;

        armRun = movsum(armSig, [0 minConsecBins-1], 2) >= minConsecBins;
        eyeRun = movsum(eyeSig, [0 minConsecBins-1], 2) >= minConsecBins;

        armNeuron = any(armRun,2);
        eyeNeuron = any(eyeRun,2);

        eyeOnly = sum( eyeNeuron & ~armNeuron );
        armOnly = sum( armNeuron & ~eyeNeuron );
        both    = sum( eyeNeuron &  armNeuron );

        frac_EyeOnly(area,v) = eyeOnly / nReal;
        frac_ArmOnly(area,v) = armOnly / nReal;
        frac_Both(area,v)    = both    / nReal;
    end
end
end


%% =================== HELPER FUNCTIONS ===================

function p_run = prob_at_least_one_run(T, k, alpha)
% Probability of >=1 run of >=k consecutive "successes" in T Bernoulli trials.
% Success prob per bin = alpha.
    if k <= 1
        p_run = 1 - (1-alpha)^T;
        return
    end
    if T < k
        p_run = 0;
        return
    end

    % Markov chain over run length states 0..k-1, conditioned on "no run yet"
    pState = zeros(1,k);
    pState(1) = 1;

    for t = 1:T
        pNew = zeros(1,k);

        % failure resets run length to 0
        pNew(1) = sum(pState) * (1-alpha);

        % success advances run length (runs reaching k are absorbing "success" and removed)
        for r = 2:k
            pNew(r) = pState(r-1) * alpha;
        end

        pState = pNew;
    end

    p_no_run = sum(pState);
    p_run = 1 - p_no_run;
end

function [chi2stat, p] = chi2independence_p(tbl)
% χ² test for independence on a 2x2 table (no Yates correction).
    if any(tbl(:) < 0) || any(isnan(tbl(:))) || size(tbl,1)~=2 || size(tbl,2)~=2
        chi2stat = NaN; p = NaN; return
    end
    N = sum(tbl(:));
    if N == 0
        chi2stat = NaN; p = NaN; return
    end
    rowS = sum(tbl,2);
    colS = sum(tbl,1);
    E = (rowS * colS) / N;

    if any(E(:) == 0)
        chi2stat = NaN; p = NaN; return
    end

    chi2stat = sum((tbl(:) - E(:)).^2 ./ E(:));
    p = 1 - chi2cdf(chi2stat, 1);
end

function s = p_to_stars(p)
% Convert p-value to stars; return '' if not significant at 0.05
    if p < 0.001
        s = '***';
    elseif p < 0.01
        s = '**';
    elseif p < 0.05
        s = '*';
    else
        s = '';
    end
end

function computeAndPlotSustainedFractions(AllPSessions, predictorNames, areaLabels, TimeUsed, Colors, tStart, tEnd, minSepBins)
% computeAndPlotSustainedFractions
 
% Computes sustained coding fractions and plots Value and Outcome results
%
% Inputs:
%   AllPSessions    - 1x10 cell, each cell is 2000 x 65 x 8 p-value matrix
%   predictorNames  - 1x10 cell of predictor names
%   areaLabels      - 1x8 cell of area labels
%   TimeUsed        - 1x65 vector of time points in ms
%   Colors          - 8x3 color matrix for areas
%   tStart          - start of time window in ms (e.g., 0)
%   tEnd            - end of time window in ms   (e.g., 1200)
%   minSepBins      - minimum bin separation for non-overlapping
%                     significance (default 5 for 250ms bins / 50ms steps)
%
% Example call:
%   computeAndPlotSustainedFractions(AllPSessions_Eye, predictorNames, ...
%       areaLabels, TimeUsed, Colors, 0, 1200, 5)

if nargin < 8
    minSepBins = 5;
end

nPred  = length(predictorNames);
nAreas = length(areaLabels);
p0     = 0.05;

% ══════════════════════════════════════════════════════════════════════
% STEP 1 — Find time bins within requested window
% ══════════════════════════════════════════════════════════════════════
binIdx = find(TimeUsed >= tStart & TimeUsed <= tEnd);
if isempty(binIdx)
    error('No time bins found in window [%d %d] ms', tStart, tEnd)
end
fprintf('Time window: %.0f to %.0f ms — %d bins\n', ...
        TimeUsed(binIdx(1)), TimeUsed(binIdx(end)), length(binIdx))

% ══════════════════════════════════════════════════════════════════════
% STEP 2 — Get neuron counts per area from NaN structure
% ══════════════════════════════════════════════════════════════════════
refMat   = AllPSessions{1,1};
nNeurons = zeros(1, nAreas);
for area = 1:nAreas
    tmp            = squeeze(refMat(:, 1, area));
    nNeurons(area) = sum(~isnan(tmp));
end

fprintf('\nNeurons per area:\n')
for area = 1:nAreas
    fprintf('  %s: %d\n', areaLabels{area}, nNeurons(area))
end

% ══════════════════════════════════════════════════════════════════════
% STEP 3 — Compute sustained fractions
% ══════════════════════════════════════════════════════════════════════
fraction = nan(nPred, nAreas);

for pred = 1:nPred
    pMat = AllPSessions{1, pred};  % 2000 x 65 x 8

    for area = 1:nAreas
        tmp   = squeeze(pMat(:, :, area));  % 2000 x 65
        nReal = nNeurons(area);

        if nReal == 0
            continue
        end

        % Extract real neurons and selected time window
        pWindow = tmp(1:nReal, binIdx);  % nReal x nBins

        % Classify each neuron as sustained or not
        isSustained = false(nReal, 1);

        for neu = 1:nReal
            sigBins = find(pWindow(neu,:) < 0.05);

            if length(sigBins) < 2
                continue
            end

            % Check if any pair of significant bins is non-overlapping
            % i.e. separated by at least minSepBins
            diffMat = sigBins' - sigBins;   % nSig x nSig
            diffMat(diffMat <= 0) = NaN;    % keep only positive differences
            if any(diffMat(:) >= minSepBins)
                isSustained(neu) = true;
            end
        end

        fraction(pred, area) = sum(isSustained) / nReal;
    end
end

% Print summary
fprintf('\nSustained fractions (min sep = %d bins):\n', minSepBins)
fprintf('%25s', '')
for area = 1:nAreas
    fprintf('%8s', areaLabels{area})
end
fprintf('\n')
for pred = 1:nPred
    fprintf('%25s', predictorNames{pred})
    for area = 1:nAreas
        fprintf('%8.3f', fraction(pred, area))
    end
    fprintf('\n')
end

% ══════════════════════════════════════════════════════════════════════
% STEP 4 — Find predictor indices
% ══════════════════════════════════════════════════════════════════════
idxValue        = find(strcmp(predictorNames, 'Value'));
idxValueMSyst   = find(strcmp(predictorNames, 'ValueMSyst'));
idxOutcome      = find(strcmp(predictorNames, 'Outcome'));
idxOutcomeMSyst = find(strcmp(predictorNames, 'OutcomeMSyst'));

if isempty(idxValue) || isempty(idxValueMSyst) || ...
   isempty(idxOutcome) || isempty(idxOutcomeMSyst)
    error('Could not find required predictor names. Check predictorNames cell array.')
end

% ══════════════════════════════════════════════════════════════════════
% STEP 5 — Bar positions
% ══════════════════════════════════════════════════════════════════════
barW     = 0.35;
barGap   = 0.05;
groupGap = 0.35;

groupWidth = 2*barW + barGap;
groupPos   = (0:nAreas-1) * (groupWidth + groupGap);

x1 = groupPos;                   % main effect bar positions
x2 = groupPos + barW + barGap;   % interaction bar positions
xTick = mean([x1; x2], 1);       % tick centered between bars

xLimLeft  = x1(1)   - barW;
xLimRight = x2(end) + barW;

% ══════════════════════════════════════════════════════════════════════
% STEP 6 — Helper: binomial test
% ══════════════════════════════════════════════════════════════════════
    function pval = binomTest(frac, n)
        k    = round(frac * n);
        pval = 1 - binocdf(k-1, n, p0);
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 7 — Helper: significance string
% ══════════════════════════════════════════════════════════════════════
    function str = sigStr(pval)
        if pval < 0.001
            str = '***';
        elseif pval < 0.01
            str = '**';
        elseif pval < 0.05
            str = '*';
        else
            str = 'ns';
        end
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 8 — Plotting function
% ══════════════════════════════════════════════════════════════════════
    function makePlot(idxMain, idxInter, mainLabel, interLabel, figTitle)

        figure('Position', [100 100 850 320])
        hold on

        yMaxAll = 0;  % track max y for ylim

        for area = 1:nAreas
            c     = Colors(area,:);
            cLight = min(c + 0.4, 1);  % lighter version for interaction bar
            n     = nNeurons(area);

            fMain  = fraction(idxMain,  area);
            fInter = fraction(idxInter, area);

            if isnan(fMain) || isnan(fInter)
                continue
            end

            % ── Main effect bar — solid ──────────────────────────────
            bar(x1(area), fMain, barW, ...
                'FaceColor', c, ...
                'EdgeColor', 'none')

            % ── Interaction bar — lighter ────────────────────────────
            bar(x2(area), fInter, barW, ...
                'FaceColor', cLight, ...
                'EdgeColor', c, ...
                'LineWidth', 1.0)

            % ── Significance above main effect bar ───────────────────
            pMain = binomTest(fMain, n);
            sMain = sigStr(pMain);
            if ~strcmp(sMain, 'ns')
                text(x1(area), fMain + 0.012, sMain, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', c*0.7)
            end

            % ── Significance above interaction bar ───────────────────
            pInter = binomTest(fInter, n);
            sInter = sigStr(pInter);
            if ~strcmp(sInter, 'ns')
                text(x2(area), fInter + 0.012, sInter, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', c*0.7)
            end

            % ── Fisher exact test between main and interaction ───────
            kMain  = round(fMain  * n);
            kInter = round(fInter * n);

            % Protect against degenerate cases
            if kMain > 0 && kInter > 0 && ...
               kMain < n && kInter < n
                contingency = [kMain,  n - kMain; ...
                               kInter, n - kInter];
                try
                    [~, pFisher] = fishertest(contingency);
                catch
                    pFisher = 1;
                end

                sFisher = sigStr(pFisher);
                if ~strcmp(sFisher, 'ns')
                    yBracket = max(fMain, fInter) + 0.03;
                    yMaxAll  = max(yMaxAll, yBracket + 0.04);

                    % Bracket lines
                    line([x1(area) x1(area)], [fMain     yBracket], ...
                         'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                    line([x2(area) x2(area)], [fInter    yBracket], ...
                         'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                    line([x1(area) x2(area)], [yBracket  yBracket], ...
                         'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)

                    text(mean([x1(area) x2(area)]), yBracket + 0.005, ...
                         sFisher, ...
                         'HorizontalAlignment', 'center', ...
                         'FontSize', 6.5, 'Color', [0.3 0.3 0.3])
                end
            end

            yMaxAll = max(yMaxAll, max(fMain, fInter) + 0.05);
        end

        % ── Chance line ───────────────────────────────────────────────
        line([xLimLeft xLimRight], [p0 p0], ...
             'Color', [0.5 0.5 0.5], ...
             'LineStyle', '--', ...
             'LineWidth', 0.8)

        % ── Legend ───────────────────────────────────────────────────
        % Use dummy patches for legend
        hMain  = patch(NaN, NaN, [0.5 0.5 0.5], ...
                       'EdgeColor', 'none', ...
                       'DisplayName', mainLabel);
        hInter = patch(NaN, NaN, [0.8 0.8 0.8], ...
                       'EdgeColor', [0.5 0.5 0.5], ...
                       'LineWidth', 1.0, ...
                       'DisplayName', interLabel);
        legend([hMain hInter], 'Location', 'northeast', ...
               'FontSize', 8, 'Box', 'off')

        % ── Axes formatting ───────────────────────────────────────────
        yLimTop = max(yMaxAll, 0.35);
        xlim([xLimLeft xLimRight])
        ylim([0 yLimTop])
        yticks(0:0.1:yLimTop)

        set(gca, 'XTick',      xTick, ...
                 'XTickLabel', areaLabels, ...
                 'TickDir',    'out', ...
                 'FontSize',   8, ...
                 'Box',        'off')

        ylabel('Fraction of neurons', 'FontSize', 9)
        title(figTitle, 'FontSize', 10)
        box off

    end

% ══════════════════════════════════════════════════════════════════════
% STEP 9 — Make the two figures
% ══════════════════════════════════════════════════════════════════════
makePlot(idxValue,   idxValueMSyst,   ...
         'Value (main effect)', 'Value × MSyst (interaction)', ...
         'Value coding — sustained fractions')

makePlot(idxOutcome, idxOutcomeMSyst, ...
         'Outcome (main effect)', 'Outcome × MSyst (interaction)', ...
         'Outcome coding — sustained fractions')
end

function computeAndPlotSustainedFractions_v2(AllPSessions, predictorNames, ...
    areaLabels, TimeUsed, Colors, tStart, tEnd)
% computeAndPlotSustainedFractions_v2
%
% Uses non-overlapping bin downsampling for independent bin assumption
% Correct chance level via analytical run probability
% Pearson chi-squared for comparison between main effect and interaction
%
% Inputs:
%   AllPSessions    - 1x10 cell, each 2000 x 65 x 8 p-value matrix
%   predictorNames  - 1x10 cell of predictor names
%   areaLabels      - 1x8 cell
%   TimeUsed        - 1x65 time vector in ms
%   Colors          - 8x3 color matrix
%   tStart          - window start in ms
%   tEnd            - window end in ms

% ══════════════════════════════════════════════════════════════════════
% PARAMETERS
% ══════════════════════════════════════════════════════════════════════
alpha       = 0.05;   % single bin significance threshold
nConsec     = 2;      % minimum consecutive significant bins
dsStep      = 5;      % downsample step — keep every 5th bin (non-overlapping)
                      % at 50ms steps this gives 250ms spacing = non-overlapping

nAreas = length(areaLabels);

% ══════════════════════════════════════════════════════════════════════
% STEP 1 — Find time bins within window
% ══════════════════════════════════════════════════════════════════════
binWin = find(TimeUsed >= tStart & TimeUsed <= tEnd);
if isempty(binWin)
    error('No bins in window [%d %d] ms', tStart, tEnd)
end
fprintf('Window: %.0f to %.0f ms — %d bins\n', ...
    TimeUsed(binWin(1)), TimeUsed(binWin(end)), length(binWin))

% ══════════════════════════════════════════════════════════════════════
% STEP 2 — Get neuron counts from NaN structure
% ══════════════════════════════════════════════════════════════════════
refMat   = AllPSessions{1,1};
nNeurons = zeros(1, nAreas);
for area = 1:nAreas
    tmp            = squeeze(refMat(:,1,area));
    nNeurons(area) = sum(~isnan(tmp));
end

fprintf('\nNeurons per area:\n')
for area = 1:nAreas
    fprintf('  %s: %d\n', areaLabels{area}, nNeurons(area))
end

% ══════════════════════════════════════════════════════════════════════
% STEP 3 — Find predictor indices
% ══════════════════════════════════════════════════════════════════════
idxValue        = find(strcmp(predictorNames, 'Value'));
idxValueMSyst   = find(strcmp(predictorNames, 'ValueMSyst'));
idxOutcome      = find(strcmp(predictorNames, 'Outcome'));
idxOutcomeMSyst = find(strcmp(predictorNames, 'OutcomeMSyst'));

if any([isempty(idxValue), isempty(idxValueMSyst), ...
        isempty(idxOutcome), isempty(idxOutcomeMSyst)])
    error('Could not find required predictor names. Check predictorNames.')
end

% ══════════════════════════════════════════════════════════════════════
% STEP 4 — Helper functions
% ══════════════════════════════════════════════════════════════════════

% Check if any row has >= nConsec consecutive TRUE bins
hasConsecRun = @(sigMat, n) any(conv2(double(sigMat), ones(1,n), 'valid') >= n, 2);

% Analytical probability of at least one run of length >= n
% in T independent Bernoulli trials with success prob p
    function prob = prob_at_least_one_run(T, n, p)
        % Uses inclusion-exclusion / recursive formula
        % P(at least one run of n successes in T trials)
        if T < n
            prob = 0;
            return
        end
        % Build probability vector using recursion
        % f(t) = P(first run of length n ends at position t)
        % P(at least one run) = 1 - P(no run)
        % Use Markov chain approach
        q = 1 - p;
        % State = current run length (0 to n)
        % Transition: if sig -> run+1, if not sig -> run=0
        % Absorbing state at run=n
        % P(absorbed by time T) = P(at least one run)
        
        % Transfer matrix approach
        % States 0..n-1 transient, state n absorbing
        A = zeros(n+1, n+1);
        for s = 0:n-1
            A(s+1, s+2) = p;      % success: run increases
            A(s+1, 1)   = q;      % failure: reset to 0
        end
        A(n+1, n+1) = 1;          % absorbing state
        
        % Start in state 0
        v0 = zeros(1, n+1);
        v0(1) = 1;
        
        % Propagate T steps
        vT = v0 * (A^T);
        prob = vT(n+1);
    end

% Pearson chi-squared for 2x2 table
    function pval = chi2test(a, b, c, d)
        % Table: [a b; c d]
        % a = main sig, not inter sig
        % b = inter sig, not main sig  
        % c = main sig AND inter sig
        % d = neither
        N  = a + b + c + d;
        if N == 0
            pval = 1;
            return
        end
        % Row and column totals
        R1 = a + b; R2 = c + d;
        C1 = a + c; C2 = b + d;
        % Expected
        E11 = R1*C1/N; E12 = R1*C2/N;
        E21 = R2*C1/N; E22 = R2*C2/N;
        if any([E11 E12 E21 E22] < 5)
            % Use Fisher exact if expected counts low
            [~, pval] = fishertest([a b; c d]);
        else
            chi2 = (a-E11)^2/E11 + (b-E12)^2/E12 + ...
                   (c-E21)^2/E21 + (d-E22)^2/E22;
            pval = 1 - chi2cdf(chi2, 1);
        end
    end

% Significance string
    function str = sigStr(p)
        if p < 0.001;      str = '***';
        elseif p < 0.01;   str = '**';
        elseif p < 0.05;   str = '*';
        else;              str = 'ns';
        end
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 5 — Compute fractions for a pair of predictors
% ══════════════════════════════════════════════════════════════════════
    function [fracMain, fracInter, fracBoth, fracNeither, ...
              chanceMain, chanceBoth, pChi] = ...
              computePair(idxMain, idxInter)

        pMain_full  = AllPSessions{1, idxMain};
        pInter_full = AllPSessions{1, idxInter};

        fracMain    = nan(1, nAreas);
        fracInter   = nan(1, nAreas);
        fracBoth    = nan(1, nAreas);
        fracNeither = nan(1, nAreas);
        chanceMain  = nan(1, nAreas);
        chanceBoth  = nan(1, nAreas);
        pChi        = nan(1, nAreas);

        for area = 1:nAreas
            nReal = nNeurons(area);
            if nReal == 0; continue; end

            pM = squeeze(pMain_full( :,:,area));
            pI = squeeze(pInter_full(:,:,area));

            pM = pM(1:nReal, :);
            pI = pI(1:nReal, :);

            % Restrict to window
            pMw = pM(:, binWin);
            pIw = pI(:, binWin);

            % Remove NaN bins
            validBins = ~isnan(pMw(1,:)) & ~isnan(pIw(1,:));
            pMw = pMw(:, validBins);
            pIw = pIw(:, validBins);

            % Downsample to non-overlapping bins
            % Keep bins where original index mod dsStep == 0
            origIdx      = binWin(validBins);
            dsMask       = mod(origIdx, dsStep) == 0;
            pMw          = pMw(:, dsMask);
            pIw          = pIw(:, dsMask);
            Tvalid       = size(pMw, 2);

            if Tvalid < nConsec
                continue
            end

            % Significance matrices
            sigM = pMw < alpha;
            sigI = pIw < alpha;

            % Classify neurons
            mainCoding  = hasConsecRun(sigM, nConsec);
            interCoding = hasConsecRun(sigI, nConsec);

            nMainOnly  = sum( mainCoding & ~interCoding);
            nInterOnly = sum(~mainCoding &  interCoding);
            nBoth      = sum( mainCoding &  interCoding);
            nNeither   = sum(~mainCoding & ~interCoding);

%             fracMain(area)    = (nMainOnly + nBoth) / nReal;
%             fracInter(area)   = (nInterOnly + nBoth) / nReal;
%             fracBoth(area)    = nBoth / nReal;
%             fracNeither(area) = nNeither / nReal;
            fracMain(area)    = (nMainOnly ) / nReal;
            fracInter(area)   = (nInterOnly ) / nReal;
            fracBoth(area)    = nBoth / nReal;
            fracNeither(area) = nNeither / nReal;
            % Correct chance level
            p_run          = prob_at_least_one_run(Tvalid, nConsec, alpha);
            chanceMain(area) = p_run;
            chanceBoth(area) = p_run^2;

            % Chi-squared: main effect fraction vs interaction fraction
            % 2x2 table comparing proportions from same N neurons
            % [main-only, inter-only; both, neither]
            % More correctly: test whether P(main) != P(inter)
            % Using McNemar-style: discordant cells
            % b = main-only (sig main, not inter)
            % c = inter-only (sig inter, not main)
            % McNemar: (b-c)^2 / (b+c)
            b = nMainOnly;
            c = nInterOnly;
            if (b + c) > 0
                mcnemar_stat = (b - c)^2 / (b + c);
                pChi(area)   = 1 - chi2cdf(mcnemar_stat, 1);
            else
                pChi(area) = 1;
            end
        end
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 6 — Compute for Value and Outcome pairs
% ══════════════════════════════════════════════════════════════════════
[fracMainV, fracInterV, fracBothV, ~, chanceMainV, chanceBothV, pChiV] = ...
    computePair(idxValue, idxValueMSyst);

[fracMainO, fracInterO, fracBothO, ~, chanceMainO, chanceBothO, pChiO] = ...
    computePair(idxOutcome, idxOutcomeMSyst);

% ══════════════════════════════════════════════════════════════════════
% STEP 7 — Bar positions
% ══════════════════════════════════════════════════════════════════════
barW     = 0.1;
barGap   = 0.025;
groupGap = 0.1;

groupWidth = 2*barW + barGap;
groupPos   = (0:nAreas-1) * (groupWidth + groupGap);

x1    = groupPos;
x2    = groupPos + barW + barGap;
xTick = mean([x1; x2], 1);

xLimLeft  = x1(1)   - barW;
xLimRight = x2(end) + barW;

% ══════════════════════════════════════════════════════════════════════
% STEP 8 — Plot function
% ══════════════════════════════════════════════════════════════════════
    function makePlot(fracMain, fracInter, chanceMain, chanceBoth, ...
                      pChi, mainLabel, interLabel, figTitle)

        figure('Position', [500 500 400 200])
        hold on

        yMaxAll = 0;

        for area = 1:nAreas
            c      = Colors(area,:);
            cLight = min(c + 0.35, 1);
            n      = nNeurons(area);

            fMain  = fracMain(area);
            fInter = fracInter(area);

            if isnan(fMain) || isnan(fInter)
                continue
            end

            % ── Bars ─────────────────────────────────────────────────
            bar(x1(area), fMain, barW, ...
                'FaceColor', c, 'EdgeColor', 'none')
            bar(x2(area), fInter, barW, ...
                'FaceColor', cLight, 'EdgeColor', c, 'LineWidth', 1.0)

            % ── Chance lines per area ─────────────────────────────────
            % Draw small tick at chance level for this area
            chM = chanceMain(area);
            chB = chanceBoth(area);

            % Binomial test: does fraction exceed chance?
            % Use correct chance level
            kMain  = round(fMain  * n);
            kInter = round(fInter * n);

            pMain  = 1 - binocdf(kMain  - 1, n, chM);
            pInter = 1 - binocdf(kInter - 1, n, chM);

            % Stars above bars
            sMain  = sigStr(pMain);
            sInter = sigStr(pInter);

            if ~strcmp(sMain, 'ns')
                text(x1(area), fMain + 0.012, sMain, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', c*0.7)
            end
            if ~strcmp(sInter, 'ns')
                text(x2(area), fInter + 0.012, sInter, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', c*0.7)
            end

            % ── McNemar bracket ───────────────────────────────────────
            sMcN = sigStr(pChi(area));
            if ~strcmp(sMcN, 'ns')
                yBracket = max(fMain, fInter) + 0.03;
                yMaxAll  = max(yMaxAll, yBracket + 0.04);

                line([x1(area) x1(area)], [fMain  yBracket], ...
                     'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                line([x2(area) x2(area)], [fInter yBracket], ...
                     'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                line([x1(area) x2(area)], [yBracket yBracket], ...
                     'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                text(mean([x1(area) x2(area)]), yBracket + 0.005, sMcN, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', [0.3 0.3 0.3])
            end

            yMaxAll = max(yMaxAll, max(fMain, fInter) + 0.05);
        end

        % ── Global chance line ────────────────────────────────────────
        % Use mean chance across areas as reference
        meanChance = nanmean(chanceMain);
        line([xLimLeft xLimRight], [meanChance meanChance], ...
             'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 0.8)

        % ── Legend ───────────────────────────────────────────────────
        hMain  = patch(NaN, NaN, [0.5 0.5 0.5], ...
                       'EdgeColor', 'none', 'DisplayName', mainLabel);
        hInter = patch(NaN, NaN, [0.8 0.8 0.8], ...
                       'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1.0, ...
                       'DisplayName', interLabel);
        legend([hMain hInter], 'Location', 'northeast', ...
               'FontSize', 8, 'Box', 'off')

        % ── Axes ─────────────────────────────────────────────────────
%         yLimTop = max(yMaxAll, 0.4);
yLimTop = .3;
        xlim([xLimLeft xLimRight])
        ylim([0 yLimTop])
        yticks(0:0.1:yLimTop)
        set(gca, 'XTick', xTick, 'XTickLabel', areaLabels, ...
                 'TickDir', 'out', 'FontSize', 8, 'Box', 'off')
        ylabel('Fraction of neurons', 'FontSize', 9)
        title(figTitle, 'FontSize', 10)
        box off
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 9 — Make figures
% ══════════════════════════════════════════════════════════════════════
makePlot(fracMainV, fracInterV, chanceMainV, chanceBothV, pChiV, ...
         'Value (main effect)', 'Value × MSyst (interaction)', ...
         'Value coding — sustained fractions')

makePlot(fracMainO, fracInterO, chanceMainO, chanceBothO, pChiO, ...
         'Outcome (main effect)', 'Outcome × MSyst (interaction)', ...
         'Outcome coding — sustained fractions')

fprintf('\nDone.\n')
end
 

function computeAndPlotSustainedFractions_v3(AllPSessions, predictorNames, ...
    areaLabels, TimeUsed, Colors, tStart, tEnd, dsStart)
% computeAndPlotSustainedFractions_v3
%
% Computes sustained coding fractions and plots Value and Outcome results
% Uses non-overlapping bin downsampling for independent bin assumption
% Correct chance level via analytical run probability
% McNemar test for paired comparison between main effect and interaction
%
% Inputs:
%   AllPSessions    - 1x10 cell, each 2000 x 65 x 8 p-value matrix
%   predictorNames  - 1x10 cell of predictor names
%   areaLabels      - 1x8 cell
%   TimeUsed        - 1x65 time vector in ms
%   Colors          - 8x3 color matrix
%   tStart          - window start in ms
%   tEnd            - window end in ms
%   dsStart         - which bin in window to start downsampling from (default 1)
%
% Example calls:
%   computeAndPlotSustainedFractions_v3(AllPSessions_Eye, predictorNames, ...
%       areaLabels, TimeUsed, Colors, 0, 1200, 1)
%
%   % Robustness check across all starting bins
%   for ds = 1:5
%       computeAndPlotSustainedFractions_v3(AllPSessions_Eye, predictorNames, ...
%           areaLabels, TimeUsed, Colors, 0, 1200, ds)
%   end

% ══════════════════════════════════════════════════════════════════════
% PARAMETERS
% ══════════════════════════════════════════════════════════════════════
if nargin < 8
    dsStart = 1;  % default: start from first bin in window
end

alpha   = 0.05;   % single bin significance threshold
nConsec = 2;      % minimum consecutive non-overlapping significant bins
dsStep  = 5;      % downsample step — every 5th bin = non-overlapping 250ms bins

nAreas = length(areaLabels);

fprintf('=== computeAndPlotSustainedFractions_v3 ===\n')
fprintf('Window: %.0f to %.0f ms\n', tStart, tEnd)
fprintf('Downsample: every %d bins starting from bin %d in window\n', dsStep, dsStart)

% ══════════════════════════════════════════════════════════════════════
% STEP 1 — Find time bins within window
% ══════════════════════════════════════════════════════════════════════
binWin = find(TimeUsed >= tStart & TimeUsed <= tEnd);
if isempty(binWin)
    error('No bins in window [%d %d] ms', tStart, tEnd)
end
fprintf('Bins in window: %d (%.0f to %.0f ms)\n', ...
    length(binWin), TimeUsed(binWin(1)), TimeUsed(binWin(end)))

% ══════════════════════════════════════════════════════════════════════
% STEP 2 — Get neuron counts from NaN structure
% ══════════════════════════════════════════════════════════════════════
refMat   = AllPSessions{1,1};
nNeurons = zeros(1, nAreas);
for area = 1:nAreas
    tmp            = squeeze(refMat(:,1,area));
    nNeurons(area) = sum(~isnan(tmp));
end

fprintf('\nNeurons per area:\n')
for area = 1:nAreas
    fprintf('  %s: %d\n', areaLabels{area}, nNeurons(area))
end

% ══════════════════════════════════════════════════════════════════════
% STEP 3 — Find predictor indices
% ══════════════════════════════════════════════════════════════════════
idxValue        = find(strcmp(predictorNames, 'Value'));
idxValueMSyst   = find(strcmp(predictorNames, 'ValueMSyst'));
idxOutcome      = find(strcmp(predictorNames, 'Outcome'));
idxOutcomeMSyst = find(strcmp(predictorNames, 'OutcomeMSyst'));

if any([isempty(idxValue), isempty(idxValueMSyst), ...
        isempty(idxOutcome), isempty(idxOutcomeMSyst)])
    error('Could not find required predictor names. Check predictorNames.')
end

% ══════════════════════════════════════════════════════════════════════
% STEP 4 — Helper functions
% ══════════════════════════════════════════════════════════════════════

% Check if any row has >= nConsec consecutive TRUE bins
hasConsecRun = @(sigMat, n) any( ...
    conv2(double(sigMat), ones(1,n), 'valid') >= n, 2);

% Analytical probability of at least one run of length >= n
% in T independent Bernoulli trials with success prob p
    function prob = prob_at_least_one_run(T, n, p)
        if T < n
            prob = 0;
            return
        end
        q = 1 - p;
        % Markov chain: states 0..n-1 transient, state n absorbing
        A = zeros(n+1, n+1);
        for s = 0:n-1
            A(s+1, s+2) = p;   % success: run length increases
            A(s+1, 1)   = q;   % failure: reset to 0
        end
        A(n+1, n+1) = 1;       % absorbing state
        v0 = zeros(1, n+1);
        v0(1) = 1;             % start in state 0
        vT   = v0 * (A^T);
        prob = vT(n+1);
    end

% Significance string
    function str = sigStr(p)
        if p < 0.001;      str = '***';
        elseif p < 0.01;   str = '**';
        elseif p < 0.05;   str = '*';
        else;              str = 'ns';
        end
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 5 — Compute fractions for a predictor pair
% ══════════════════════════════════════════════════════════════════════
    function [fracMain, fracInter, fracBoth, fracNeither, ...
              chanceMain, pMcNemar, nMain, nInter, nBothOut, nNeitherOut] = ...
              computePair(idxMain, idxInter)

        pMain_full  = AllPSessions{1, idxMain};
        pInter_full = AllPSessions{1, idxInter};

        fracMain    = nan(1, nAreas);
        fracInter   = nan(1, nAreas);
        fracBoth    = nan(1, nAreas);
        fracNeither = nan(1, nAreas);
        chanceMain  = nan(1, nAreas);
        pMcNemar    = nan(1, nAreas);
        nMain       = nan(1, nAreas);
        nInter      = nan(1, nAreas);
        nBothOut    = nan(1, nAreas);
        nNeitherOut = nan(1, nAreas);

        for area = 1:nAreas
            nReal = nNeurons(area);
            if nReal == 0; continue; end

            pM = squeeze(pMain_full( :,:,area));
            pI = squeeze(pInter_full(:,:,area));

            pM = pM(1:nReal, :);
            pI = pI(1:nReal, :);

            % Restrict to window
            pMw = pM(:, binWin);
            pIw = pI(:, binWin);

            % Remove NaN bins
            validBins = ~isnan(pMw(1,:)) & ~isnan(pIw(1,:));
            pMw = pMw(:, validBins);
            pIw = pIw(:, validBins);

            % ── Downsample to non-overlapping bins ────────────────────
            % Build local indices within valid window
            nValid    = sum(validBins);
            localIdx  = 1:nValid;

            % Keep bins starting from dsStart, every dsStep bins
            dsMask    = mod(localIdx - dsStart, dsStep) == 0;

            pMw       = pMw(:, dsMask);
            pIw       = pIw(:, dsMask);
            Tvalid    = size(pMw, 2);

            fprintf('  Area %s: %d valid bins, %d after downsampling (dsStart=%d)\n', ...
                areaLabels{area}, nValid, Tvalid, dsStart)

            if Tvalid < nConsec
                fprintf('  Warning: too few bins for area %s — skipping\n', ...
                    areaLabels{area})
                continue
            end

            % ── Significance matrices ─────────────────────────────────
            sigM = pMw < alpha;
            sigI = pIw < alpha;

            % ── Classify neurons ──────────────────────────────────────
            mainCoding  = hasConsecRun(sigM, nConsec);
            interCoding = hasConsecRun(sigI, nConsec);

            nMainOnly  = sum( mainCoding & ~interCoding);
            nInterOnly = sum(~mainCoding &  interCoding);
            nBoth      = sum( mainCoding &  interCoding);
            nNeither   = sum(~mainCoding & ~interCoding);

            % ── Fractions — strictly exclusive categories ─────────────
            % nBoth NOT included in either bar
            fracMain(area)    = nMainOnly  / nReal;
            fracInter(area)   = nInterOnly / nReal;
            fracBoth(area)    = nBoth      / nReal;
            fracNeither(area) = nNeither   / nReal;

            % Store counts for reporting
            nMain(area)       = nMainOnly;
            nInter(area)      = nInterOnly;
            nBothOut(area)    = nBoth;
            nNeitherOut(area) = nNeither;

            % ── Correct chance level ──────────────────────────────────
            p_run           = prob_at_least_one_run(Tvalid, nConsec, alpha);
            chanceMain(area) = p_run;

            % ── McNemar test ──────────────────────────────────────────
            % Discordant cells only:
            % b = nMainOnly (main sig, inter not sig)
            % c = nInterOnly (inter sig, main not sig)
            b = nMainOnly;
            c = nInterOnly;
            if (b + c) > 0
                mcnemar_stat  = (b - c)^2 / (b + c);
                pMcNemar(area) = 1 - chi2cdf(mcnemar_stat, 1);
            else
                pMcNemar(area) = 1;
            end
        end
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 6 — Compute for Value and Outcome pairs
% ══════════════════════════════════════════════════════════════════════
fprintf('\n--- Value pair ---\n')
[fracMainV, fracInterV, fracBothV, fracNeitherV, ...
 chanceMainV, pMcNemarV, nMainV, nInterV, nBothV, nNeitherV] = ...
    computePair(idxValue, idxValueMSyst);

fprintf('\n--- Outcome pair ---\n')
[fracMainO, fracInterO, fracBothO, fracNeitherO, ...
 chanceMainO, pMcNemarO, nMainO, nInterO, nBothO, nNeitherO] = ...
    computePair(idxOutcome, idxOutcomeMSyst);

% ══════════════════════════════════════════════════════════════════════
% STEP 7 — Print summary tables
% ══════════════════════════════════════════════════════════════════════
fprintf('\n=== VALUE SUMMARY ===\n')
fprintf('%10s %8s %8s %8s %8s %8s %8s\n', ...
    'Area','nMain','nInter','nBoth','nNeither','fMain','fInter')
for area = 1:nAreas
    fprintf('%10s %8.0f %8.0f %8.0f %8.0f %8.3f %8.3f\n', ...
        areaLabels{area}, nMainV(area), nInterV(area), ...
        nBothV(area), nNeitherV(area), ...
        fracMainV(area), fracInterV(area))
end

fprintf('\n=== OUTCOME SUMMARY ===\n')
fprintf('%10s %8s %8s %8s %8s %8s %8s\n', ...
    'Area','nMain','nInter','nBoth','nNeither','fMain','fInter')
for area = 1:nAreas
    fprintf('%10s %8.0f %8.0f %8.0f %8.0f %8.3f %8.3f\n', ...
        areaLabels{area}, nMainO(area), nInterO(area), ...
        nBothO(area), nNeitherO(area), ...
        fracMainO(area), fracInterO(area))
end

% ══════════════════════════════════════════════════════════════════════
% STEP 8 — Bar positions
% ══════════════════════════════════════════════════════════════════════
barW     = 0.35;
barGap   = 0.05;
groupGap = 0.35;

groupWidth = 2*barW + barGap;
groupPos   = (0:nAreas-1) * (groupWidth + groupGap);

x1    = groupPos;
x2    = groupPos + barW + barGap;
xTick = mean([x1; x2], 1);

xLimLeft  = x1(1)   - barW;
xLimRight = x2(end) + barW;

% ══════════════════════════════════════════════════════════════════════
% STEP 9 — Plot function
% ══════════════════════════════════════════════════════════════════════
    function makePlot(fracMain, fracInter, fracBoth, ...
                      chanceMain, pMcNemar, ...
                      mainLabel, interLabel, figTitle)

        figure('Position', [100 100 850 340])
        hold on

        yMaxAll = 0;

        for area = 1:nAreas
            c      = Colors(area,:);
            cLight = min(c + 0.35, 1);
            n      = nNeurons(area);

            fMain  = fracMain(area);
            fInter = fracInter(area);
            fBoth  = fracBoth(area);

            if isnan(fMain) || isnan(fInter)
                continue
            end

            % ── Bars ─────────────────────────────────────────────────
            bar(x1(area), fMain, barW, ...
                'FaceColor', c, 'EdgeColor', 'none')
            bar(x2(area), fInter, barW, ...
                'FaceColor', cLight, 'EdgeColor', c, 'LineWidth', 1.0)

            % ── Binomial test against correct chance level ────────────
            chM = chanceMain(area);
            if isnan(chM); chM = alpha; end

            kMain  = round(fMain  * n);
            kInter = round(fInter * n);

            pMain  = 1 - binocdf(max(kMain  - 1, 0), n, chM);
            pInter = 1 - binocdf(max(kInter - 1, 0), n, chM);

            sMain  = sigStr(pMain);
            sInter = sigStr(pInter);

            yStarMain  = fMain  + 0.008;
            yStarInter = fInter + 0.008;

            if ~strcmp(sMain, 'ns')
                text(x1(area), yStarMain, sMain, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', c * 0.7)
            end
            if ~strcmp(sInter, 'ns')
                text(x2(area), yStarInter, sInter, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', c * 0.7)
            end

            % ── McNemar bracket ───────────────────────────────────────
            sMcN = sigStr(pMcNemar(area));
            if ~strcmp(sMcN, 'ns')
                yBracket = max(fMain, fInter) + 0.025;
                yMaxAll  = max(yMaxAll, yBracket + 0.03);

                line([x1(area) x1(area)], [fMain  yBracket], ...
                     'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                line([x2(area) x2(area)], [fInter yBracket], ...
                     'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                line([x1(area) x2(area)], [yBracket yBracket], ...
                     'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                text(mean([x1(area) x2(area)]), yBracket + 0.005, sMcN, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', [0.3 0.3 0.3])
            end

            yMaxAll = max(yMaxAll, max(fMain, fInter) + 0.04);

            % ── Small text showing fBoth below x axis ─────────────────
            % Optional: uncomment to show nBoth fraction as text
            % text(mean([x1(area) x2(area)]), -0.01, ...
            %      sprintf('b=%.2f', fBoth), ...
            %      'HorizontalAlignment', 'center', ...
            %      'FontSize', 5.5, 'Color', [0.5 0.5 0.5])
        end

        % ── Global chance line ────────────────────────────────────────
        meanChance = nanmean(chanceMain);
        line([xLimLeft xLimRight], [meanChance meanChance], ...
             'Color', [0.5 0.5 0.5], ...
             'LineStyle', '--', 'LineWidth', 0.8)
        text(xLimRight + 0.1, meanChance, ...
             sprintf('chance=%.3f', meanChance), ...
             'FontSize', 7, 'Color', [0.5 0.5 0.5], ...
             'VerticalAlignment', 'middle')

        % ── Legend ───────────────────────────────────────────────────
        hMain  = patch(NaN, NaN, [0.5 0.5 0.5], ...
                       'EdgeColor', 'none', ...
                       'DisplayName', mainLabel);
        hInter = patch(NaN, NaN, [0.8 0.8 0.8], ...
                       'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1.0, ...
                       'DisplayName', interLabel);
        legend([hMain hInter], 'Location', 'northeast', ...
               'FontSize', 8, 'Box', 'off')

        % ── Axes ─────────────────────────────────────────────────────
        yLimTop = max(yMaxAll, 0.35);
        xlim([xLimLeft xLimRight])
        ylim([0 yLimTop])
        yticks(0:0.05:yLimTop)

        set(gca, 'XTick',      xTick, ...
                 'XTickLabel', areaLabels, ...
                 'TickDir',    'out', ...
                 'FontSize',   8, ...
                 'Box',        'off')

        ylabel('Fraction of neurons', 'FontSize', 9)
        title(sprintf('%s  (dsStart=%d)', figTitle, dsStart), 'FontSize', 10)
        box off
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 10 — Make figures
% ══════════════════════════════════════════════════════════════════════
makePlot(fracMainV, fracInterV, fracBothV, ...
         chanceMainV, pMcNemarV, ...
         'Value only (main effect)', ...
         'Value × MSyst only (interaction)', ...
         'Value coding — exclusive sustained fractions')

makePlot(fracMainO, fracInterO, fracBothO, ...
         chanceMainO, pMcNemarO, ...
         'Outcome only (main effect)', ...
         'Outcome × MSyst only (interaction)', ...
         'Outcome coding — exclusive sustained fractions')

fprintf('\nDone.\n')
end

function computeAndPlotFractions_v3(AllPSessions, predictorNames, ...
    areaLabels, TimeUsed, Colors, tStart, tEnd)
% computeAndPlotFractions_v3
%
% Computes peak fraction of significant neurons within a time window
% and plots Value and Outcome results as bar plots.
% Bars show exclusive categories: main-effect-only vs interaction-only.
% Binomial test against p0=0.05 for each bar.
% McNemar test compares the two fractions within each area.
% Peak is defined as the time bin with highest fraction of sig neurons.
%
% Inputs:
%   AllPSessions    - 1x10 cell, each 2000 x 65 x 8 p-value matrix
%   predictorNames  - 1x10 cell of predictor names
%   areaLabels      - 1x8 cell of area labels
%   TimeUsed        - 1x65 time vector in ms
%   Colors          - 8x3 color matrix for areas
%   tStart          - window start in ms
%   tEnd            - window end in ms
%
% Example call:
%   computeAndPlotFractions_v3(AllPSessions_Eye, predictorNames, ...
%       areaLabels, TimeUsed, Colors, 0, 1200)

% ══════════════════════════════════════════════════════════════════════
% PARAMETERS
% ══════════════════════════════════════════════════════════════════════
alpha  = 0.05;   % single bin significance threshold
p0     = 0.05;   % chance level for binomial test
nAreas = length(areaLabels);

fprintf('=== computeAndPlotFractions_v3 ===\n')
fprintf('Window: %.0f to %.0f ms\n', tStart, tEnd)
fprintf('Criterion: peak fraction of significant neurons in window\n')
fprintf('Binomial test against p0 = %.2f\n', p0)

% ══════════════════════════════════════════════════════════════════════
% STEP 1 — Find time bins within window
% ══════════════════════════════════════════════════════════════════════
binWin = find(TimeUsed >= tStart & TimeUsed <= tEnd);
if isempty(binWin)
    error('No bins found in window [%d %d] ms', tStart, tEnd)
end
fprintf('Bins in window: %d (%.0f to %.0f ms)\n', ...
    length(binWin), TimeUsed(binWin(1)), TimeUsed(binWin(end)))

% ══════════════════════════════════════════════════════════════════════
% STEP 2 — Get neuron counts from NaN structure
% ══════════════════════════════════════════════════════════════════════
refMat   = AllPSessions{1,1};
nNeurons = zeros(1, nAreas);
for area = 1:nAreas
    tmp            = squeeze(refMat(:,1,area));
    nNeurons(area) = sum(~isnan(tmp));
end

fprintf('\nNeurons per area:\n')
for area = 1:nAreas
    fprintf('  %s: %d\n', areaLabels{area}, nNeurons(area))
end

% ══════════════════════════════════════════════════════════════════════
% STEP 3 — Find predictor indices
% ══════════════════════════════════════════════════════════════════════
idxValue        = find(strcmp(predictorNames, 'Value'));
idxValueMSyst   = find(strcmp(predictorNames, 'ValueMSyst'));
idxOutcome      = find(strcmp(predictorNames, 'Outcome'));
idxOutcomeMSyst = find(strcmp(predictorNames, 'OutcomeMSyst'));

if any([isempty(idxValue), isempty(idxValueMSyst), ...
        isempty(idxOutcome), isempty(idxOutcomeMSyst)])
    error('Could not find required predictor names. Check predictorNames.')
end

% ══════════════════════════════════════════════════════════════════════
% STEP 4 — Helper functions
% ══════════════════════════════════════════════════════════════════════

% Significance string
    function str = sigStr(p)
        if p < 0.001;      str = '***';
        elseif p < 0.01;   str = '**';
        elseif p < 0.05;   str = '*';
        else;              str = 'ns';
        end
    end

% Binomial test: is observed fraction significantly above p0?
    function pval = binomTest(frac, n)
        k    = round(frac * n);
        pval = 1 - binocdf(k - 1, n, p0);
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 5 — Compute peak fractions for a predictor pair
% ══════════════════════════════════════════════════════════════════════
    function [fracMain, fracInter, fracBoth, fracNeither, ...
              peakBinMain, peakBinInter, pMcNemar, ...
              nMainOnly, nInterOnly, nBothOut, nNeitherOut] = ...
              computePair(idxMain, idxInter)

        pMain_full  = AllPSessions{1, idxMain};
        pInter_full = AllPSessions{1, idxInter};

        fracMain     = nan(1, nAreas);
        fracInter    = nan(1, nAreas);
        fracBoth     = nan(1, nAreas);
        fracNeither  = nan(1, nAreas);
        peakBinMain  = nan(1, nAreas);
        peakBinInter = nan(1, nAreas);
        pMcNemar     = nan(1, nAreas);
        nMainOnly    = nan(1, nAreas);
        nInterOnly   = nan(1, nAreas);
        nBothOut     = nan(1, nAreas);
        nNeitherOut  = nan(1, nAreas);

        for area = 1:nAreas
            nReal = nNeurons(area);
            if nReal == 0; continue; end

            % Get p-value matrices
            pM = squeeze(pMain_full( :,:,area));
            pI = squeeze(pInter_full(:,:,area));

            pM = pM(1:nReal, :);
            pI = pI(1:nReal, :);

            % Restrict to window
            pMw = pM(:, binWin);  % nReal x nBins
            pIw = pI(:, binWin);  % nReal x nBins

            % ── Find peak bin for each predictor ──────────────────────
            fracPerBinM = sum(pMw < alpha, 1) ./ nReal;
            fracPerBinI = sum(pIw < alpha, 1) ./ nReal;

            [~, pkM] = max(fracPerBinM);
            [~, pkI] = max(fracPerBinI);

            peakBinMain(area)  = binWin(pkM);
            peakBinInter(area) = binWin(pkI);

            % ── Classify neurons at their respective peak bins ────────
            sigAtPeakM = pMw(:, pkM) < alpha;  % nReal x 1
            sigAtPeakI = pIw(:, pkI) < alpha;  % nReal x 1

            % Four mutually exclusive groups
            nMO = sum( sigAtPeakM & ~sigAtPeakI);  % main only
            nIO = sum(~sigAtPeakM &  sigAtPeakI);  % interaction only
            nBO = sum( sigAtPeakM &  sigAtPeakI);  % both
            nNO = sum(~sigAtPeakM & ~sigAtPeakI);  % neither

            % Store counts
            nMainOnly(area)   = nMO;
            nInterOnly(area)  = nIO;
            nBothOut(area)    = nBO;
            nNeitherOut(area) = nNO;

            % Exclusive fractions — nBoth NOT included in either bar
            fracMain(area)    = nMO / nReal;
            fracInter(area)   = nIO / nReal;
            fracBoth(area)    = nBO / nReal;
            fracNeither(area) = nNO / nReal;

            % ── McNemar test ──────────────────────────────────────────
            b = nMO;  % main only
            c = nIO;  % interaction only
            if (b + c) > 0
                mcnemar_stat   = (b - c)^2 / (b + c);
                pMcNemar(area) = 1 - chi2cdf(mcnemar_stat, 1);
            else
                pMcNemar(area) = 1;
            end

            fprintf('  %s: peak main=bin%d(%.0fms) peak inter=bin%d(%.0fms)\n', ...
                areaLabels{area}, ...
                peakBinMain(area),  TimeUsed(peakBinMain(area)), ...
                peakBinInter(area), TimeUsed(peakBinInter(area)))
        end
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 6 — Compute for Value and Outcome pairs
% ══════════════════════════════════════════════════════════════════════
fprintf('\n--- Value pair ---\n')
[fracMainV, fracInterV, fracBothV, fracNeitherV, ...
 peakBinMainV, peakBinInterV, pMcNemarV, ...
 nMainV, nInterV, nBothV, nNeitherV] = ...
    computePair(idxValue, idxValueMSyst);

fprintf('\n--- Outcome pair ---\n')
[fracMainO, fracInterO, fracBothO, fracNeitherO, ...
 peakBinMainO, peakBinInterO, pMcNemarO, ...
 nMainO, nInterO, nBothO, nNeitherO] = ...
    computePair(idxOutcome, idxOutcomeMSyst);

% ══════════════════════════════════════════════════════════════════════
% STEP 7 — Print summary tables
% ══════════════════════════════════════════════════════════════════════
fprintf('\n=== VALUE SUMMARY ===\n')
fprintf('%10s %8s %8s %8s %8s %8s %8s %10s %10s\n', ...
    'Area','nMain','nInter','nBoth','nNeither','fMain','fInter', ...
    'pkMain(ms)','pkInter(ms)')
for area = 1:nAreas
    fprintf('%10s %8.0f %8.0f %8.0f %8.0f %8.3f %8.3f %10.0f %10.0f\n', ...
        areaLabels{area}, ...
        nMainV(area), nInterV(area), nBothV(area), nNeitherV(area), ...
        fracMainV(area), fracInterV(area), ...
        TimeUsed(peakBinMainV(area)), TimeUsed(peakBinInterV(area)))
end

fprintf('\n=== OUTCOME SUMMARY ===\n')
fprintf('%10s %8s %8s %8s %8s %8s %8s %10s %10s\n', ...
    'Area','nMain','nInter','nBoth','nNeither','fMain','fInter', ...
    'pkMain(ms)','pkInter(ms)')
for area = 1:nAreas
    fprintf('%10s %8.0f %8.0f %8.0f %8.0f %8.3f %8.3f %10.0f %10.0f\n', ...
        areaLabels{area}, ...
        nMainO(area), nInterO(area), nBothO(area), nNeitherO(area), ...
        fracMainO(area), fracInterO(area), ...
        TimeUsed(peakBinMainO(area)), TimeUsed(peakBinInterO(area)))
end

% ══════════════════════════════════════════════════════════════════════
% STEP 8 — Bar positions
% ══════════════════════════════════════════════════════════════════════
barW     = 0.35;
barGap   = 0.05;
groupGap = 0.35;

groupWidth = 2*barW + barGap;
groupPos   = (0:nAreas-1) * (groupWidth + groupGap);

x1    = groupPos;
x2    = groupPos + barW + barGap;
xTick = mean([x1; x2], 1);

xLimLeft  = x1(1)   - barW;
xLimRight = x2(end) + barW;

% ══════════════════════════════════════════════════════════════════════
% STEP 9 — Plot function
% ══════════════════════════════════════════════════════════════════════
    function makePlot(fracMain, fracInter, fracBoth, ...
                      pMcNemar, mainLabel, interLabel, figTitle)

        figure('Position', [100 100 850 340])
        hold on

        yMaxAll = 0;

        for area = 1:nAreas
            c      = Colors(area,:);
            cLight = min(c + 0.35, 1);
            n      = nNeurons(area);

            fMain  = fracMain(area);
            fInter = fracInter(area);

            if isnan(fMain) || isnan(fInter)
                continue
            end

            % ── Bars ─────────────────────────────────────────────────
            bar(x1(area), fMain, barW, ...
                'FaceColor', c, 'EdgeColor', 'none')
            bar(x2(area), fInter, barW, ...
                'FaceColor', cLight, 'EdgeColor', c, 'LineWidth', 1.0)

            % ── Binomial test stars above each bar ────────────────────
            pBinMain  = binomTest(fMain,  n);
            pBinInter = binomTest(fInter, n);

            sMain  = sigStr(pBinMain);
            sInter = sigStr(pBinInter);

            if ~strcmp(sMain, 'ns')
                text(x1(area), fMain + 0.008, sMain, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', c * 0.7)
            end
            if ~strcmp(sInter, 'ns')
                text(x2(area), fInter + 0.008, sInter, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', c * 0.7)
            end

            % ── McNemar bracket between bars ──────────────────────────
            sMcN = sigStr(pMcNemar(area));
            if ~strcmp(sMcN, 'ns')
                yBracket = max(fMain, fInter) + 0.03;
                yMaxAll  = max(yMaxAll, yBracket + 0.03);

                line([x1(area) x1(area)], [fMain  yBracket], ...
                     'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                line([x2(area) x2(area)], [fInter yBracket], ...
                     'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                line([x1(area) x2(area)], [yBracket yBracket], ...
                     'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                text(mean([x1(area) x2(area)]), yBracket + 0.005, sMcN, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', [0.3 0.3 0.3])
            end

            yMaxAll = max(yMaxAll, max(fMain, fInter) + 0.05);
        end

        % ── Global chance line at p0 = 0.05 ──────────────────────────
        line([xLimLeft xLimRight], [p0 p0], ...
             'Color', [0.5 0.5 0.5], ...
             'LineStyle', '--', 'LineWidth', 0.8)

        % ── Legend ───────────────────────────────────────────────────
        hMain  = patch(NaN, NaN, [0.5 0.5 0.5], ...
                       'EdgeColor', 'none', ...
                       'DisplayName', mainLabel);
        hInter = patch(NaN, NaN, [0.8 0.8 0.8], ...
                       'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1.0, ...
                       'DisplayName', interLabel);
        legend([hMain hInter], 'Location', 'northeast', ...
               'FontSize', 8, 'Box', 'off')

        % ── Axes ─────────────────────────────────────────────────────
        yLimTop = max(yMaxAll, 0.4);
        xlim([xLimLeft xLimRight])
        ylim([0 yLimTop])
        yticks(0:0.05:yLimTop)

        set(gca, 'XTick',      xTick, ...
                 'XTickLabel', areaLabels, ...
                 'TickDir',    'out', ...
                 'FontSize',   8, ...
                 'Box',        'off')

        ylabel('Fraction of neurons', 'FontSize', 9)
        title(figTitle, 'FontSize', 10)
        box off
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 10 — Make figures
% ══════════════════════════════════════════════════════════════════════
makePlot(fracMainV, fracInterV, fracBothV, pMcNemarV, ...
         'Value only (main effect)', ...
         'Value × MSyst only (interaction)', ...
         'Value coding — peak fractions')

makePlot(fracMainO, fracInterO, fracBothO, pMcNemarO, ...
         'Outcome only (main effect)', ...
         'Outcome × MSyst only (interaction)', ...
         'Outcome coding — peak fractions')

fprintf('\nDone.\n')
end

function computeAndPlotSustainedFractions_v4(AllPSessions, predictorNames, ...
    areaLabels, TimeUsed, Colors, tStart, tEnd)
% computeAndPlotSustainedFractions_v4
%
% Computes sustained coding fractions using non-overlapping 250ms bins.
% Runs all possible starting positions (dsStart = 1:5) and classifies a
% neuron as sustained-coding if it passes the consecutive-bin criterion
% in ANY starting position (union). Each pass already requires 500ms of
% sustained coding (2 consecutive non-overlapping bins).
%
% Inputs:
%   AllPSessions    - 1xN cell, each nNeurons x nBins x nAreas p-value matrix
%   predictorNames  - 1xN cell of predictor names
%   areaLabels      - 1x8 cell
%   TimeUsed        - 1xnBins time vector in ms
%   Colors          - 8x3 color matrix
%   tStart          - window start in ms
%   tEnd            - window end in ms

% ══════════════════════════════════════════════════════════════════════
% PARAMETERS
% ══════════════════════════════════════════════════════════════════════
alpha    = 0.05;
nConsec  = 2;      % minimum consecutive non-overlapping significant bins
dsStep   = 5;      % downsample step — every 5th bin = non-overlapping 250ms
nStarts  = dsStep;  % number of starting positions

nAreas = length(areaLabels);

fprintf('=== computeAndPlotSustainedFractions_v4 ===\n')
fprintf('Window: %.0f to %.0f ms\n', tStart, tEnd)
fprintf('Union across %d starting positions\n', nStarts)

% ══════════════════════════════════════════════════════════════════════
% STEP 1 — Find time bins within window
% ══════════════════════════════════════════════════════════════════════
binWin = find(TimeUsed >= tStart & TimeUsed <= tEnd);
if isempty(binWin)
    error('No bins in window [%d %d] ms', tStart, tEnd)
end
fprintf('Bins in window: %d (%.0f to %.0f ms)\n', ...
    length(binWin), TimeUsed(binWin(1)), TimeUsed(binWin(end)))

% ══════════════════════════════════════════════════════════════════════
% STEP 2 — Get neuron counts from NaN structure
% ══════════════════════════════════════════════════════════════════════
refMat   = AllPSessions{1,1};
nNeurons = zeros(1, nAreas);
for area = 1:nAreas
    tmp            = squeeze(refMat(:,1,area));
    nNeurons(area) = sum(~isnan(tmp));
end

fprintf('\nNeurons per area:\n')
for area = 1:nAreas
    fprintf('  %s: %d\n', areaLabels{area}, nNeurons(area))
end

% ══════════════════════════════════════════════════════════════════════
% STEP 3 — Find predictor indices
% ══════════════════════════════════════════════════════════════════════
idxValue        = find(strcmp(predictorNames, 'Value'));
idxValueMSyst   = find(strcmp(predictorNames, 'ValueMSyst'));
idxOutcome      = find(strcmp(predictorNames, 'Outcome'));
idxOutcomeMSyst = find(strcmp(predictorNames, 'OutcomeMSyst'));

if any([isempty(idxValue), isempty(idxValueMSyst), ...
        isempty(idxOutcome), isempty(idxOutcomeMSyst)])
    error('Could not find required predictor names. Check predictorNames.')
end

% ══════════════════════════════════════════════════════════════════════
% STEP 4 — Helper functions
% ══════════════════════════════════════════════════════════════════════

hasConsecRun = @(sigMat, n) any( ...
    conv2(double(sigMat), ones(1,n), 'valid') >= n, 2);

    function prob = prob_at_least_one_run(T, n, p)
        if T < n
            prob = 0;
            return
        end
        q = 1 - p;
        A = zeros(n+1, n+1);
        for s = 0:n-1
            A(s+1, s+2) = p;
            A(s+1, 1)   = q;
        end
        A(n+1, n+1) = 1;
        v0 = zeros(1, n+1);
        v0(1) = 1;
        vT   = v0 * (A^T);
        prob = vT(n+1);
    end

    function str = sigStr(p)
        if p < 0.001;      str = '***';
        elseif p < 0.01;   str = '**';
        elseif p < 0.05;   str = '*';
        else;              str = 'ns';
        end
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 5 — Compute fractions (union across dsStarts)
% ══════════════════════════════════════════════════════════════════════
    function [fracMain, fracInter, fracBoth, fracNeither, ...
              chanceLevel, pMcNemar, nMain, nInter, nBothOut, nNeitherOut] = ...
              computePair(idxMain, idxInter)

        pMain_full  = AllPSessions{1, idxMain};
        pInter_full = AllPSessions{1, idxInter};

        fracMain    = nan(1, nAreas);
        fracInter   = nan(1, nAreas);
        fracBoth    = nan(1, nAreas);
        fracNeither = nan(1, nAreas);
        chanceLevel = nan(1, nAreas);
        pMcNemar    = nan(1, nAreas);
        nMain       = nan(1, nAreas);
        nInter      = nan(1, nAreas);
        nBothOut    = nan(1, nAreas);
        nNeitherOut = nan(1, nAreas);

        for area = 1:nAreas
            nReal = nNeurons(area);
            if nReal == 0; continue; end

            pM = squeeze(pMain_full( :,:,area));
            pI = squeeze(pInter_full(:,:,area));
            pM = pM(1:nReal, :);
            pI = pI(1:nReal, :);

            % Restrict to window
            pMw = pM(:, binWin);
            pIw = pI(:, binWin);

            % Remove NaN bins
            validBins = ~isnan(pMw(1,:)) & ~isnan(pIw(1,:));
            pMw = pMw(:, validBins);
            pIw = pIw(:, validBins);
            nValid = size(pMw, 2);

            % ── Union across all starting positions ───────────────────
            mainAny  = false(nReal, 1);
            interAny = false(nReal, 1);
            nValidDS = 0;
            medianT  = 0;

            for ds = 1:nStarts
                localIdx = 1:nValid;
                dsMask   = mod(localIdx - ds, dsStep) == 0;
                pMds     = pMw(:, dsMask);
                pIds     = pIw(:, dsMask);
                Tds      = size(pMds, 2);

                if Tds < nConsec
                    continue
                end
                nValidDS = nValidDS + 1;
                medianT  = medianT + Tds;

                sigM = pMds < alpha;
                sigI = pIds < alpha;

                mainAny  = mainAny  | hasConsecRun(sigM, nConsec);
                interAny = interAny | hasConsecRun(sigI, nConsec);
            end

            if nValidDS == 0
                fprintf('  Warning: no valid dsStarts for area %s — skipping\n', ...
                    areaLabels{area})
                continue
            end

            medianT = round(medianT / nValidDS);

            fprintf('  Area %s: %d valid dsStarts, ~%d bins each\n', ...
                areaLabels{area}, nValidDS, medianT)

            % ── Exclusive categories ──────────────────────────────────
            nMainOnly  = sum( mainAny & ~interAny);
            nInterOnly = sum(~mainAny &  interAny);
            nBothC     = sum( mainAny &  interAny);
            nNeitherC  = sum(~mainAny & ~interAny);

            fracMain(area)    = nMainOnly  / nReal;
            fracInter(area)   = nInterOnly / nReal;
            fracBoth(area)    = nBothC     / nReal;
            fracNeither(area) = nNeitherC  / nReal;

            nMain(area)       = nMainOnly;
            nInter(area)      = nInterOnly;
            nBothOut(area)    = nBothC;
            nNeitherOut(area) = nNeitherC;

            % ── Chance level (union across nValidDS independent tests) ─
            p_run_single       = prob_at_least_one_run(medianT, nConsec, alpha);
            chanceLevel(area)  = 1 - (1 - p_run_single)^nValidDS;

            % ── McNemar test ──────────────────────────────────────────
            b = nMainOnly;
            c = nInterOnly;
            if (b + c) > 0
                mcnemar_stat   = (b - c)^2 / (b + c);
                pMcNemar(area) = 1 - chi2cdf(mcnemar_stat, 1);
            else
                pMcNemar(area) = 1;
            end
        end
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 6 — Compute for Value and Outcome pairs
% ══════════════════════════════════════════════════════════════════════
fprintf('\n--- Value pair ---\n')
[fracMainV, fracInterV, fracBothV, fracNeitherV, ...
 chanceLevelV, pMcNemarV, nMainV, nInterV, nBothV, nNeitherV] = ...
    computePair(idxValue, idxValueMSyst);

fprintf('\n--- Outcome pair ---\n')
[fracMainO, fracInterO, fracBothO, fracNeitherO, ...
 chanceLevelO, pMcNemarO, nMainO, nInterO, nBothO, nNeitherO] = ...
    computePair(idxOutcome, idxOutcomeMSyst);

% ══════════════════════════════════════════════════════════════════════
% STEP 7 — Print summary tables
% ══════════════════════════════════════════════════════════════════════
fprintf('\n=== VALUE SUMMARY ===\n')
fprintf('%10s %6s %8s %8s %8s %8s %8s %8s %8s %10s\n', ...
    'Area','N','nMain','nInter','nBoth','nNeith','fMain','fInter','chance','McNemar')
for area = 1:nAreas
    fprintf('%10s %6d %8.0f %8.0f %8.0f %8.0f %8.3f %8.3f %8.4f %10s\n', ...
        areaLabels{area}, nNeurons(area), ...
        nMainV(area), nInterV(area), nBothV(area), nNeitherV(area), ...
        fracMainV(area), fracInterV(area), chanceLevelV(area), ...
        sigStr(pMcNemarV(area)))
end

fprintf('\n=== OUTCOME SUMMARY ===\n')
fprintf('%10s %6s %8s %8s %8s %8s %8s %8s %8s %10s\n', ...
    'Area','N','nMain','nInter','nBoth','nNeith','fMain','fInter','chance','McNemar')
for area = 1:nAreas
    fprintf('%10s %6d %8.0f %8.0f %8.0f %8.0f %8.3f %8.3f %8.4f %10s\n', ...
        areaLabels{area}, nNeurons(area), ...
        nMainO(area), nInterO(area), nBothO(area), nNeitherO(area), ...
        fracMainO(area), fracInterO(area), chanceLevelO(area), ...
        sigStr(pMcNemarO(area)))
end

% ══════════════════════════════════════════════════════════════════════
% STEP 8 — Bar positions
% ══════════════════════════════════════════════════════════════════════
barW     = 0.1;
barGap   = 0.05;
groupGap = 0.1;

groupWidth = 2*barW + barGap;
groupPos   = (0:nAreas-1) * (groupWidth + groupGap);

x1    = groupPos;
x2    = groupPos + barW + barGap;
xTick = mean([x1; x2], 1);

xLimLeft  = x1(1)   - barW;
xLimRight = x2(end) + barW;

% ══════════════════════════════════════════════════════════════════════
% STEP 9 — Plot function
% ══════════════════════════════════════════════════════════════════════
    function makePlot(fracMain, fracInter, fracBoth, ...
                      chanceLevel, pMcNemar, ...
                      mainLabel, interLabel, figTitle)

        figure('Position', [100 100 300 150])
        hold on

        yMaxAll = 0;

        for area = 1:nAreas
            c      = Colors(area,:);
            cLight = min(c + 0.35, 1);
            n      = nNeurons(area);

            fMain  = fracMain(area);
            fInter = fracInter(area);

            if isnan(fMain) || isnan(fInter)
                continue
            end

            % ── Bars ─────────────────────────────────────────────────
            bar(x1(area), fMain, barW, ...
                'FaceColor', c, 'EdgeColor', 'none')
            bar(x2(area), fInter, barW, ...
                'FaceColor', cLight, 'EdgeColor', c, 'LineWidth', 1.0)

            % ── Binomial test against chance ──────────────────────────
            ch = chanceLevel(area);
            if isnan(ch); ch = alpha; end

            kMain  = round(fMain  * n);
            kInter = round(fInter * n);

            pMain  = 1 - binocdf(max(kMain  - 1, 0), n, ch);
            pInter = 1 - binocdf(max(kInter - 1, 0), n, ch);

            sMain  = sigStr(pMain);
            sInter = sigStr(pInter);

            yStarMain  = fMain  + 0.008;
            yStarInter = fInter + 0.008;

            if ~strcmp(sMain, 'ns')
                text(x1(area), yStarMain, sMain, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', c * 0.7)
            end
            if ~strcmp(sInter, 'ns')
                text(x2(area), yStarInter, sInter, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', c * 0.7)
            end

            % ── McNemar bracket ───────────────────────────────────────
            sMcN = sigStr(pMcNemar(area));
            if ~strcmp(sMcN, 'ns')
                yBracket = max(fMain, fInter) + 0.025;
                yMaxAll  = max(yMaxAll, yBracket + 0.03);

                line([x1(area) x1(area)], [fMain  yBracket], ...
                     'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                line([x2(area) x2(area)], [fInter yBracket], ...
                     'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                line([x1(area) x2(area)], [yBracket yBracket], ...
                     'Color', [0.4 0.4 0.4], 'LineWidth', 0.7)
                text(mean([x1(area) x2(area)]), yBracket + 0.005, sMcN, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 6.5, 'Color', [0.3 0.3 0.3])
            end

            yMaxAll = max(yMaxAll, max(fMain, fInter) + 0.04);
        end

        % ── Chance line ───────────────────────────────────────────────
        meanChance = nanmean(chanceLevel);
        line([xLimLeft xLimRight], [meanChance meanChance], ...
             'Color', [0.5 0.5 0.5], ...
             'LineStyle', '--', 'LineWidth', 0.8)
        text(xLimRight + 0.1, meanChance, ...
             sprintf('chance=%.4f', meanChance), ...
             'FontSize', 7, 'Color', [0.5 0.5 0.5], ...
             'VerticalAlignment', 'middle')

        % ── Legend ───────────────────────────────────────────────────
        hMain  = patch(NaN, NaN, [0.5 0.5 0.5], ...
                       'EdgeColor', 'none', ...
                       'DisplayName', mainLabel);
        hInter = patch(NaN, NaN, [0.8 0.8 0.8], ...
                       'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1.0, ...
                       'DisplayName', interLabel);
        legend([hMain hInter], 'Location', 'northeast', ...
               'FontSize', 8, 'Box', 'off')

        % ── Axes ─────────────────────────────────────────────────────
        yLimTop = max(yMaxAll, 0.35);
        xlim([xLimLeft xLimRight])
        ylim([0 .3])

        set(gca, 'XTick',      xTick, ...
                 'XTickLabel', areaLabels, ...
                 'TickDir',    'out', ...
                 'FontSize',   8, ...
                 'Box',        'off')

        ylabel('Fraction of neurons', 'FontSize', 9)
        title(figTitle, 'FontSize', 10)
        box off
    end

% ══════════════════════════════════════════════════════════════════════
% STEP 10 — Make figures
% ══════════════════════════════════════════════════════════════════════
makePlot(fracMainV, fracInterV, fracBothV, ...
         chanceLevelV, pMcNemarV, ...
         'Value (abstracted)', ...
         'Value \times MotorSystem (embodied)', ...
         'Value coding — sustained fractions')

makePlot(fracMainO, fracInterO, fracBothO, ...
         chanceLevelO, pMcNemarO, ...
         'Outcome (abstracted)', ...
         'Outcome \times MotorSystem (embodied)', ...
         'Outcome coding — sustained fractions')

% ══════════════════════════════════════════════════════════════════════
% STEP 11 — Across-area paired tests (embodied vs abstracted)
% ══════════════════════════════════════════════════════════════════════
validAreas = ~isnan(fracMainV) & ~isnan(fracInterV);
nValid = sum(validAreas);
fprintf('\n=== VALUE: Across-area comparison ===\n')
fprintf('Mean embodied:   %.3f +- %.3f (SEM)\n', ...
    mean(fracInterV(validAreas)), std(fracInterV(validAreas))/sqrt(nValid))
fprintf('Mean abstracted: %.3f +- %.3f (SEM)\n', ...
    mean(fracMainV(validAreas)), std(fracMainV(validAreas))/sqrt(nValid))
[~, pT, ~, sT] = ttest(fracInterV(validAreas), fracMainV(validAreas));
[pW, ~, ~] = signrank(fracInterV(validAreas), fracMainV(validAreas));
fprintf('Paired t-test:         t(%d) = %.3f, p = %.4f\n', sT.df, sT.tstat, pT)
fprintf('Wilcoxon signed-rank:  p = %.4f\n', pW)
fprintf('\nPer-area McNemar (embodied vs abstracted):\n')
fprintf('%10s %8s %8s %10s %8s\n', 'Area', 'Abstr', 'Embod', 'McNemar p', 'sig')
for area = 1:nAreas
    if isnan(pMcNemarV(area)); continue; end
    fprintf('%10s %8.0f %8.0f %10.4f %8s\n', ...
        areaLabels{area}, nMainV(area), nInterV(area), ...
        pMcNemarV(area), sigStr(pMcNemarV(area)))
end

validAreas = ~isnan(fracMainO) & ~isnan(fracInterO);
nValid = sum(validAreas);
fprintf('\n=== OUTCOME: Across-area comparison ===\n')
fprintf('Mean embodied:   %.3f +- %.3f (SEM)\n', ...
    mean(fracInterO(validAreas)), std(fracInterO(validAreas))/sqrt(nValid))
fprintf('Mean abstracted: %.3f +- %.3f (SEM)\n', ...
    mean(fracMainO(validAreas)), std(fracMainO(validAreas))/sqrt(nValid))
[~, pT, ~, sT] = ttest(fracInterO(validAreas), fracMainO(validAreas));
[pW, ~, ~] = signrank(fracInterO(validAreas), fracMainO(validAreas));
fprintf('Paired t-test:         t(%d) = %.3f, p = %.4f\n', sT.df, sT.tstat, pT)
fprintf('Wilcoxon signed-rank:  p = %.4f\n', pW)
fprintf('\nPer-area McNemar (embodied vs abstracted):\n')
fprintf('%10s %8s %8s %10s %8s\n', 'Area', 'Abstr', 'Embod', 'McNemar p', 'sig')
for area = 1:nAreas
    if isnan(pMcNemarO(area)); continue; end
    fprintf('%10s %8.0f %8.0f %10.4f %8s\n', ...
        areaLabels{area}, nMainO(area), nInterO(area), ...
        pMcNemarO(area), sigStr(pMcNemarO(area)))
end
% ══════════════════════════════════════════════════════════════════════
% STEP 12 — Two-way ANOVA: coding type × area (linear model)
% ══════════════════════════════════════════════════════════════════════

% --- Value ---
validV = ~isnan(fracMainV) & ~isnan(fracInterV);
fracV  = [fracMainV(validV), fracInterV(validV)];
areaF  = [find(validV), find(validV)];
typeF  = [ones(1, sum(validV)), 2*ones(1, sum(validV))];

fprintf('\n=== VALUE: Two-way ANOVA (coding type + area) ===\n')
[pValV, tblV] = anovan(fracV(:), {typeF(:), areaF(:)}, ...
    'model', 'linear', ...
    'varnames', {'CodingType', 'Area'}, ...
    'display', 'off');
fprintf('Main effect CodingType: F(%d,%d) = %.3f, p = %.4f\n', ...
    tblV{2,3}, tblV{4,3}, tblV{2,6}, pValV(1))
fprintf('Main effect Area:       F(%d,%d) = %.3f, p = %.4f\n', ...
    tblV{3,3}, tblV{4,3}, tblV{3,6}, pValV(2))
% --- Outcome ---
validO = ~isnan(fracMainO) & ~isnan(fracInterO);
fracO  = [fracMainO(validO), fracInterO(validO)];
areaFO = [find(validO), find(validO)];
typeFO = [ones(1, sum(validO)), 2*ones(1, sum(validO))];

fprintf('\n=== OUTCOME: Two-way ANOVA (coding type + area) ===\n')
tblO  = {};
pValO = [];
[pValO, tblO] = anovan(fracO(:), {typeFO(:), areaFO(:)}, ...
    'model', 'linear', ...
    'varnames', {'CodingType', 'Area'}, ...
    'display', 'off');
fprintf('Main effect CodingType: F(%d,%d) = %.3f, p = %.4f\n', ...
    tblO{2,3}, tblO{4,3}, tblO{2,6}, pValO(1))
fprintf('Main effect Area:       F(%d,%d) = %.3f, p = %.4f\n', ...
    tblO{3,3}, tblO{4,3}, tblO{3,6}, pValO(2))
fprintf('\nDone.\n')
end
