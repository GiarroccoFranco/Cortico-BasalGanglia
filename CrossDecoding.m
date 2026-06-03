clearvars, clc
close all
cd('C:\Users\giarroccof2\OneDrive - National Institutes of Health\Franco\NeuralData\')
Sessions = importdata('RecordingSessionsM1M2_Final.txt');
Folder = cd('C:\Users\giarroccof2\OneDrive - National Institutes of Health\Franco\NeuralData\');

Test = 'TestPumpy2_';
Year = '2022';

Sessions2Anal = 1:length(Sessions);
nAreas        = 8;
areaLabels    = {'PMd','vlPFC','Put','Cd','lVS','mVS','GPi','Amy'};

% ══════════════════════════════════════════════════════════════════════
% STORAGE — Single session dot products
% Dim 2: 4 angles
%   1 = within-saccade  (value vs outcome)
%   2 = within-reach    (value vs outcome)
%   3 = cross-system    (value: saccade vs reach)
%   4 = cross-system    (outcome: saccade vs reach)
% ══════════════════════════════════════════════════════════════════════
Ortgn          = nan(length(Sessions), 4, nAreas);
All_Vectors    = nan(100, 4, nAreas, length(Sessions));
Sig_Neurons    = nan(100, 4, nAreas, length(Sessions));
% Col 1 = value-sig saccade
% Col 2 = value-sig reach
% Col 3 = outcome-sig saccade
% Col 4 = outcome-sig reach

% ══════════════════════════════════════════════════════════════════════
% SESSION LOOP
% ══════════════════════════════════════════════════════════════════════
for nSession = Sessions2Anal

    nSession
    Session = [];
    Session = Sessions(nSession);
    subpath = fullfile(Folder);

    if nSession > 32
        namefolder = strcat('0', num2str(Session));
        cd(strcat(subpath, '\', namefolder));
        load SessionSARSAValues.mat
        Sarsa = SessionSARSAValues;
        load TrialsMarkers.mat
        TrialsMarkers = TrialsMarkers;
    end
    if nSession < 33
        StrSess = num2str(Session);
        subpath = fullfile(Folder, strcat(Test, StrSess(3:6), Year));
        cd(subpath)
        load SARSASessionValues.mat
        Sarsa = SARSASessionValues;
        load TrialsMarkers_StimOn_100_50.mat
        TrialsMarkers = TrialsMarkers_StimOn_100_50;
    end

    % ── Load both aligned SessionData ──────────────────────────────────
    load SessionData_StimOn_250_50.mat
    SessionData_Obj = SessionData_StimOn_250_50;

    load SessionData_250_50_Reward.mat
    SessionData_Out = SessionData_250_50_Reward;

    load SessionStimValues.mat
    Value = SessionStimValues;

    % ── Trial markers ──────────────────────────────────────────────────
    Directions  = FindDirection(TrialsMarkers);
    N_Block     = TrialsMarkers.BlockCode;
    Reward      = TrialsMarkers.Reward_Output;
    StimulusRew = TrialsMarkers.HighRewProbStimSelected;
    Block       = TrialsMarkers.HandBlocks;

    NovelTrialsHand = find(TrialsMarkers.NovelBlocksHand == 1);
    NovelTrialsEye  = find(TrialsMarkers.NovelBlocksEye  == 1);
    Alltrials       = 1:length(Reward);
    RTs             = TrialsMarkers.RTs;
    ImageIDs        = DefineIDs(N_Block, StimulusRew);

    All_Trials_WithinBlock = TrialsMarkers.TrialWithinBlock;
    uniqueTrials = unique(TrialsMarkers.TrialWithinBlock, 'stable');
    blockVector  = zeros(size(TrialsMarkers.TrialWithinBlock));
    currentBlock = 1;
    for i = 1:length(TrialsMarkers.TrialWithinBlock)
        if TrialsMarkers.TrialWithinBlock(i) == uniqueTrials(1) && i > 1
            currentBlock = currentBlock + 1;
        end
        blockVector(i) = currentBlock;
    end

    % ── TimeStamps ────────────────────────────────────────────────────
    TimeStamp_Obj = find(ismember(SessionData_Obj.Times, SessionData_Obj.Times));
    TimeStamp_Out = find(ismember(SessionData_Out.Times, SessionData_Out.Times));

    % ── Electrode locations ───────────────────────────────────────────
    [PMd, PFC, dCd, dPut, VS_Cd, VS_Put, GPi, Amy, ~] = ...
        GetElectrodesLocation_BothMonkeys(nSession);

    TrialsToAnalize = Alltrials;

    % ── Create DecData for both alignments ────────────────────────────
    [DecData_PMd_Obj ] = CreateDataRegression_2(SessionData_Obj, TrialsToAnalize, TimeStamp_Obj, PMd);
    [DecData_PFC_Obj ] = CreateDataRegression_2(SessionData_Obj, TrialsToAnalize, TimeStamp_Obj, PFC);
    [DecData_dPut_Obj] = CreateDataRegression_2(SessionData_Obj, TrialsToAnalize, TimeStamp_Obj, dPut);
    [DecData_dCd_Obj ] = CreateDataRegression_2(SessionData_Obj, TrialsToAnalize, TimeStamp_Obj, dCd);
    [DecData_VsPut_Obj] = CreateDataRegression_2(SessionData_Obj, TrialsToAnalize, TimeStamp_Obj, VS_Put);
    [DecData_VsCd_Obj ] = CreateDataRegression_2(SessionData_Obj, TrialsToAnalize, TimeStamp_Obj, VS_Cd);
    [DecData_GPi_Obj ] = CreateDataRegression_2(SessionData_Obj, TrialsToAnalize, TimeStamp_Obj, GPi);
    [DecData_Amy_Obj ] = CreateDataRegression_2(SessionData_Obj, TrialsToAnalize, TimeStamp_Obj, Amy);

    [DecData_PMd_Out ] = CreateDataRegression_2(SessionData_Out, TrialsToAnalize, TimeStamp_Out, PMd);
    [DecData_PFC_Out ] = CreateDataRegression_2(SessionData_Out, TrialsToAnalize, TimeStamp_Out, PFC);
    [DecData_dPut_Out] = CreateDataRegression_2(SessionData_Out, TrialsToAnalize, TimeStamp_Out, dPut);
    [DecData_dCd_Out ] = CreateDataRegression_2(SessionData_Out, TrialsToAnalize, TimeStamp_Out, dCd);
    [DecData_VsPut_Out] = CreateDataRegression_2(SessionData_Out, TrialsToAnalize, TimeStamp_Out, VS_Put);
    [DecData_VsCd_Out ] = CreateDataRegression_2(SessionData_Out, TrialsToAnalize, TimeStamp_Out, VS_Cd);
    [DecData_GPi_Out ] = CreateDataRegression_2(SessionData_Out, TrialsToAnalize, TimeStamp_Out, GPi);
    [DecData_Amy_Out ] = CreateDataRegression_2(SessionData_Out, TrialsToAnalize, TimeStamp_Out, Amy);

    data_Obj = {DecData_PMd_Obj, DecData_PFC_Obj, DecData_dPut_Obj, DecData_dCd_Obj, ...
                DecData_VsPut_Obj, DecData_VsCd_Obj, DecData_GPi_Obj, DecData_Amy_Obj};
    data_Out = {DecData_PMd_Out, DecData_PFC_Out, DecData_dPut_Out, DecData_dCd_Out, ...
                DecData_VsPut_Out, DecData_VsCd_Out, DecData_GPi_Out, DecData_Amy_Out};

    % ── X matrices ────────────────────────────────────────────────────
    zero_dir = find(Directions == 0);
    Directions(zero_dir) = -1;

    if nSession < 33
        X_Eye = [Directions(NovelTrialsEye)', Value(NovelTrialsEye), ...
                 Reward(NovelTrialsEye)', ImageIDs(NovelTrialsEye)', ...
                 RTs(NovelTrialsEye)'];
        X_Arm = [Directions(NovelTrialsHand)', Value(NovelTrialsHand), ...
                 Reward(NovelTrialsHand)', ImageIDs(NovelTrialsHand)', ...
                 RTs(NovelTrialsHand)'];

        St_V_Eye   =   Value(NovelTrialsEye)  ;
        St_V_Arm   =   Value(NovelTrialsHand)  ;

    else
        X_Eye = [Directions(NovelTrialsEye)', Value(NovelTrialsEye)', ...
                 Reward(NovelTrialsEye)', ImageIDs(NovelTrialsEye)', ...
                 RTs(NovelTrialsEye)'];
        X_Arm = [Directions(NovelTrialsHand)', Value(NovelTrialsHand)', ...
                 Reward(NovelTrialsHand)', ImageIDs(NovelTrialsHand)', ...
                 RTs(NovelTrialsHand)'];
        St_V_Eye   =   Value(NovelTrialsEye)  ;
        St_V_Arm   =   Value(NovelTrialsHand)  ;
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
   
    SV_Eye_index (Eye_StimLow)=0;     SV_Eye_index (Eye_StimHigh)=1;
    
    SV_Arm_index (Arm_StimLow)=0;     SV_Arm_index (Arm_StimHigh)=1;

    % ══════════════════════════════════════════════════════════════════
    % REG LOOP
    % ══════════════════════════════════════════════════════════════════
    for REG = 1:nAreas

        DataMat_Obj = data_Obj{1, REG};
        DataMat_Out = data_Out{1, REG};

        if isempty(DataMat_Obj) || isempty(DataMat_Out)
            nneurons(nSession, REG) = 0;
            continue
        end

        nNeu = size(DataMat_Obj, 3);
        if size(DataMat_Out, 3) ~= nNeu
            warning('Session %d REG %d: neuron count mismatch', nSession, REG)
            continue
        end

        nneurons(nSession, REG) = nNeu;

        nBins_Obj = size(DataMat_Obj, 2);
        nBins_Out = size(DataMat_Out, 2);

        % Beta and p-value storage
        BetaVal_Eye = nan(nNeu, nBins_Obj);
        BetaVal_Arm = nan(nNeu, nBins_Obj);
        BetaOut_Eye = nan(nNeu, nBins_Out);
        BetaOut_Arm = nan(nNeu, nBins_Out);

        pVal_Eye    = nan(nNeu, nBins_Obj);
        pVal_Arm    = nan(nNeu, nBins_Obj);
        pOut_Eye    = nan(nNeu, nBins_Out);
        pOut_Arm    = nan(nNeu, nBins_Out);

        for neu = 1:nNeu

            tmp_BetaVal_Eye = nan(1, nBins_Obj);
            tmp_BetaVal_Arm = nan(1, nBins_Obj);
            tmp_pVal_Eye    = nan(1, nBins_Obj);
            tmp_pVal_Arm    = nan(1, nBins_Obj);

            tmp_BetaOut_Eye = nan(1, nBins_Out);
            tmp_BetaOut_Arm = nan(1, nBins_Out);
            tmp_pOut_Eye    = nan(1, nBins_Out);
            tmp_pOut_Arm    = nan(1, nBins_Out);

            % Object-aligned — Value coefficient = {3,1}
            parfor bin = 1:nBins_Obj
                B_Obj_Eye = fitlm(X_Eye, ...
                    DataMat_Obj(NovelTrialsEye, bin, neu), ...
                    'linear', 'CategoricalVars', [1 3]);
                B_Obj_Arm = fitlm(X_Arm, ...
                    DataMat_Obj(NovelTrialsHand, bin, neu), ...
                    'linear', 'CategoricalVars', [1 3]);

                tmp_BetaVal_Eye(bin) = B_Obj_Eye.Coefficients{3, 1};
                tmp_BetaVal_Arm(bin) = B_Obj_Arm.Coefficients{3, 1};
                tmp_pVal_Eye(bin)    = B_Obj_Eye.Coefficients{3, 4};
                tmp_pVal_Arm(bin)    = B_Obj_Arm.Coefficients{3, 4};
            end

            % Outcome-aligned — Outcome coefficient = {4,1}
            parfor bin = 1:nBins_Out
                B_Out_Eye = fitlm(X_Eye, ...
                    DataMat_Out(NovelTrialsEye, bin, neu), ...
                    'linear', 'CategoricalVars', [1 3]);
                B_Out_Arm = fitlm(X_Arm, ...
                    DataMat_Out(NovelTrialsHand, bin, neu), ...
                    'linear', 'CategoricalVars', [1 3]);

                tmp_BetaOut_Eye(bin) = B_Out_Eye.Coefficients{4, 1};
                tmp_BetaOut_Arm(bin) = B_Out_Arm.Coefficients{4, 1};
                tmp_pOut_Eye(bin)    = B_Out_Eye.Coefficients{4, 4};
                tmp_pOut_Arm(bin)    = B_Out_Arm.Coefficients{4, 4};
            end

            BetaVal_Eye(neu, :) = tmp_BetaVal_Eye;
            BetaVal_Arm(neu, :) = tmp_BetaVal_Arm;
            BetaOut_Eye(neu, :) = tmp_BetaOut_Eye;
            BetaOut_Arm(neu, :) = tmp_BetaOut_Arm;
            pVal_Eye(neu, :)    = tmp_pVal_Eye;
            pVal_Arm(neu, :)    = tmp_pVal_Arm;
            pOut_Eye(neu, :)    = tmp_pOut_Eye;
            pOut_Arm(neu, :)    = tmp_pOut_Arm;

        end % neu

        % ── Peak bins ─────────────────────────────────────────────────
        [~, bin_ValEye] = max(vecnorm(BetaVal_Eye));
        [~, bin_ValArm] = max(vecnorm(BetaVal_Arm));
        [~, bin_OutEye] = max(vecnorm(BetaOut_Eye));
        [~, bin_OutArm] = max(vecnorm(BetaOut_Arm));

        % ── Peak vectors ──────────────────────────────────────────────
        Vec_ValEye = BetaVal_Eye(:, bin_ValEye(1));
        Vec_ValArm = BetaVal_Arm(:, bin_ValArm(1));
        Vec_OutEye = BetaOut_Eye(:, bin_OutEye(1));
        Vec_OutArm = BetaOut_Arm(:, bin_OutArm(1));

        % ── Store raw vectors ──────────────────────────────────────────
        All_Vectors(1:nNeu, 1, REG, nSession) = Vec_ValEye;
        All_Vectors(1:nNeu, 2, REG, nSession) = Vec_ValArm;
        All_Vectors(1:nNeu, 3, REG, nSession) = Vec_OutEye;
        All_Vectors(1:nNeu, 4, REG, nSession) = Vec_OutArm;

        % ── Significant neurons ────────────────────────────────────────
        Sig_Neurons(find(pVal_Eye(:, bin_ValEye(1)) < 0.05), 1, REG, nSession) = 1;
        Sig_Neurons(find(pVal_Arm(:, bin_ValArm(1)) < 0.05), 2, REG, nSession) = 1;
        Sig_Neurons(find(pOut_Eye(:, bin_OutEye(1)) < 0.05), 3, REG, nSession) = 1;
        Sig_Neurons(find(pOut_Arm(:, bin_OutArm(1)) < 0.05), 4, REG, nSession) = 1;

        % ── Normalize ─────────────────────────────────────────────────
        Vec_ValEye_n = Vec_ValEye / norm(Vec_ValEye);
        Vec_ValArm_n = Vec_ValArm / norm(Vec_ValArm);
        Vec_OutEye_n = Vec_OutEye / norm(Vec_OutEye);
        Vec_OutArm_n = Vec_OutArm / norm(Vec_OutArm);

        % ── Single session dot products ────────────────────────────────
        % 1 = within-saccade value-outcome
        % 2 = within-reach value-outcome
        % 3 = cross-system value
        % 4 = cross-system outcome
        Ortgn(nSession, 1, REG) = dot(Vec_ValEye_n, Vec_OutEye_n);
        Ortgn(nSession, 2, REG) = dot(Vec_ValArm_n, Vec_OutArm_n);
        Ortgn(nSession, 3, REG) = dot(Vec_ValEye_n, Vec_ValArm_n);
        Ortgn(nSession, 4, REG) = dot(Vec_OutEye_n, Vec_OutArm_n);

    end % REG

end % nSession



function Accuracy=PerformSVM(DecData,Trials,Label)

for  bin= 1:size(DecData,2)

    Dat=DecData{1,bin};
    if ~isempty(Dat)

        DataC=Dat(:,Trials)';
        Mdl = fitcsvm(DataC,Label,"Prior","uniform",'KernelFunction','linear',KFold=10);
        Accuracy(bin) = 1-kfoldLoss(Mdl);
    
    elseif isempty(Dat)
        Accuracy(bin) =NaN;
    end



end


end
