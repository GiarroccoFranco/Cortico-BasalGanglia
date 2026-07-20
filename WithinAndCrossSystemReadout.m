clearvars, clc
close all
cd('C:\Users\giarroccof2\OneDrive - National Institutes of Health\Franco\NeuralData\') ;
Sessions = importdata('RecordingSessionsM1M2_Final.txt');
Folder=cd('C:\Users\giarroccof2\OneDrive - National Institutes of Health\Franco\NeuralData\') ;


Test='TestPumpy2_';
Year='2022';

Sessions2Anal=1:length(Sessions);

Ortgn  =  nan(length(Sessions),2,8);

All_Dim          =  nan (100, 4, 8,length(Sessions));
All_Vectors      =  nan (100, 4, 8,length(Sessions));
Significant_Neuron     =  nan (100, 4, 8,length(Sessions));

Shared_Neuron     =  nan (100, 4, 8,length(Sessions));


for nSession= Sessions2Anal
    % for  nSession= Sessions2Anal

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
        SessionData=[];
    load SessionData_StimOn_250_50.mat;
    SessionData = SessionData_StimOn_250_50;

    load SessionStimValues.mat


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

   
    
    n_bin=SessionData.Times;
    TimeUsed=SessionData.Times;
    TimeIdx=ismember(SessionData.Times,n_bin);
    TimeStamp=find(TimeIdx==1);

    [ PMd,   PFC,   dCd, dPut ,VS_Cd, VS_Put, GPi, Amy, numberofsess ]=GetElectrodesLocation_BothMonkeys(nSession );

 

    Alltrials=1:length(Reward);
   


    TrialsToAnalize=Alltrials;  %% HandTrials NovelTrialsEye EyeTrials NovelTrialsHand  FamiliarTrials Familiar_IDX_Eye Familiar_IDX_Hand




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




    zero_dir=find(Directions==0);
    Directions(zero_dir)=-1;


    if nSession <33

        X_nested_e = [Directions(NovelTrialsEye)' , Value(NovelTrialsEye),Reward(NovelTrialsEye)',ImageIDs(NovelTrialsEye)', TrialsMarkers.RTs(NovelTrialsEye)'];
        X_nested_a = [Directions(NovelTrialsHand)' , Value(NovelTrialsHand),Reward(NovelTrialsHand)',ImageIDs(NovelTrialsHand)',TrialsMarkers.RTs(NovelTrialsHand)'];


        St_V_Eye   =   Value(NovelTrialsEye)  ;

        St_V_Arm   =   Value(NovelTrialsHand)  ;
 
    elseif nSession >32


        X_nested_e = [Directions(NovelTrialsEye)' , Value(NovelTrialsEye)',Reward(NovelTrialsEye)',ImageIDs(NovelTrialsEye)', TrialsMarkers.RTs(NovelTrialsEye)'];
        X_nested_a = [Directions(NovelTrialsHand)' , Value(NovelTrialsHand)',Reward(NovelTrialsHand)',ImageIDs(NovelTrialsHand)',TrialsMarkers.RTs(NovelTrialsHand)'];
        St_V_Eye   =   Value(NovelTrialsEye)'   ;

        St_V_Arm   =   Value(NovelTrialsHand)'  ;



    end



    SV_Eye_index = ones(size(St_V_Eye,1),1)*2;

    SV_Arm_index = ones(size(St_V_Arm,1),1)*2;

   
 % Percentile thresholds

    % Eye
    stim_p33_Eye = prctile(St_V_Eye, 33);
    stim_p66_Eye = prctile(St_V_Eye, 66);


    % Low / High groups (middle values ignored)
    Eye_StimLow  = find(St_V_Eye <= stim_p33_Eye);
    Eye_StimHigh = find(St_V_Eye >= stim_p66_Eye);


    % Arm
    stim_p33_Arm = prctile(St_V_Arm, 33);
    stim_p66_Arm = prctile(St_V_Arm, 66);



    % Low / High groups (middle values ignored)
    Arm_StimLow  = find(St_V_Arm <= stim_p33_Arm);
    Arm_StimHigh = find(St_V_Arm >= stim_p66_Arm);

   
    SV_Eye_index (Eye_StimLow)=1;     SV_Eye_index (Eye_StimHigh)=3;

    
    SV_Arm_index (Arm_StimLow)=1;     SV_Arm_index (Arm_StimHigh)=3;

    
    Eyelabels{1,nSession}= [  Directions(NovelTrialsEye)'  SV_Eye_index    All_Trials_WithinBlock(NovelTrialsEye)'                ]  ;
    Armlabels{1,nSession}= [  Directions(NovelTrialsHand)' SV_Arm_index   All_Trials_WithinBlock(NovelTrialsHand)'               ]  ;

    Proj_B_AV_Arm=nan(length(NovelTrialsHand), length(TimeStamp), 8 );
    Proj_B_SV_Arm =nan(length(NovelTrialsHand), length(TimeStamp), 8 );
    Proj_B_Dir_Arm =nan(length(NovelTrialsHand), length(TimeStamp), 8 );

    Proj_B_AV_Eye=nan(length(NovelTrialsEye), length(TimeStamp), 8 );
    Proj_B_SV_Eye =nan(length(NovelTrialsEye), length(TimeStamp), 8 );
    Proj_B_Dir_Eye =nan(length(NovelTrialsEye), length(TimeStamp), 8 );

    Proj_2_B_AV_Arm=nan(length(NovelTrialsHand), length(TimeStamp), 8 );
    Proj_2_B_SV_Arm =nan(length(NovelTrialsHand), length(TimeStamp), 8 );
    Proj_2_B_Dir_Arm =nan(length(NovelTrialsHand), length(TimeStamp), 8 );

    Proj_2_B_AV_Eye=nan(length(NovelTrialsEye), length(TimeStamp), 8 );
    Proj_2_B_SV_Eye =nan(length(NovelTrialsEye), length(TimeStamp), 8 );
    Proj_2_B_Dir_Eye =nan(length(NovelTrialsEye), length(TimeStamp), 8 );


    for REG =  1:size(data,2)

        DataMat=data{1,REG};

        if isempty(DataMat)
            nneurons(nSession,REG)=0;
        elseif ~isempty(DataMat)
            nneurons(nSession,REG)=size(DataMat,3);



            BetaDir_Eye=[]; BetaSV_Eye=[]; BetaAV_Eye=[];  Beta_NF_Eye=[]; Beta_Tr_Eye=[];
            BetaDir_Arm=[]; BetaSV_Arm=[]; BetaAV_Arm=[];  Beta_NF_Arm=[]; Beta_Tr_Arm=[];

            pDir_Eye=[]; pSV_Eye=[]; pAV_Eye=[];
            pDir_Arm=[]; pSV_Arm=[]; pAV_Arm=[];




            for   neu=1:size(DataMat,3)
                parfor bin=1:size(DataMat,2)

                    Bdir=[];  Bdir=[]; Bsarsa=[];

                                        B_Eye = fitlm(X_nested_e,DataMat(NovelTrialsEye,bin,neu),'linear' ,"CategoricalVars", [1 3 ]);
                                        B_Arm = fitlm(X_nested_a,DataMat(NovelTrialsHand,bin,neu),'linear' ,"CategoricalVars", [1 3 ]);

                    BetaDir_Eye(neu,bin)=B_Eye.Coefficients{2,1};
                    BetaSV_Eye(neu,bin)=B_Eye.Coefficients{3,1};
                    BetaAV_Eye(neu,bin)=B_Eye.Coefficients{4,1};

                    pDir_Eye(neu,bin)=B_Eye.Coefficients{2,4};
                    pSV_Eye(neu,bin)=B_Eye.Coefficients{3,4};
                    pAV_Eye(neu,bin)=B_Eye.Coefficients{4,4};

                    BetaDir_Arm(neu,bin)=B_Arm.Coefficients{2,1};
                    BetaSV_Arm(neu,bin)=B_Arm.Coefficients{3,1};
                    BetaAV_Arm(neu,bin)=B_Arm.Coefficients{4,1};

                    pDir_Arm(neu,bin)=B_Arm.Coefficients{2,4};
                    pSV_Arm(neu,bin)=B_Arm.Coefficients{3,4};
                    pAV_Arm(neu,bin)=B_Arm.Coefficients{4,4};


                



                end
            end



            Norm_Dir_Eye=vecnorm(BetaDir_Eye);
            bin_BetaDir_Eye=find(Norm_Dir_Eye==max(Norm_Dir_Eye));
            Beta_VectorDir_Eye=BetaDir_Eye(:,bin_BetaDir_Eye(1));


            Norm_SV_Eye=vecnorm(BetaSV_Eye);
            bin_BetaSV_Eye=find(Norm_SV_Eye==max(Norm_SV_Eye));
            Beta_VectorSV_Eye=BetaSV_Eye(:,bin_BetaSV_Eye(1));

            Norm_AV_Eye=vecnorm(BetaAV_Eye);
            bin_BetaAV_Eye=find(Norm_AV_Eye==max(Norm_AV_Eye));
            Beta_VectorAV_Eye=BetaAV_Eye(:,bin_BetaAV_Eye(1));

            Norm_Dir_Arm=vecnorm(BetaDir_Arm);
            bin_BetaDir_Arm=find(Norm_Dir_Arm==max(Norm_Dir_Arm));
            Beta_VectorDir_Arm=BetaDir_Arm(:,bin_BetaDir_Arm(1));

            Norm_SV_Arm=vecnorm(BetaSV_Arm);
            bin_BetaSV_Arm=find(Norm_SV_Arm==max(Norm_SV_Arm));
            Beta_VectorSV_Arm=BetaSV_Arm(:,bin_BetaSV_Arm(1));

            Norm_AV_Arm=vecnorm(BetaAV_Arm);
            bin_BetaAV_Arm=find(Norm_AV_Arm==max(Norm_AV_Arm));
            Beta_VectorAV_Arm=BetaAV_Arm(:,bin_BetaAV_Arm(1));



            All_Vectors(1:size(Beta_VectorDir_Eye,1),1,REG,nSession) = Beta_VectorDir_Eye;
            All_Vectors(1:size(Beta_VectorSV_Eye,1),2,REG,nSession) = Beta_VectorSV_Eye;

            All_Vectors(1:size(Beta_VectorDir_Arm,1),3,REG,nSession) = Beta_VectorDir_Arm;
            All_Vectors(1:size(Beta_VectorSV_Arm,1),4,REG,nSession) = Beta_VectorSV_Arm;






            Beta_VectorDir_Eye=Beta_VectorDir_Eye/norm(Beta_VectorDir_Eye);
            Beta_VectorSV_Eye=Beta_VectorSV_Eye/norm(Beta_VectorSV_Eye);
            Beta_VectorDir_Arm=Beta_VectorDir_Arm/norm(Beta_VectorDir_Arm);
            Beta_VectorSV_Arm=Beta_VectorSV_Arm/norm(Beta_VectorSV_Arm);



            Ortgn(nSession,1,REG)  =  dot(Beta_VectorDir_Arm,Beta_VectorDir_Eye);
            Ortgn(nSession,2,REG)  =  dot(Beta_VectorSV_Arm,Beta_VectorSV_Eye);

            All_Dim(1:size(Beta_VectorDir_Eye,1),1,REG,nSession) = Beta_VectorDir_Eye;
            All_Dim(1:size(Beta_VectorSV_Eye,1),2,REG,nSession) = Beta_VectorSV_Eye;
            All_Dim(1:size(Beta_VectorDir_Arm,1),3,REG,nSession) = Beta_VectorDir_Arm;
            All_Dim(1:size(Beta_VectorSV_Arm,1),4,REG,nSession) = Beta_VectorSV_Arm;


            Significant_Neuron ( find(pDir_Eye(:,bin_BetaDir_Eye(1))<.05), 1, REG,nSession)=1;
            Significant_Neuron ( find(pSV_Eye(:,bin_BetaSV_Eye(1))<.05), 2, REG,nSession)=1;
            Significant_Neuron ( find(pDir_Arm(:,bin_BetaDir_Arm(1))<.05), 3, REG,nSession)=1;
            Significant_Neuron ( find(pSV_Arm(:,bin_BetaSV_Arm(1))<.05), 4, REG,nSession)=1;


            %-----------  Choice DIRECTION
            PermData=[]; PermData=permute(DataMat, [3 2 1]);
            for     Trial_Beta=1:length(NovelTrialsEye)
                for tb=1:size (PermData,2)
                    Proj_B_Dir_Eye(Trial_Beta,tb,REG)=dot(PermData(:,tb,NovelTrialsEye(Trial_Beta)),Beta_VectorDir_Eye);
                end
            end
            for     Trial_Beta=1:length(NovelTrialsHand)
                for tb=1:size (PermData,2)
                    Proj_B_Dir_Arm(Trial_Beta,tb,REG)=dot(PermData(:,tb,NovelTrialsHand(Trial_Beta)),Beta_VectorDir_Arm);
                end
            end

            %-----------  STIMULUS VALUE
            PermData=[]; PermData=permute(DataMat, [3 2 1]);
            for     Trial_Beta=1:length(NovelTrialsEye)
                for tb=1:size (PermData,2)
                    Proj_B_SV_Eye(Trial_Beta,tb,REG)=dot(PermData(:,tb,NovelTrialsEye(Trial_Beta)),Beta_VectorSV_Eye);
                end
            end
            for     Trial_Beta=1:length(NovelTrialsHand)
                for tb=1:size (PermData,2)
                    Proj_B_SV_Arm(Trial_Beta,tb,REG)=dot(PermData(:,tb,NovelTrialsHand(Trial_Beta)),Beta_VectorSV_Arm);
                end
            end




            % ===============================    PROJECTION OF ACTIVITY ONTO OTHER MOTOR SYSTEM DIMENSIONS

            %-----------  Choice DIRECTION 2
            PermData=[]; PermData=permute(DataMat, [3 2 1]);
            for     Trial_Beta=1:length(NovelTrialsEye)
                for tb=1:size (PermData,2)
                    Proj_2_B_Dir_Eye(Trial_Beta,tb,REG)=dot(PermData(:,tb,NovelTrialsEye(Trial_Beta)),Beta_VectorDir_Arm);
                end
            end
            
            for     Trial_Beta=1:length(NovelTrialsHand)
                for tb=1:size (PermData,2)
                    Proj_2_B_Dir_Arm(Trial_Beta,tb,REG)=dot(PermData(:,tb,NovelTrialsHand(Trial_Beta)),Beta_VectorDir_Eye);
                end
            end

            %-----------  STIMULUS VALUE 2
            PermData=[]; PermData=permute(DataMat, [3 2 1]);
            for     Trial_Beta=1:length(NovelTrialsEye)
                for tb=1:size (PermData,2)
                    Proj_2_B_SV_Eye(Trial_Beta,tb,REG)=dot(PermData(:,tb,NovelTrialsEye(Trial_Beta)),Beta_VectorSV_Arm);
                end
            end
            for     Trial_Beta=1:length(NovelTrialsHand)
                for tb=1:size (PermData,2)
                    Proj_2_B_SV_Arm(Trial_Beta,tb,REG)=dot(PermData(:,tb,NovelTrialsHand(Trial_Beta)),Beta_VectorSV_Eye);
                end
            end

   


        end
    end




    Proj_B_SV_Arm_Sess{1,nSession}    =   Proj_B_SV_Arm ;
    Proj_B_Dir_Arm_Sess{1,nSession}   =   Proj_B_Dir_Arm;


    Proj_B_SV_Eye_Sess{1,nSession}    =   Proj_B_SV_Eye ;
    Proj_B_Dir_Eye_Sess{1,nSession}   =   Proj_B_Dir_Eye;



    Proj_2_B_SV_Arm_Sess{1,nSession}    =   Proj_2_B_SV_Arm ;
    Proj_2_B_Dir_Arm_Sess{1,nSession}   =   Proj_2_B_Dir_Arm;


    Proj_2_B_SV_Eye_Sess{1,nSession}    =   Proj_2_B_SV_Eye ;
    Proj_2_B_Dir_Eye_Sess{1,nSession}   =   Proj_2_B_Dir_Eye;











end  %% cicle for Sessions






areaLabels = {
    'PMd'
    'vlPFC'
    'Put'
    'Cd'
    'lVS'
    'mVS'
    'GPi'
    'Amy'
    };

keyboard


%%
nSessions = size(nneurons,1);

% Session labels with monkey identity
sessionLabels = strings(nSessions,1);
for s = 1:nSessions
    if s <= 32
        sessionLabels(s) = sprintf('%d (MP)', s);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
    else
        sessionLabels(s) = sprintf('%d (ML)', s);
    end
end

% Create table
T = array2table(nneurons, 'VariableNames', areaLabels);

% Convert neuron counts to strings and blank zeros
for a = 1:numel(areaLabels)
    col = T{:,a};
    strcol = strings(size(col));
    strcol(col > 0) = string(col(col > 0));
    strcol(col == 0) = "";   % blank instead of 0
    T.(areaLabels{a}) = strcol;
end

% Add session column
T.Session = sessionLabels;
T = movevars(T,'Session','Before',1);

% Export
% writetable(T,'SuppTable1.xlsx');






%%


% All_Dim is 100 × 6 × 8 × 50
%  All_Vectors is 100 × 6 × 8 × 50
D_2_use = All_Vectors;
[nNeurons, nCond, nAreas, nSess] = size(D_2_use);

% New total neurons
newN = nNeurons * nSess;

% Preallocate
All_Dim_concat = nan(newN, nCond, nAreas);

rowStart = 1;

for s = 1:nSess
    block = D_2_use(:,:,:,s);    % size = 100 × 6 × 8
    SignBlock =Significant_Neuron(:,:,:,s);

    All_Dim_concat(rowStart : rowStart + nNeurons - 1, :, :) = block;
    Sign_Neurons_concat(rowStart : rowStart + nNeurons - 1, :, :) = SignBlock;

    rowStart = rowStart + nNeurons;

end


[nNeurons, nCond, nAreas] = size(All_Dim_concat);

%% This is to use all neurons (next there is a code that computes it for significant neurons only)
nBoot = 1000;   % number of bootstrap iterations
angleBoot = nan(nAreas, 2, nBoot);  % areas × variable-pairs × bootstrap

for ar = 1:nAreas

    % Extract (neurons × 6)
    M = All_Dim_concat(:,:,ar);

    % Remove NaN rows
    validRows = ~isnan(M(:,1));
    Mclean = M(validRows, :);

    nNeurons = size(Mclean,1);

    for b = 1:nBoot

        % --- Bootstrap neurons (with replacement)
        idx = randi(nNeurons, nNeurons, 1);
        Mb = Mclean(idx, :);

        % --- Normalize columns
        for c = 1:4
            colNorm = norm(Mb(:,c));
            if colNorm > 0
                Mb(:,c) = Mb(:,c) / colNorm;
            end
        end

        % --- Dot products
        d13 = dot(Mb(:,1), Mb(:,3));
        d24 = dot(Mb(:,2), Mb(:,4));
%         d36 = dot(Mb(:,3), Mb(:,6));

        % --- Convert to angles
        theta = acosd([d13, d24]);

        % --- Enforce [0, 90] inside bootstrap
        angleBoot(ar,:,b) = min(theta, 180 - theta);
    end
end
angleMean = mean(angleBoot, 3);
angleStd  = std(angleBoot, [], 3);

angleCI_low  = prctile(angleBoot,  2.5, 3);
angleCI_high = prctile(angleBoot, 97.5, 3);

 xl = 1:8;
figure('Color','w','Position',[200 200 800 230]);

titles = {'Choice Direction','Obj Value'};
for vr = 1:2
   subplot (1,3,vr)
  errorbar(xl, angleMean(:,vr), angleStd(:,vr), 'k', 'LineWidth', 1, 'CapSize', 10,'LineStyle','none'); hold on

   
    plot(xl, angleMean(:,vr), 'o', 'MarkerFaceColor', 'k', 'MarkerSize', 6,'MarkerEdgeColor','k');

    xlim([0.5 nAreas+0.5]);
    ylim([0 100]);


 
    line([0 10], [90 90], "LineStyle",":", "LineWidth",0.5, "Color",'k');

    xticks(xl);
    xticklabels(areaLabels);
    ylabel('Angle (degrees)');
    yticks = [0:30:90];

set(gca, ...
    'YTick', yticks, ...
    'TickDir','out', ...
    'FontSize',8);

axis square
grid off
    title(titles{vr}, 'FontSize', 10,'FontWeight','normal');
end
  
% clear gcf
%   f = gcf; 
%             exportgraphics(f, 'Angle_All_NeuralPopulation.pdf', 'Resolution', 500);
%% ... for significant neurons only
nBoot = 1000;

angleBoot_Sign = nan(nAreas, 2, nBoot);  % areas × variable-pairs × bootstrap

for ar = 1:nAreas

    % Extract matrices
    M = All_Dim_concat(:,:,ar);        % N × 4
    N = Sign_Neurons_concat(:,:,ar);   % N × 4

    % Coding neuron indices
    Cod_neurons_1 = union(find(N(:,1)==1), find(N(:,3)==1));
    Cod_neurons_2 = union(find(N(:,2)==1), find(N(:,4)==1));
%     Cod_neurons_3 = union(find(N(:,3)==1), find(N(:,6)==1));

    for b = 1:nBoot

        % -------- Pair 1–3
        idx1 = Cod_neurons_1(randi(numel(Cod_neurons_1), numel(Cod_neurons_1), 1));
        v1  = M(idx1,1);
        v3  = M(idx1,3);

        if norm(v1)>0 && norm(v3)>0
            v1 = v1 / norm(v1);
            v3 = v3 / norm(v3);
            d13 = dot(v1,v3);
        else
            d13 = NaN;
        end

        % -------- Pair 2-4
        idx2 = Cod_neurons_2(randi(numel(Cod_neurons_2), numel(Cod_neurons_2), 1));
        v2  = M(idx2,2);
        v4  = M(idx2,4);

        if norm(v2)>0 && norm(v4)>0
            v2 = v2 / norm(v2);
            v4 = v4 / norm(v4);
            d24 = dot(v2,v4);
        else
            d24 = NaN;
        end

        % -------- Pair 3–6
%         idx3 = Cod_neurons_3(randi(numel(Cod_neurons_3), numel(Cod_neurons_3), 1));
%         v3  = M(idx3,3);
%         v6  = M(idx3,6);
% 
%         if norm(v3)>0 && norm(v6)>0
%             v3 = v3 / norm(v3);
%             v6 = v6 / norm(v6);
% %             d36 = dot(v3,v6);
%         else
% %             d36 = NaN;
%         end

        % Convert to angles and enforce [0,90]
        theta = acosd([d13 d24 ]);
        angleBoot_Sign(ar,:,b) = min(theta, 180-theta);
    end
end


angleMean_Sign = mean(angleBoot_Sign, 3, 'omitnan');
angleStd_Sign  = std(angleBoot_Sign, [], 3, 'omitnan');

angleCI_Sign(:,:,1) = prctile(angleBoot_Sign,  2.5, 3);
angleCI_Sign(:,:,2) = prctile(angleBoot_Sign, 97.5, 3);

 xl = 1:8;
figure('Color','w','Position',[200 200 800 230]);

titles = {'Choice Direction','Obj Value'};
for vr = 1:2
   subplot (1,3,vr)
  errorbar(xl, angleMean_Sign(:,vr), angleStd_Sign(:,vr), 'k', 'LineWidth', 1, 'CapSize', 10,'LineStyle','none'); hold on

   
    plot(xl, angleMean_Sign(:,vr), 'o', 'MarkerFaceColor', 'k', 'MarkerSize', 6,'MarkerEdgeColor','k');

   xlim([0.5 nAreas+0.5]);
    ylim([0 100]);


 
    line([0 10], [90 90], "LineStyle",":", "LineWidth",0.5, "Color",'k');

    xticks(xl);
    xticklabels(areaLabels);
    ylabel('Angle (degrees)');
    yticks = [0:30:90];

set(gca, ...
    'YTick', yticks, ...
    'TickDir','out', ...
    'FontSize',8);

axis square
grid off
    title(titles{vr}, 'FontSize', 10,'FontWeight','normal');
end
%   
% clear gcf
%   f = gcf; 
%             exportgraphics(f, 'Angle_All_NeuralPopulation_SignNeuron.pdf', 'Resolution', 500);


%%

%% ... for significant "SHARED" neurons 
nBoot = 1000;

angleBoot_Sign = nan(nAreas, 2, nBoot);  % areas × variable-pairs × bootstrap

for ar = 1:nAreas

    % Extract matrices
    M = All_Dim_concat(:,:,ar);        % N × 6
    N = Sign_Neurons_concat(:,:,ar);   % N × 6

    % Coding neuron indices
    Cod_neurons_1 = intersect(find(N(:,1)==1), find(N(:,3)==1));
    Cod_neurons_2 = intersect(find(N(:,2)==1), find(N(:,2)==1));
%     Cod_neurons_3 = intersect(find(N(:,3)==1), find(N(:,6)==1));

    for b = 1:nBoot

        % -------- Pair 1–3
        idx1 = Cod_neurons_1(randi(numel(Cod_neurons_1), numel(Cod_neurons_1), 1));
        v1  = M(idx1,1);
        v3  = M(idx1,3);

        if norm(v1)>0 && norm(v3)>0
            v1 = v1 / norm(v1);
            v3 = v3 / norm(v3);
            d13 = dot(v1,v3);
        else
            d13 = NaN;
        end

        % -------- Pair 2–4
        idx2 = Cod_neurons_2(randi(numel(Cod_neurons_2), numel(Cod_neurons_2), 1));
        v2  = M(idx2,2);
        v4  = M(idx2,4);

        if norm(v2)>0 && norm(v4)>0
            v2 = v2 / norm(v2);
            v4 = v4 / norm(v4);
            d24 = dot(v2,v4);
        else
            d24 = NaN;
        end

        % -------- Pair 3–6
%         idx3 = Cod_neurons_3(randi(numel(Cod_neurons_3), numel(Cod_neurons_3), 1));
%         v3  = M(idx3,3);
%         v6  = M(idx3,6);
% 
%         if norm(v3)>0 && norm(v6)>0
%             v3 = v3 / norm(v3);
%             v6 = v6 / norm(v6);
% %             d36 = dot(v3,v6);
% %         else
% %             d36 = NaN;
%         end

        % Convert to angles and enforce [0,90]
        theta = acosd([d13 d24 ]);
        angleBoot_Sign(ar,:,b) = min(theta, 180-theta);
    end
end


angleMean_Sign = mean(angleBoot_Sign, 3, 'omitnan');
angleStd_Sign  = std(angleBoot_Sign, [], 3, 'omitnan');

angleCI_Sign(:,:,1) = prctile(angleBoot_Sign,  2.5, 3);
angleCI_Sign(:,:,2) = prctile(angleBoot_Sign, 97.5, 3);

 xl = 1:8;
figure('Color','w','Position',[200 200 800 230]);

titles = {'Choice Direction','Obj Value'};
for vr = 1:2
   subplot (1,3,vr)
  errorbar(xl, angleMean_Sign(:,vr), angleStd_Sign(:,vr), 'k', 'LineWidth', 1, 'CapSize', 10,'LineStyle','none'); hold on

   
    plot(xl, angleMean_Sign(:,vr), 'o', 'MarkerFaceColor', 'k', 'MarkerSize', 6,'MarkerEdgeColor','k');

 
   xlim([0.5 nAreas+0.5]);
   ylim([0 100]);


 
    line([0 10], [90 90], "LineStyle",":", "LineWidth",0.5, "Color",'k');

    xticks(xl);
    xticklabels(areaLabels);
    ylabel('Angle (degrees)');
    yticks = [0:30:90];

set(gca, ...
    'YTick', yticks, ...
    'TickDir','out', ...
    'FontSize',8);

axis square
grid off
    title(titles{vr}, 'FontSize', 10,'FontWeight','normal');
end
%   
% clear gcf
%   f = gcf; 
%             exportgraphics(f, 'Angle_All_NeuralPopulation_SharedNeuron.pdf', 'Resolution', 500);



%% ------------------- PLOT angles
xl = 1:8;

% variables order: 1 = CD, 2 = AV, 3 = SV
% Ortgn(:,2)=[];
[nSessions, nVars, nAreas] = size(Ortgn);
MeanAngles = nan(nVars, nAreas);   % 3 x 8
SEMAngles  = nan(nVars, nAreas);   % 3 x 8

Angles_all = nan(nSessions, nVars, nAreas); %
Angles_all_unfolded= nan(nSessions, nVars, nAreas); %
for ar = 1:nAreas
    for v = 1:nVars
        % ---- Dot products
        dots = Ortgn(:, v, ar);        % 50 x 1
        valid = ~isnan(dots);
        if ~any(valid)
            continue;
        end
        dots_clamped = min(max(dots(valid), -1), 1);   % safer — acosd needs [-1,1]

        % ---- Convert to angle, then fold to [0, 90] ----
        theta_raw    = acosd(dots_clamped);             % 0–180
        theta_folded = min(theta_raw, 180 - theta_raw); % 0–90

        % ---- Store per-session (folded) ----
        ang_tmp = nan(nSessions, 1);
        ang_tmp(valid) = theta_folded;
        Angles_all(:, v, ar) = ang_tmp;
        AngleUnfoldValid= nan(nSessions, 1);
        AngleUnfoldValid (valid)=theta_raw;
        Angles_all_unfolded(:, v, ar) = AngleUnfoldValid;

        % ---- Mean and SEM across sessions (both on folded) ----
        MeanAngles(v, ar) = mean(theta_folded);
        SEMAngles(v, ar)  = std(theta_folded) / sqrt(numel(theta_folded));
    end
end

FliplAngles=min(MeanAngles, 180-MeanAngles);
% PLOT: 3 subplots (CD, AV, SV)

titles = {'Choice Direction','Obj Value'};

figure('Color','w','Position',[200 200 800 230]);

for v = 1:nVars

    subplot(1,3,v); hold on;

    mu  = FliplAngles(v,:);   % 1 x 8
    sem = SEMAngles(v,:);    % 1 x 8

    % Use your area labels
    x = 1:nAreas;

    % Error bars
    errorbar(x, mu, sem, 'k', 'LineWidth', 1, 'CapSize', 10,'LineStyle','none');

    % Points
    plot(x, mu, 'o', 'MarkerFaceColor', 'k', 'MarkerSize', 6,'MarkerEdgeColor','k');

    xlim([0.5 nAreas+0.5]);
    ylim([0 100]);


 
    line([0 10], [90 90], "LineStyle",":", "LineWidth",0.5, "Color",'k');

    xticks(xl);
    xticklabels(areaLabels);
    ylabel('Angle (degrees)');
    yticks = [0:30:90];

set(gca, ...
    'YTick', yticks, ...
    'TickDir','out', ...
    'FontSize',8);

axis square
grid off
title(titles{v}, 'FontSize', 10,'FontWeight','normal');

end

%     f = gcf; 
%             exportgraphics(f, 'Angle_All_Neurons_SingleSessions.pdf', 'Resolution', 500);
%%
% %% ------------------- PLOT angles 2 (signle across sessions)
% 
% [nSessions, nVars, nAreas] = size(Ortgn);
% 
% % variables order: 1 = CD, 2 = AV, 3 = SV
%  MeanCosine=nanmean(Ortgn,1);
% %  MeanAngle = acosd(ffrg);
% 
% titles = {'Choice Direction','Action Value','Stimulus Value'};
% 
% figure('Color','w','Position',[200 200 800 230]);
% 
% for ai = 1: nAreas
% 
% areavar =[]; areavar = Ortgn(:,:,ai);
% 
% areavar_valid = []; areavar_valid = areavar(~isnan(areavar(:,1)),:);
% 
% for nsa = 1: size(areavar_valid,1)
% 
% areavar_valid_4_test= areavar_valid;
% areavar_valid_4_test(nsa,:)=[];
% mean_areavar_valid_4_test(nsa,:)=acosd(nanmean(areavar_valid_4_test,1));
% 
% 
% 
% end
% 
% 
% 
% mean_area_angles(ai,:) = nanmean(mean_areavar_valid_4_test,1) ; 
% SEM_area_angles(ai,:)  = std (mean_areavar_valid_4_test);
% 
% %
% 
% end
% 
% 
% 
% titles = {'Choice Direction','Action Value','Stimulus Value'};
% x = 1:8;
% figure('Color','w','Position',[200 200 800 230]);
% 
% for variablen = 1:2 
% subplot (1,3,variablen)
%     % Error bars
%     errorbar(x, mean_area_angles(:,variablen), SEM_area_angles(:,variablen), 'k', 'LineWidth', 1, 'CapSize', 10,'LineStyle','none'); hold on
% 
%     % Points
%     plot(x, mean_area_angles(:,variablen), 'o', 'MarkerFaceColor', 'k', 'MarkerSize', 6,'MarkerEdgeColor','k');
% 
%     xlim([0.5 nAreas+0.5]);
%     ylim([0 100]);
% 
%     %
% %     yticks(0:30:90);
% %     yticklabels(0:30:90);
% 
%     %  90°
%     line([0 10], [90 90], "LineStyle",":", "LineWidth",0.5, "Color",'k');
% 
%     xticks(x);
%     xticklabels(areaLabels);
%     ylabel('Angle (degrees)');
%     title(titles{v}, 'FontSize', 14,'FontWeight','normal');
% 
% 
% end
%%
ns = length(Eyelabels);


for ss= 1:ns
Eyelabels{1,ss}(:,5)=ss;
Armlabels{1,ss}(:,5)=ss;
end


allLabelEye = [];

allLabelArm = [];


for s = 1:ns
    M_Eye = Eyelabels{s};   % nTrials × 2
    if ~isempty(M_Eye)
        allLabelEye = [allLabelEye; M_Eye];   % vertical concatenation
    end

    M_Arm = Armlabels{s};   % nTrials × 2
    if ~isempty(M_Arm)
        allLabelArm = [allLabelArm; M_Arm];   % vertical concatenation
    end
end




%% ============================================================
% CONCATENAZIONE DI TUTTI I PROJ_*_Sess  →  Proj_*_All
% STESSO IDENTICO STILE DEL TUO SCRIPT
% ============================================================

% ===== PROJ_B_AV_ARM =====
% nSess = numel(Proj_B_AV_Arm_Sess);
% totalTrials = sum(cellfun(@(x) size(x,1), Proj_B_AV_Arm_Sess));
% [~, nTime, nAreas] = size(Proj_B_AV_Arm_Sess{1});
% 
% Proj_1_B_AV_Arm_All = nan(totalTrials, nTime, nAreas);
% rowStart = 1;
% 
% for s = 1:nSess
%     M = Proj_B_AV_Arm_Sess{s};
%     t = size(M,1);
%     Proj_1_B_AV_Arm_All(rowStart:rowStart+t-1,:,:) = M;
%     rowStart = rowStart + t;
% end
% 

% ===== PROJ_B_SV_ARM =====
nSess = numel(Proj_B_SV_Arm_Sess);
totalTrials = sum(cellfun(@(x) size(x,1), Proj_B_SV_Arm_Sess));
[~, nTime, nAreas] = size(Proj_B_SV_Arm_Sess{1});

Proj_1_B_SV_Arm_All = nan(totalTrials, nTime, nAreas);
rowStart = 1;

for s = 1:nSess
    M = Proj_B_SV_Arm_Sess{s};
    t = size(M,1);
    Proj_1_B_SV_Arm_All(rowStart:rowStart+t-1,:,:) = M;
    rowStart = rowStart + t;
end


% ===== PROJ_B_DIR_ARM =====
nSess = numel(Proj_B_Dir_Arm_Sess);
totalTrials = sum(cellfun(@(x) size(x,1), Proj_B_Dir_Arm_Sess));
[~, nTime, nAreas] = size(Proj_B_Dir_Arm_Sess{1});

Proj_1_B_Dir_Arm_All = nan(totalTrials, nTime, nAreas);
rowStart = 1;

for s = 1:nSess
    M = Proj_B_Dir_Arm_Sess{s};
    t = size(M,1);
    Proj_1_B_Dir_Arm_All(rowStart:rowStart+t-1,:,:) = M;
    rowStart = rowStart + t;
end

% 
% % ===== PROJ_B_AV_EYE =====
% nSess = numel(Proj_B_AV_Eye_Sess);
% totalTrials = sum(cellfun(@(x) size(x,1), Proj_B_AV_Eye_Sess));
% [~, nTime, nAreas] = size(Proj_B_AV_Eye_Sess{1});
% 
% Proj_1_B_AV_Eye_All = nan(totalTrials, nTime, nAreas);
% rowStart = 1;
% 
% for s = 1:nSess
%     M = Proj_B_AV_Eye_Sess{s};
%     t = size(M,1);
%     Proj_1_B_AV_Eye_All(rowStart:rowStart+t-1,:,:) = M;
%     rowStart = rowStart + t;
% end


% ===== PROJ_B_SV_EYE =====
nSess = numel(Proj_B_SV_Eye_Sess);
totalTrials = sum(cellfun(@(x) size(x,1), Proj_B_SV_Eye_Sess));
[~, nTime, nAreas] = size(Proj_B_SV_Eye_Sess{1});

Proj_1_B_SV_Eye_All = nan(totalTrials, nTime, nAreas);
rowStart = 1;

for s = 1:nSess
    M = Proj_B_SV_Eye_Sess{s};
    t = size(M,1);
    Proj_1_B_SV_Eye_All(rowStart:rowStart+t-1,:,:) = M;
    rowStart = rowStart + t;
end


% ===== PROJ_B_DIR_EYE =====
nSess = numel(Proj_B_Dir_Eye_Sess);
totalTrials = sum(cellfun(@(x) size(x,1), Proj_B_Dir_Eye_Sess));
[~, nTime, nAreas] = size(Proj_B_Dir_Eye_Sess{1});

Proj_1_B_Dir_Eye_All = nan(totalTrials, nTime, nAreas);
rowStart = 1;

for s = 1:nSess
    M = Proj_B_Dir_Eye_Sess{s};
    t = size(M,1);
    Proj_1_B_Dir_Eye_All(rowStart:rowStart+t-1,:,:) = M;
    rowStart = rowStart + t;
end

% --------- For projecting onto the other motor-system dimension
% nSess = numel(Proj_2_B_SV_Arm_Sess);
% totalTrials = sum(cellfun(@(x) size(x,1), Proj_2_B_SV_Arm_Sess));
% [~, nTime, nAreas] = size(Proj_2_B_SV_Arm_Sess{1});
% 
% Proj_2_B_AV_Arm_All = nan(totalTrials, nTime, nAreas);
% rowStart = 1;
% 
% for s = 1:nSess
%     M = Proj_2_B_AV_Arm_Sess{s};
%     t = size(M,1);
%     Proj_2_B_AV_Arm_All(rowStart:rowStart+t-1,:,:) = M;
%     rowStart = rowStart + t;
% end


% ===== Proj_2_B_SV_ARM =====
nSess = numel(Proj_2_B_SV_Arm_Sess);
totalTrials = sum(cellfun(@(x) size(x,1), Proj_2_B_SV_Arm_Sess));
[~, nTime, nAreas] = size(Proj_2_B_SV_Arm_Sess{1});

Proj_2_B_SV_Arm_All = nan(totalTrials, nTime, nAreas);
rowStart = 1;

for s = 1:nSess
    M = Proj_2_B_SV_Arm_Sess{s};
    t = size(M,1);
    Proj_2_B_SV_Arm_All(rowStart:rowStart+t-1,:,:) = M;
    rowStart = rowStart + t;
end


% ===== Proj_2_B_DIR_ARM =====
nSess = numel(Proj_2_B_Dir_Arm_Sess);
totalTrials = sum(cellfun(@(x) size(x,1), Proj_2_B_Dir_Arm_Sess));
[~, nTime, nAreas] = size(Proj_2_B_Dir_Arm_Sess{1});

Proj_2_B_Dir_Arm_All = nan(totalTrials, nTime, nAreas);
rowStart = 1;

for s = 1:nSess
    M = Proj_2_B_Dir_Arm_Sess{s};
    t = size(M,1);
    Proj_2_B_Dir_Arm_All(rowStart:rowStart+t-1,:,:) = M;
    rowStart = rowStart + t;
end


% % ===== Proj_2_B_AV_EYE =====
% nSess = numel(Proj_2_B_AV_Eye_Sess);
% totalTrials = sum(cellfun(@(x) size(x,1), Proj_2_B_AV_Eye_Sess));
% [~, nTime, nAreas] = size(Proj_2_B_AV_Eye_Sess{1});
% 
% Proj_2_B_AV_Eye_All = nan(totalTrials, nTime, nAreas);
% rowStart = 1;
% 
% for s = 1:nSess
%     M = Proj_2_B_AV_Eye_Sess{s};
%     t = size(M,1);
%     Proj_2_B_AV_Eye_All(rowStart:rowStart+t-1,:,:) = M;
%     rowStart = rowStart + t;
% end


% ===== Proj_2_B_SV_EYE =====
nSess = numel(Proj_2_B_SV_Eye_Sess);
totalTrials = sum(cellfun(@(x) size(x,1), Proj_2_B_SV_Eye_Sess));
[~, nTime, nAreas] = size(Proj_2_B_SV_Eye_Sess{1});

Proj_2_B_SV_Eye_All = nan(totalTrials, nTime, nAreas);
rowStart = 1;

for s = 1:nSess
    M = Proj_2_B_SV_Eye_Sess{s};
    t = size(M,1);
    Proj_2_B_SV_Eye_All(rowStart:rowStart+t-1,:,:) = M;
    rowStart = rowStart + t;
end


% ===== Proj_2_B_DIR_EYE =====
nSess = numel(Proj_2_B_Dir_Eye_Sess);
totalTrials = sum(cellfun(@(x) size(x,1), Proj_2_B_Dir_Eye_Sess));
[~, nTime, nAreas] = size(Proj_2_B_Dir_Eye_Sess{1});

Proj_2_B_Dir_Eye_All = nan(totalTrials, nTime, nAreas);
rowStart = 1;

for s = 1:nSess
    M = Proj_2_B_Dir_Eye_Sess{s};
    t = size(M,1);
    Proj_2_B_Dir_Eye_All(rowStart:rowStart+t-1,:,:) = M;
    rowStart = rowStart + t;
end

%%



%% ============================ Define TRIALS LABELS
%  INPUT:
%    allLabelEye  = [nEyeTrials x 4]
%    allLabelArm  = [nArmTrials x 4]
%    Col 1 = choice direction (-1 left, 1 right)
%    Col 2 = stimulus value
%    Col 3 = action value
% =============================

%% ---------- Helper function ----------
getTrialGroups = @(M) struct( ...
    'Left',  find(M(:,1) == -1), ...
    'Right', find(M(:,1) == 1),  ...
    'StimLow', find(M(:,2) == 1), 'StimHigh', find(M(:,2) == 3), ...
    'Session', []...
    );

% ============================
%  PROCESS EYE TRIALS
% ============================
Eye = getTrialGroups(allLabelEye);

% Percentile thresholds


Eye.Session =  allLabelEye(:,5);

% ============================
%  PROCESS ARM TRIALS
% ============================
Arm = getTrialGroups(allLabelArm);

% Percentile thresholds


Arm.Session =  allLabelArm(:,5);
 

% %% For ACTION VALUE vs. Choice Direction
% %
% %
% % Arm
% % Action Value-SAME; Choice Dir-SAME
% CD_AV_Arm_Low_Left_1   (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Arm_All(intersect(Arm.ActLow,Arm.Left),:,:)),'gaussian',1);
% CD_AV_Arm_High_Left_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Arm_All(intersect(Arm.ActHigh,Arm.Left),:,:)),'gaussian',1);
% CD_AV_Arm_Low_Right_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Arm_All(intersect(Arm.ActLow,Arm.Right),:,:)),'gaussian',1);
% CD_AV_Arm_High_Right_1 (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Arm_All(intersect(Arm.ActHigh,Arm.Right),:,:)),'gaussian',1);
% 
% AV_CD_Arm_Low_Left_1   (:,:,:)    = smoothdata(  nanmean(Proj_1_B_AV_Arm_All(intersect(Arm.ActLow,Arm.Left),:,:)),'gaussian',1);
% AV_CD_Arm_High_Left_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_AV_Arm_All(intersect(Arm.ActHigh,Arm.Left),:,:)),'gaussian',1);
% AV_CD_Arm_Low_Right_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_AV_Arm_All(intersect(Arm.ActLow,Arm.Right),:,:)),'gaussian',1);
% AV_CD_Arm_High_Right_1 (:,:,:)    = smoothdata(  nanmean(Proj_1_B_AV_Arm_All(intersect(Arm.ActHigh,Arm.Right),:,:)),'gaussian',1);
% 
% % figure,
% % plot(AV_CD_Arm_Low_Left_1(:,:,1),'k');hold on
% % plot(AV_CD_Arm_High_Left_1(:,:,1),'b');hold on
% % plot(AV_CD_Arm_Low_Right_1(:,:,1),'y');hold on
% % plot(AV_CD_Arm_High_Right_1(:,:,1),'c');hold on
% 
% % Action Value-OTHER; Choice Dir-OTHER
% 
% CD_AV_Arm_Low_Left_2   (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Arm_All(intersect(Arm.ActLow,Arm.Left),:,:)),'gaussian',1);
% CD_AV_Arm_High_Left_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Arm_All(intersect(Arm.ActHigh,Arm.Left),:,:)),'gaussian',1);
% CD_AV_Arm_Low_Right_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Arm_All(intersect(Arm.ActLow,Arm.Right),:,:)),'gaussian',1);
% CD_AV_Arm_High_Right_2 (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Arm_All(intersect(Arm.ActHigh,Arm.Right),:,:)),'gaussian',1);
% 
% AV_CD_Arm_Low_Left_2   (:,:,:)    = smoothdata(  nanmean(Proj_2_B_AV_Arm_All(intersect(Arm.ActLow,Arm.Left),:,:)),'gaussian',1);
% AV_CD_Arm_High_Left_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_AV_Arm_All(intersect(Arm.ActHigh,Arm.Left),:,:)),'gaussian',1);
% AV_CD_Arm_Low_Right_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_AV_Arm_All(intersect(Arm.ActLow,Arm.Right),:,:)),'gaussian',1);
% AV_CD_Arm_High_Right_2 (:,:,:)    = smoothdata(  nanmean(Proj_2_B_AV_Arm_All(intersect(Arm.ActHigh,Arm.Right),:,:)),'gaussian',1);
% 
% % Eye
% % Action Value-SAME; Choice Dir-SAME
% CD_AV_Eye_Low_Left_1   (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Eye_All(intersect(Eye.ActLow,Eye.Left),:,:)),'gaussian',1);
% CD_AV_Eye_High_Left_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Eye_All(intersect(Eye.ActHigh,Eye.Left),:,:)),'gaussian',1);
% CD_AV_Eye_Low_Right_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Eye_All(intersect(Eye.ActLow,Eye.Right),:,:)),'gaussian',1);
% CD_AV_Eye_High_Right_1 (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Eye_All(intersect(Eye.ActHigh,Eye.Right),:,:)),'gaussian',1);
% 
% AV_CD_Eye_Low_Left_1   (:,:,:)    = smoothdata(  nanmean(Proj_1_B_AV_Eye_All(intersect(Eye.ActLow,Eye.Left),:,:)),'gaussian',1);
% AV_CD_Eye_High_Left_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_AV_Eye_All(intersect(Eye.ActHigh,Eye.Left),:,:)),'gaussian',1);
% AV_CD_Eye_Low_Right_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_AV_Eye_All(intersect(Eye.ActLow,Eye.Right),:,:)),'gaussian',1);
% AV_CD_Eye_High_Right_1 (:,:,:)    = smoothdata(  nanmean(Proj_1_B_AV_Eye_All(intersect(Eye.ActHigh,Eye.Right),:,:)),'gaussian',1);
% 
% 
% % Action Value-OTHER; Choice Dir-OTHER
% 
% CD_AV_Eye_Low_Left_2   (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Eye_All(intersect(Eye.ActLow,Eye.Left),:,:)),'gaussian',1);
% CD_AV_Eye_High_Left_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Eye_All(intersect(Eye.ActHigh,Eye.Left),:,:)),'gaussian',1);
% CD_AV_Eye_Low_Right_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Eye_All(intersect(Eye.ActLow,Eye.Right),:,:)),'gaussian',1);
% CD_AV_Eye_High_Right_2 (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Eye_All(intersect(Eye.ActHigh,Eye.Right),:,:)),'gaussian',1);
% 
% AV_CD_Eye_Low_Left_2   (:,:,:)    = smoothdata(  nanmean(Proj_2_B_AV_Eye_All(intersect(Eye.ActLow,Eye.Left),:,:)),'gaussian',1);
% AV_CD_Eye_High_Left_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_AV_Eye_All(intersect(Eye.ActHigh,Eye.Left),:,:)),'gaussian',1);
% AV_CD_Eye_Low_Right_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_AV_Eye_All(intersect(Eye.ActLow,Eye.Right),:,:)),'gaussian',1);
% AV_CD_Eye_High_Right_2 (:,:,:)    = smoothdata(  nanmean(Proj_2_B_AV_Eye_All(intersect(Eye.ActHigh,Eye.Right),:,:)),'gaussian',1);
% 



%% For STIMULUS VALUE vs. Choice Direction
% Arm
% Stimulus Value-SAME; Choice Dir-SAME
CD_SV_Arm_Low_Left_1   (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Arm_All(intersect(Arm.StimLow,Arm.Left),:,:)),'gaussian',1);
CD_SV_Arm_High_Left_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Arm_All(intersect(Arm.StimHigh,Arm.Left),:,:)),'gaussian',1);
CD_SV_Arm_Low_Right_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Arm_All(intersect(Arm.StimLow,Arm.Right),:,:)),'gaussian',1);
CD_SV_Arm_High_Right_1 (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Arm_All(intersect(Arm.StimHigh,Arm.Right),:,:)),'gaussian',1);

SV_CD_Arm_Low_Left_1   (:,:,:)    = smoothdata(  nanmean(Proj_1_B_SV_Arm_All(intersect(Arm.StimLow,Arm.Left),:,:)),'gaussian',1);
SV_CD_Arm_High_Left_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_SV_Arm_All(intersect(Arm.StimHigh,Arm.Left),:,:)),'gaussian',1);
SV_CD_Arm_Low_Right_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_SV_Arm_All(intersect(Arm.StimLow,Arm.Right),:,:)),'gaussian',1);
SV_CD_Arm_High_Right_1 (:,:,:)    = smoothdata(  nanmean(Proj_1_B_SV_Arm_All(intersect(Arm.StimHigh,Arm.Right),:,:)),'gaussian',1);


% Stimulus Value-OTHER; Choice Dir-OTHER

CD_SV_Arm_Low_Left_2   (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Arm_All(intersect(Arm.StimLow,Arm.Left),:,:)),'gaussian',1);
CD_SV_Arm_High_Left_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Arm_All(intersect(Arm.StimHigh,Arm.Left),:,:)),'gaussian',1);
CD_SV_Arm_Low_Right_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Arm_All(intersect(Arm.StimLow,Arm.Right),:,:)),'gaussian',1);
CD_SV_Arm_High_Right_2 (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Arm_All(intersect(Arm.StimHigh,Arm.Right),:,:)),'gaussian',1);

SV_CD_Arm_Low_Left_2   (:,:,:)    = smoothdata(  nanmean(Proj_2_B_SV_Arm_All(intersect(Arm.StimLow,Arm.Left),:,:)),'gaussian',1);
SV_CD_Arm_High_Left_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_SV_Arm_All(intersect(Arm.StimHigh,Arm.Left),:,:)),'gaussian',1);
SV_CD_Arm_Low_Right_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_SV_Arm_All(intersect(Arm.StimLow,Arm.Right),:,:)),'gaussian',1);
SV_CD_Arm_High_Right_2 (:,:,:)    = smoothdata(  nanmean(Proj_2_B_SV_Arm_All(intersect(Arm.StimHigh,Arm.Right),:,:)),'gaussian',1);

% Eye
% Stimulus Value-SAME; Choice Dir-SAME
CD_SV_Eye_Low_Left_1   (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Eye_All(intersect(Eye.StimLow,Eye.Left),:,:)),'gaussian',1);
CD_SV_Eye_High_Left_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Eye_All(intersect(Eye.StimHigh,Eye.Left),:,:)),'gaussian',1);
CD_SV_Eye_Low_Right_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Eye_All(intersect(Eye.StimLow,Eye.Right),:,:)),'gaussian',1);
CD_SV_Eye_High_Right_1 (:,:,:)    = smoothdata(  nanmean(Proj_1_B_Dir_Eye_All(intersect(Eye.StimHigh,Eye.Right),:,:)),'gaussian',1);

SV_CD_Eye_Low_Left_1   (:,:,:)    = smoothdata(  nanmean(Proj_1_B_SV_Eye_All(intersect(Eye.StimLow,Eye.Left),:,:)),'gaussian',1);
SV_CD_Eye_High_Left_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_SV_Eye_All(intersect(Eye.StimHigh,Eye.Left),:,:)),'gaussian',1);
SV_CD_Eye_Low_Right_1  (:,:,:)    = smoothdata(  nanmean(Proj_1_B_SV_Eye_All(intersect(Eye.StimLow,Eye.Right),:,:)),'gaussian',1);
SV_CD_Eye_High_Right_1 (:,:,:)    = smoothdata(  nanmean(Proj_1_B_SV_Eye_All(intersect(Eye.StimHigh,Eye.Right),:,:)),'gaussian',1);


% Stimulus Value-OTHER; Choice Dir-OTHER

CD_SV_Eye_Low_Left_2   (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Eye_All(intersect(Eye.StimLow,Eye.Left),:,:)),'gaussian',1);
CD_SV_Eye_High_Left_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Eye_All(intersect(Eye.StimHigh,Eye.Left),:,:)),'gaussian',1);
CD_SV_Eye_Low_Right_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Eye_All(intersect(Eye.StimLow,Eye.Right),:,:)),'gaussian',1);
CD_SV_Eye_High_Right_2 (:,:,:)    = smoothdata(  nanmean(Proj_2_B_Dir_Eye_All(intersect(Eye.StimHigh,Eye.Right),:,:)),'gaussian',1);

SV_CD_Eye_Low_Left_2   (:,:,:)    = smoothdata(  nanmean(Proj_2_B_SV_Eye_All(intersect(Eye.StimLow,Eye.Left),:,:)),'gaussian',1);
SV_CD_Eye_High_Left_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_SV_Eye_All(intersect(Eye.StimHigh,Eye.Left),:,:)),'gaussian',1);
SV_CD_Eye_Low_Right_2  (:,:,:)    = smoothdata(  nanmean(Proj_2_B_SV_Eye_All(intersect(Eye.StimLow,Eye.Right),:,:)),'gaussian',1);
SV_CD_Eye_High_Right_2 (:,:,:)    = smoothdata(  nanmean(Proj_2_B_SV_Eye_All(intersect(Eye.StimHigh,Eye.Right),:,:)),'gaussian',1);




%%

%
Eye_Color_Low   =  [ 0.976 0.318 0.176];
Eye_Color_High  =  [ 0.506 0.176 0.071];
Arm_Color_Low   =  [ 0.192 0.620 0.980];
Arm_Color_High  =  [ 0.016 0.212 0.396];

areaLabels = {
    'PMd'
    'PFC'
    'dPut'
    'dCd'
    'VS-put'
    'VS-cd'
    'GPi'
    'Amygdala'
    };

% FixHold  = 13 ;
FixHold    = 13 ;
CueON      = 25 ;
StimON     = 25 ;




%%
% FOR  VALUE

 for ar=1:8
     figure,



    subplot(2,4,3)


    plot(CD_SV_Arm_Low_Left_1(:,13:50,ar), SV_CD_Arm_Low_Left_1(:,13:50,ar),'LineStyle',':','LineWidth',2,'Color', Arm_Color_Low); hold on
    plot(CD_SV_Arm_Low_Right_1(:,13:50,ar), SV_CD_Arm_Low_Right_1(:,13:50,ar),'LineStyle','-','LineWidth',2,'Color', Arm_Color_Low); hold on

    plot(CD_SV_Arm_High_Left_1(:,13:50,ar), SV_CD_Arm_High_Left_1(:,13:50,ar),'LineStyle',':','LineWidth',2,'Color', Arm_Color_High); hold on
    plot(CD_SV_Arm_High_Right_1(:,13:50,ar), SV_CD_Arm_High_Right_1(:,13:50,ar),'LineStyle','-','LineWidth',2,'Color', Arm_Color_High); hold on

    plot(CD_SV_Arm_Low_Left_1(:,FixHold,ar), SV_CD_Arm_Low_Left_1(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]);hold on
    plot(CD_SV_Arm_Low_Left_1(:,CueON,ar), SV_CD_Arm_Low_Left_1(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
  


    plot(CD_SV_Arm_Low_Right_1(:,FixHold,ar), SV_CD_Arm_Low_Right_1(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    plot(CD_SV_Arm_Low_Right_1(:,CueON,ar), SV_CD_Arm_Low_Right_1(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
   

    plot(CD_SV_Arm_High_Left_1(:,FixHold,ar), SV_CD_Arm_High_Left_1(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    plot(CD_SV_Arm_High_Left_1(:,CueON,ar), SV_CD_Arm_High_Left_1(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
  

    plot(CD_SV_Arm_High_Right_1(:,FixHold,ar), SV_CD_Arm_High_Right_1(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    plot(CD_SV_Arm_High_Right_1(:,CueON,ar), SV_CD_Arm_High_Right_1(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
  
    xlabel ('Choice Direction')
    ylabel ('Stimulus Value')




    subplot(2,4,4)

    plot(CD_SV_Arm_Low_Left_1(:,13:50,ar), SV_CD_Arm_Low_Left_2(:,13:50,ar),'LineStyle',':','LineWidth',2,'Color', Arm_Color_Low); hold on
    plot(CD_SV_Arm_Low_Right_1(:,13:50,ar), SV_CD_Arm_Low_Right_2(:,13:50,ar),'LineStyle','-','LineWidth',2,'Color', Arm_Color_Low); hold on

    plot(CD_SV_Arm_High_Left_1(:,13:50,ar), SV_CD_Arm_High_Left_2(:,13:50,ar),'LineStyle',':','LineWidth',2,'Color', Arm_Color_High); hold on
    plot(CD_SV_Arm_High_Right_1(:,13:50,ar), SV_CD_Arm_High_Right_2(:,13:50,ar),'LineStyle','-','LineWidth',2,'Color', Arm_Color_High); hold on

    plot(CD_SV_Arm_Low_Left_1(:,FixHold,ar), SV_CD_Arm_Low_Left_2(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]);hold on
    plot(CD_SV_Arm_Low_Left_1(:,CueON,ar), SV_CD_Arm_Low_Left_2(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
   


    plot(CD_SV_Arm_Low_Right_1(:,FixHold,ar), SV_CD_Arm_Low_Right_2(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    plot(CD_SV_Arm_Low_Right_1(:,CueON,ar), SV_CD_Arm_Low_Right_2(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on

    plot(CD_SV_Arm_High_Left_1(:,FixHold,ar), SV_CD_Arm_High_Left_2(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    plot(CD_SV_Arm_High_Left_1(:,CueON,ar), SV_CD_Arm_High_Left_2(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
   

    plot(CD_SV_Arm_High_Right_1(:,FixHold,ar), SV_CD_Arm_High_Right_2(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    plot(CD_SV_Arm_High_Right_1(:,CueON,ar), SV_CD_Arm_High_Right_2(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
   
    xlabel ('Choice Direction')
    ylabel ('Stimulus Value')





    subplot(2,4,7)

    plot(CD_SV_Eye_Low_Left_1(:,13:50,ar), SV_CD_Eye_Low_Left_1(:,13:50,ar),'LineStyle',':','LineWidth',2,'Color', Eye_Color_Low); hold on
    plot(CD_SV_Eye_Low_Right_1(:,13:50,ar), SV_CD_Eye_Low_Right_1(:,13:50,ar),'LineStyle','-','LineWidth',2,'Color', Eye_Color_Low); hold on

    plot(CD_SV_Eye_High_Left_1(:,13:50,ar), SV_CD_Eye_High_Left_1(:,13:50,ar),'LineStyle',':','LineWidth',2,'Color', Eye_Color_High); hold on
    plot(CD_SV_Eye_High_Right_1(:,13:50,ar), SV_CD_Eye_High_Right_1(:,13:50,ar),'LineStyle','-','LineWidth',2,'Color', Eye_Color_High); hold on

    plot(CD_SV_Eye_Low_Left_1(:,FixHold,ar), SV_CD_Eye_Low_Left_1(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]);hold on
    plot(CD_SV_Eye_Low_Left_1(:,CueON,ar), SV_CD_Eye_Low_Left_1(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    


    plot(CD_SV_Eye_Low_Right_1(:,FixHold,ar), SV_CD_Eye_Low_Right_1(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    plot(CD_SV_Eye_Low_Right_1(:,CueON,ar), SV_CD_Eye_Low_Right_1(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on


    plot(CD_SV_Eye_High_Left_1(:,FixHold,ar), SV_CD_Eye_High_Left_1(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    plot(CD_SV_Eye_High_Left_1(:,CueON,ar), SV_CD_Eye_High_Left_1(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
   

    plot(CD_SV_Eye_High_Right_1(:,FixHold,ar), SV_CD_Eye_High_Right_1(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    plot(CD_SV_Eye_High_Right_1(:,CueON,ar), SV_CD_Eye_High_Right_1(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
   
    xlabel ('Choice Direction')
    ylabel ('Stimulus Value')



    subplot(2,4,8)

    plot(CD_SV_Eye_Low_Left_1(:,13:50,ar), SV_CD_Eye_Low_Left_2(:,13:50,ar),'LineStyle',':','LineWidth',2,'Color', Eye_Color_Low); hold on
    plot(CD_SV_Eye_Low_Right_1(:,13:50,ar), SV_CD_Eye_Low_Right_2(:,13:50,ar),'LineStyle','-','LineWidth',2,'Color', Eye_Color_Low); hold on

    plot(CD_SV_Eye_High_Left_1(:,13:50,ar), SV_CD_Eye_High_Left_2(:,13:50,ar),'LineStyle',':','LineWidth',2,'Color', Eye_Color_High); hold on
    plot(CD_SV_Eye_High_Right_1(:,13:50,ar), SV_CD_Eye_High_Right_2(:,13:50,ar),'LineStyle','-','LineWidth',2,'Color', Eye_Color_High); hold on

    plot(CD_SV_Eye_Low_Left_1(:,FixHold,ar), SV_CD_Eye_Low_Left_2(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]);hold on
    plot(CD_SV_Eye_Low_Left_1(:,CueON,ar), SV_CD_Eye_Low_Left_2(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
   

    plot(CD_SV_Eye_Low_Right_1(:,FixHold,ar), SV_CD_Eye_Low_Right_2(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    plot(CD_SV_Eye_Low_Right_1(:,CueON,ar), SV_CD_Eye_Low_Right_2(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
 
    plot(CD_SV_Eye_High_Left_1(:,FixHold,ar), SV_CD_Eye_High_Left_2(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    plot(CD_SV_Eye_High_Left_1(:,CueON,ar), SV_CD_Eye_High_Left_2(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    

    plot(CD_SV_Eye_High_Right_1(:,FixHold,ar), SV_CD_Eye_High_Right_2(:,FixHold,ar), 'd','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    plot(CD_SV_Eye_High_Right_1(:,CueON,ar), SV_CD_Eye_High_Right_2(:,CueON,ar), 's','Color',[255 104 31]/255,'MarkerSize',7,...
        'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7]); hold on
    
    xlabel ('Choice Direction')
    ylabel ('Stimulus Value')

 

    sgtitle(areaLabels{ar}, 'FontSize',15,'FontWeight',"Bold");

 end

