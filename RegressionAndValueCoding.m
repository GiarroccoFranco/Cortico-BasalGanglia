clearvars, clc
% close all
cd('insert the directory of the folder here') ;
Sessions = importdata('ExampleSession.txt');
Folder=cd('insert the directory of the folder here') ;


Test='TestPumpy2_';
Year='2022';



Sessions2Anal=1:length(Sessions);

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
for nSession= 1
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


    n_bin=SessionData.Times;
    TimeUsed=SessionData.Times;
    TimeIdx=ismember(SessionData.Times,n_bin);
    TimeStamp=find(TimeIdx==1);

    [ PMd,   PFC,   dCd, dPut ,VS_Cd, VS_Put, GPi, Amy, numberofsess ]=GetElectrodesLocation_BothMonkeys(nSession );

   

    Alltrials=1:length(Reward);

    ET=1:15; LT=16:30;
    Earlytrials=find(ismember(TrialsMarkers.TrialWithinBlock,ET)==1);
    Latetrials=find(ismember(TrialsMarkers.TrialWithinBlock,LT)==1);

    Early_Eye=intersect(NovelTrialsEye,Earlytrials);
    Early_Arm=intersect(NovelTrialsHand,Earlytrials);

    Late_Eye=intersect(NovelTrialsEye,Latetrials);
    Late_Arm=intersect(NovelTrialsHand,Latetrials);



    TrialsToAnalize=NovelTrialsOnly; 

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
  
                          X_nested_e = [Directions(NovelTrialsOnly)' , Value(NovelTrialsOnly),Block(NovelTrialsOnly)',Reward(NovelTrialsOnly)',TrialsMarkers.RTs(NovelTrialsOnly)',ImageIDs(NovelTrialsOnly)'];

                  elseif nSession >32

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

   
end  %% for Sessions

AllPSessions_Eye= { AllSesspValueDir_Eye , AllSesspValueRw_Eye , AllSess_pValueMotSyst_Eye , ...
    AllSess_pValue_Rew_Eye , AllSesspValue_DirMotSyst_Eye, AllSesspValue_DirValue_Eye, ... 
    AllSesspValue_MotorSistValue_Eye, AllSesspValue_RewDir_Eye, AllSesspValue_RewMotSyst_Eye, ...
    AllSesspValue_ValueRew_Eye   };


AllPSessions = { AllPSessions_Eye};


 






%%
%% =========================== 1. PLOT SIGNIFICANCE  =============================
%% =======================================================================



% Areas color
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


areaLabels = {'PMd','PFC','dPut','dCd','lVS','mVS','GPi','Amygdala'};


%% Figure. Plot fraction of neurons coding task variables over time (example session for monkey 1)
plot_all_predictorsBothMonkeys_main1(AllPSessions_Eye, 'Monkey 1', Colors, predictorNames, TimeUsed);




%% barplot motor-system-invariant vs motor-system-specific value coding (Fig 2D in the manuscript)
computeAndPlotSustainedFractions_v4(...
        AllPSessions_Eye, predictorNames, areaLabels, ...
        TimeUsed, Colors, -600, 1200)







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

end
