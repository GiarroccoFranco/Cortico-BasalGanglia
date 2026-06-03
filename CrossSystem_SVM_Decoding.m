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
nShuffles     = 10;

% ══════════════════════════════════════════════════════════════════════
% STORAGE
% Dims: nSessions × nBins × nAreas
% Value decoding
% ══════════════════════════════════════════════════════════════════════
maxBins = 65; % preallocate generously; trim later

% Within-system decoding (10-fold CV)
Acc_Val_WithinEye  = nan(length(Sessions), maxBins, nAreas);
Acc_Val_WithinArm  = nan(length(Sessions), maxBins, nAreas);
Acc_Out_WithinEye  = nan(length(Sessions), maxBins, nAreas);
Acc_Out_WithinArm  = nan(length(Sessions), maxBins, nAreas);

% Cross-system decoding (train one, test other)
Acc_Val_TrainArm_TestEye = nan(length(Sessions), maxBins, nAreas);
Acc_Val_TrainEye_TestArm = nan(length(Sessions), maxBins, nAreas);
Acc_Out_TrainArm_TestEye = nan(length(Sessions), maxBins, nAreas);
Acc_Out_TrainEye_TestArm = nan(length(Sessions), maxBins, nAreas);

% Shuffle baselines (mean over nShuffles)
Shuf_Val_WithinEye  = nan(length(Sessions), maxBins, nAreas);
Shuf_Val_WithinArm  = nan(length(Sessions), maxBins, nAreas);
Shuf_Out_WithinEye  = nan(length(Sessions), maxBins, nAreas);
Shuf_Out_WithinArm  = nan(length(Sessions), maxBins, nAreas);

Shuf_Val_TrainArm_TestEye = nan(length(Sessions), maxBins, nAreas);
Shuf_Val_TrainEye_TestArm = nan(length(Sessions), maxBins, nAreas);
Shuf_Out_TrainArm_TestEye = nan(length(Sessions), maxBins, nAreas);
Shuf_Out_TrainEye_TestArm = nan(length(Sessions), maxBins, nAreas);

nneurons = nan(length(Sessions), nAreas);

% ══════════════════════════════════════════════════════════════════════
% SESSION LOOP
% ══════════════════════════════════════════════════════════════════════
for nSession =   Sessions2Anal

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

    % ── Value labels (tercile split) ──────────────────────────────────
    if nSession < 33
        St_V_Eye = Value(NovelTrialsEye);
        St_V_Arm = Value(NovelTrialsHand);
    else
        St_V_Eye = Value(NovelTrialsEye)';
        St_V_Arm = Value(NovelTrialsHand)';
    end

    % Eye value labels
    stim_p33_Eye = prctile(St_V_Eye, 33);
    stim_p66_Eye = prctile(St_V_Eye, 66);
    Eye_StimLow  = find(St_V_Eye <= stim_p33_Eye);
    Eye_StimHigh = find(St_V_Eye >= stim_p66_Eye);
    Eye_ValTrials = [Eye_StimLow; Eye_StimHigh];
    Eye_ValLabels = [zeros(length(Eye_StimLow),1); ones(length(Eye_StimHigh),1)];

    % Arm value labels
    stim_p33_Arm = prctile(St_V_Arm, 33);
    stim_p66_Arm = prctile(St_V_Arm, 66);
    Arm_StimLow  = find(St_V_Arm <= stim_p33_Arm);
    Arm_StimHigh = find(St_V_Arm >= stim_p66_Arm);
    Arm_ValTrials = [Arm_StimLow; Arm_StimHigh];
    Arm_ValLabels = [zeros(length(Arm_StimLow),1); ones(length(Arm_StimHigh),1)];

    % ── Outcome labels (already binary) ───────────────────────────────
    Eye_OutLabels = Reward(NovelTrialsEye)';
    Arm_OutLabels = Reward(NovelTrialsHand)';

    % ══════════════════════════════════════════════════════════════════
    % AREA LOOP
    % ══════════════════════════════════════════════════════════════════
    for REG = 1:nAreas

        DataMat_Obj = data_Obj{1, REG};  % trials × bins × neurons
        DataMat_Out = data_Out{1, REG};

        if isempty(DataMat_Obj) || isempty(DataMat_Out)
            nneurons(nSession, REG) = 0;
            continue
        end

        nNeu = size(DataMat_Obj, 3);
        nneurons(nSession, REG) = nNeu;

        if nNeu < 2
            continue
        end

        nBins_Obj = size(DataMat_Obj, 2);
        nBins_Out = size(DataMat_Out, 2);

        % ── VALUE DECODING (object-aligned) ───────────────────────────
        parfor bin = 1:nBins_Obj

            % Neural data: trials × neurons
            NeuEye_all = squeeze(DataMat_Obj(:, bin, :));  % all trials
            NeuArm_all = squeeze(DataMat_Obj(:, bin, :));

            % Select novel trials, then subset to low/high
            NeuEye_novel = NeuEye_all(NovelTrialsEye, :);
            NeuArm_novel = NeuArm_all(NovelTrialsHand, :);

            % Value subsets (indices into novel trials)
            DataEye_Val = NeuEye_novel(Eye_ValTrials, :);
            DataArm_Val = NeuArm_novel(Arm_ValTrials, :);

            % --- Within-system: 10-fold CV ---
            if length(Eye_ValLabels) >= 10
                Acc_Val_WithinEye(nSession, bin, REG) = ...
                    SVMWithinDecode(DataEye_Val, Eye_ValLabels);
            end
            if length(Arm_ValLabels) >= 10
                Acc_Val_WithinArm(nSession, bin, REG) = ...
                    SVMWithinDecode(DataArm_Val, Arm_ValLabels);
            end

            % --- Cross-system: train Arm, test Eye ---
            if length(Arm_ValLabels) >= 5 && length(Eye_ValLabels) >= 5
                Acc_Val_TrainArm_TestEye(nSession, bin, REG) = ...
                    SVMCrossDecode(DataArm_Val, Arm_ValLabels, DataEye_Val, Eye_ValLabels);
                Acc_Val_TrainEye_TestArm(nSession, bin, REG) = ...
                    SVMCrossDecode(DataEye_Val, Eye_ValLabels, DataArm_Val, Arm_ValLabels);
            end

            % --- Shuffle baselines ---
            % --- Shuffle baseline (single shuffle, CV for within) ---
            shufEye = Eye_ValLabels(randperm(length(Eye_ValLabels)));
            shufArm = Arm_ValLabels(randperm(length(Arm_ValLabels)));

            if length(Eye_ValLabels) >= 10
                Shuf_Val_WithinEye(nSession, bin, REG) = SVMWithinDecode(DataEye_Val, shufEye);
            end
            if length(Arm_ValLabels) >= 10
                Shuf_Val_WithinArm(nSession, bin, REG) = SVMWithinDecode(DataArm_Val, shufArm);
            end
            if length(Arm_ValLabels) >= 5 && length(Eye_ValLabels) >= 5
                Shuf_Val_TrainArm_TestEye(nSession, bin, REG) = SVMCrossDecode(DataArm_Val, shufArm, DataEye_Val, shufEye);
                Shuf_Val_TrainEye_TestArm(nSession, bin, REG) = SVMCrossDecode(DataEye_Val, shufEye, DataArm_Val, shufArm);
            end

           
        end

% %         % ── OUTCOME DECODING (outcome-aligned) ───────────────────────
%         parfor bin = 1:nBins_Out
% 
%             NeuEye_all = squeeze(DataMat_Out(:, bin, :));
%             NeuArm_all = squeeze(DataMat_Out(:, bin, :));
% 
%             NeuEye_novel = NeuEye_all(NovelTrialsEye, :);
%             NeuArm_novel = NeuArm_all(NovelTrialsHand, :);
% 
%             % --- Within-system: 10-fold CV ---
%             if length(Eye_OutLabels) >= 10
%                 Acc_Out_WithinEye(nSession, bin, REG) = ...
%                     SVMWithinDecode(NeuEye_novel, Eye_OutLabels);
%             end
%             if length(Arm_OutLabels) >= 10
%                 Acc_Out_WithinArm(nSession, bin, REG) = ...
%                     SVMWithinDecode(NeuArm_novel, Arm_OutLabels);
%             end
% 
%             % --- Cross-system ---
%             if length(Arm_OutLabels) >= 5 && length(Eye_OutLabels) >= 5
%                 Acc_Out_TrainArm_TestEye(nSession, bin, REG) = ...
%                     SVMCrossDecode(NeuArm_novel, Arm_OutLabels, NeuEye_novel, Eye_OutLabels);
%                 Acc_Out_TrainEye_TestArm(nSession, bin, REG) = ...
%                     SVMCrossDecode(NeuEye_novel, Eye_OutLabels, NeuArm_novel, Arm_OutLabels);
%             end
% 
%             shufEye = Eye_OutLabels(randperm(length(Eye_OutLabels)));
%             shufArm = Arm_OutLabels(randperm(length(Arm_OutLabels)));
% 
%             if length(Eye_OutLabels) >= 10
%                 Shuf_Out_WithinEye(nSession, bin, REG) = SVMWithinDecode(NeuEye_novel, shufEye);
%             end
%             if length(Arm_OutLabels) >= 10
%                 Shuf_Out_WithinArm(nSession, bin, REG) = SVMWithinDecode(NeuArm_novel, shufArm);
%             end
%             if length(Arm_OutLabels) >= 5 && length(Eye_OutLabels) >= 5
%                 Shuf_Out_TrainArm_TestEye(nSession, bin, REG) = SVMCrossDecode(NeuArm_novel, shufArm, NeuEye_novel, shufEye);
%                 Shuf_Out_TrainEye_TestArm(nSession, bin, REG) = SVMCrossDecode(NeuEye_novel, shufEye, NeuArm_novel, shufArm);
%             end
% 
% 
%          
%         end

    end % REG

end % nSession
keyboard
% ══════════════════════════════════════════════════════════════════════
% PLOTTING — Mean across sessions (± SEM) for each area
% ══════════════════════════════════════════════════════════════════════

%% ══════════════════════════════════════════════════════════════════════


% ── Colors and labels ────────────────────────────────────────────────
% ══════════════════════════════════════════════════════════════════════
%  TIME COURSE FIGURES — Saccade and Reach separate
%  Each figure: 2×2 (top: value within/cross, bottom: outcome within/cross)
%  X-axis: real time (ms) aligned to object or outcome
% ══════════════════════════════════════════════════════════════════════
% --- Helper: compute mean and SEM across sessions, ignoring NaN ---

meanSEM = @(X, dim) deal(nanmean(X, dim), nanstd(X, 0, dim) ./ sqrt(sum(~isnan(X), dim)));
areaLabels = {'PMd','vlPFC','Put','Cd','lVS','mVS','GPi','Amy'};

Colors = [ [54 140 66]/255;
           [210 212 113]/255;
           [59 127 137]/255;
           [175 149 132]/255;
           [67 170 175]/255;
           [232 174 135]/255;
           [140 140 140]/255;
           [243 168 168]/255 ];

% ── MODIFIABLE PARAMETERS ─────────────────────────────────────────────
smoothWin       = 8;       % Gaussian smoothing window (bins)
minConsecBins   = 4;       % minimum consecutive significant bins to show
alphaLevel      = 0.05;

% ── Time vectors (ms) ────────────────────────────────────────────────
timeVec_Obj = -1200:50:2000;   % object-aligned (value)
timeVec_Out = -700:50:2500;    % outcome-aligned (outcome)

smoothBins = @(X) smoothdata(X, 2, 'gaussian', smoothWin);

% ── Build 8 data packets ─────────────────────────────────────────────
packets = struct();
packets(1).real = Acc_Val_WithinEye;         packets(1).shuf = Shuf_Val_WithinEye;         packets(1).timeVec = timeVec_Obj;
packets(2).real = Acc_Val_TrainArm_TestEye;  packets(2).shuf = Shuf_Val_TrainArm_TestEye;  packets(2).timeVec = timeVec_Obj;
packets(3).real = Acc_Out_WithinEye;         packets(3).shuf = Shuf_Out_WithinEye;         packets(3).timeVec = timeVec_Out;
packets(4).real = Acc_Out_TrainArm_TestEye;  packets(4).shuf = Shuf_Out_TrainArm_TestEye;  packets(4).timeVec = timeVec_Out;
packets(5).real = Acc_Val_WithinArm;         packets(5).shuf = Shuf_Val_WithinArm;         packets(5).timeVec = timeVec_Obj;
packets(6).real = Acc_Val_TrainEye_TestArm;  packets(6).shuf = Shuf_Val_TrainEye_TestArm;  packets(6).timeVec = timeVec_Obj;
packets(7).real = Acc_Out_WithinArm;         packets(7).shuf = Shuf_Out_WithinArm;         packets(7).timeVec = timeVec_Out;
packets(8).real = Acc_Out_TrainEye_TestArm;  packets(8).shuf = Shuf_Out_TrainEye_TestArm;  packets(8).timeVec = timeVec_Out;

% Smooth all
for pk = 1:8
    for REG = 1:nAreas
        for s = 1:length(Sessions)
            packets(pk).real(s,:,REG) = smoothBins(packets(pk).real(s,:,REG));
            packets(pk).shuf(s,:,REG) = smoothBins(packets(pk).shuf(s,:,REG));
        end
    end
end

% ── Panel layout ──────────────────────────────────────────────────────
figTitles   = {'Saccade', 'Reach'};
panelTitles = {'Value — Within', 'Value — Cross', 'Outcome — Within', 'Outcome — Cross'};
panelIdx    = {[1 2 3 4], [5 6 7 8]};
xLabels     = {'Time from object (ms)', 'Time from object (ms)', ...
               'Time from outcome (ms)', 'Time from outcome (ms)'};

for fig = 1:2
    figure('Position', [50+400*(fig-1) 50 1200 900], 'Color', 'w')

    for p = 1:4
        subplot(2,2,p); hold on

        pk = panelIdx{fig}(p);
        realData = packets(pk).real;
        shufData = packets(pk).shuf;
        tVec     = packets(pk).timeVec;

        % Trim time vector to match number of bins
        nBinsData = size(realData, 2);
        if length(tVec) > nBinsData
            tVec = tVec(1:nBinsData);
        elseif length(tVec) < nBinsData
            tVec = tVec(1):50:(tVec(1) + (nBinsData-1)*50);
        end

        % ── Shuffled baseline (pooled across areas) ───────────────────
        shufAll = reshape(shufData, [], size(shufData, 2));
        validBinsAll = find(any(~isnan(shufAll), 1));
        if ~isempty(validBinsAll)
            mu_shuf  = nanmean(shufAll(:, validBinsAll), 1);
            sem_shuf = nanstd(shufAll(:, validBinsAll), 0, 1);
            fill([tVec(validBinsAll) fliplr(tVec(validBinsAll))], ...
                 [mu_shuf+sem_shuf fliplr(mu_shuf-sem_shuf)], ...
                 [0 0 0], 'FaceAlpha', 0.1, 'EdgeColor', 'none');
            plot(tVec(validBinsAll), mu_shuf, 'k-', 'LineWidth', 1);
        end
        yline(0.5, '--', 'Color', [0.5 0.5 0.5]);
        xline(0, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5);

        % ── Area curves ──────────────────────────────────────────────
        legendH = gobjects(nAreas, 1);
        for REG = 1:nAreas
            areaReal = squeeze(realData(:, :, REG));
            validBins = find(any(~isnan(areaReal), 1));
            if isempty(validBins); continue; end

            mu  = nanmean(areaReal(:, validBins), 1);
            nS  = sum(~isnan(areaReal(:, validBins)), 1);
            sem = nanstd(areaReal(:, validBins), 0, 1) ./ sqrt(nS);

            fill([tVec(validBins) fliplr(tVec(validBins))], [mu+sem fliplr(mu-sem)], ...
                Colors(REG,:), 'FaceAlpha', 0.15, 'EdgeColor', 'none');
            legendH(REG) = plot(tVec(validBins), mu, '-', 'Color', Colors(REG,:), 'LineWidth', 2);
        end

        % ── Significance dots (above the data) ───────────────────────
        % Get current y-axis limits from the data, then place dots above
        yl = ylim;
        dotYtop   = yl(2) + 0.005;   % just above top of axes
        dotYstep  = 0.012;
        ylim([yl(1)  dotYtop + nAreas * dotYstep + 0.005])  % expand to fit dots

        for REG = 1:nAreas
            areaReal = squeeze(realData(:, :, REG));
            areaShuf = squeeze(shufData(:, :, REG));
            validBins = find(any(~isnan(areaReal), 1));
            if isempty(validBins); continue; end

            sigMask = false(1, nBinsData);
            for b = validBins
                validSess = find(~isnan(areaReal(:,b)) & ~isnan(areaShuf(:,b)));
                if length(validSess) < 5; continue; end
                [~, pval] = ttest(areaReal(validSess, b), areaShuf(validSess, b));
                sigMask(b) = pval < alphaLevel;
            end

            sigMask = filterConsec(sigMask, minConsecBins);

            sigBins = find(sigMask);
            if ~isempty(sigBins)
                ypos = dotYtop + (REG-1) * dotYstep;
                plot(tVec(sigBins), repmat(ypos, 1, length(sigBins)), '.', ...
                    'Color', Colors(REG,:), 'MarkerSize', 8);
            end
        end

        title(panelTitles{p}); xlabel(xLabels{p}); ylabel('Accuracy')
    end

    sgtitle(['Cross-System SVM Decoding — ' figTitles{fig}])
end


%%

%% ══════════════════════════════════════════════════════════════════════
%  PER-AREA TIME COURSE: Within vs Cross decoding
%  Two figures (Saccade, Reach), each with 8 subplots (one per area)
%  Each subplot: within accuracy (area color) vs cross accuracy (dark gray)
%  Three dot rows: (1) within sig, (2) cross sig, (3) within vs cross diff
%  Pooled monkeys
% ══════════════════════════════════════════════════════════════════════

areaLabels = {'PMd','vlPFC','Put','Cd','lVS','mVS','GPi','Amy'};

Colors = [ [54 140 66]/255;
           [210 212 113]/255;
           [59 127 137]/255;
           [175 149 132]/255;
           [67 170 175]/255;
           [232 174 135]/255;
           [140 140 140]/255;
           [243 168 168]/255 ];

crossColor = [0.35 0.35 0.35];   % dark gray for cross decoding
diffColor  = [0 0 0];            % black for within-vs-cross difference

% ── MODIFIABLE PARAMETERS ─────────────────────────────────────────────
smoothWin       = 8;
minConsecBins   = 5;
alphaLevel      = 0.05;

% ── Time vectors (ms) ────────────────────────────────────────────────
timeVec_Obj = -1200:50:2000;
timeVec_Out = -700:50:2500;

smoothBins = @(X) smoothdata(X, 2, 'gaussian', smoothWin);

% ══════════════════════════════════════════════════════════════════════
%  BUILD DATA PACKETS — value only (object-aligned)
%  Extend to outcome by duplicating with Out variables and timeVec_Out
% ══════════════════════════════════════════════════════════════════════

% Saccade: within = WithinEye, cross = TrainArm_TestEye
% Reach:   within = WithinArm, cross = TrainEye_TestArm

figSpecs = struct();

% --- Saccade Value ---
figSpecs(1).withinReal = Acc_Val_WithinEye;
figSpecs(1).withinShuf = Shuf_Val_WithinEye;
figSpecs(1).crossReal  = Acc_Val_TrainArm_TestEye;
figSpecs(1).crossShuf  = Shuf_Val_TrainArm_TestEye;
figSpecs(1).timeVec    = timeVec_Obj;
figSpecs(1).title      = 'Saccade — Value';
figSpecs(1).xLabel     = 'Time from object (ms)';

% --- Reach Value ---
figSpecs(2).withinReal = Acc_Val_WithinArm;
figSpecs(2).withinShuf = Shuf_Val_WithinArm;
figSpecs(2).crossReal  = Acc_Val_TrainEye_TestArm;
figSpecs(2).crossShuf  = Shuf_Val_TrainEye_TestArm;
figSpecs(2).timeVec    = timeVec_Obj;
figSpecs(2).title      = 'Reach — Value';
figSpecs(2).xLabel     = 'Time from object (ms)';

% --- Saccade Outcome ---
figSpecs(3).withinReal = Acc_Out_WithinEye;
figSpecs(3).withinShuf = Shuf_Out_WithinEye;
figSpecs(3).crossReal  = Acc_Out_TrainArm_TestEye;
figSpecs(3).crossShuf  = Shuf_Out_TrainArm_TestEye;
figSpecs(3).timeVec    = timeVec_Out;
figSpecs(3).title      = 'Saccade — Outcome';
figSpecs(3).xLabel     = 'Time from outcome (ms)';

% --- Reach Outcome ---
figSpecs(4).withinReal = Acc_Out_WithinArm;
figSpecs(4).withinShuf = Shuf_Out_WithinArm;
figSpecs(4).crossReal  = Acc_Out_TrainEye_TestArm;
figSpecs(4).crossShuf  = Shuf_Out_TrainEye_TestArm;
figSpecs(4).timeVec    = timeVec_Out;
figSpecs(4).title      = 'Reach — Outcome';
figSpecs(4).xLabel     = 'Time from outcome (ms)';

% ── Smooth all ────────────────────────────────────────────────────────
for f = 1:4
    for REG = 1:nAreas
        for s = 1:length(Sessions)
            figSpecs(f).withinReal(s,:,REG) = smoothBins(figSpecs(f).withinReal(s,:,REG));
            figSpecs(f).withinShuf(s,:,REG) = smoothBins(figSpecs(f).withinShuf(s,:,REG));
            figSpecs(f).crossReal(s,:,REG)  = smoothBins(figSpecs(f).crossReal(s,:,REG));
            figSpecs(f).crossShuf(s,:,REG)  = smoothBins(figSpecs(f).crossShuf(s,:,REG));
        end
    end
end

% ══════════════════════════════════════════════════════════════════════
%  PLOT — 4 figures, each 2×4 (8 areas)
% ══════════════════════════════════════════════════════════════════════

for f = 1:2

    tVec = figSpecs(f).timeVec;
    nBinsData = size(figSpecs(f).withinReal, 2);

    % Safety: match time vector to bin count
    if length(tVec) > nBinsData
        tVec = tVec(1:nBinsData);
    elseif length(tVec) < nBinsData
        tVec = tVec(1):50:(tVec(1) + (nBinsData-1)*50);
    end

    figure('Position', [50 50 700 350], 'Color', 'w')

    for REG = 1:nAreas
        subplot(2, 4, REG); hold on

        wReal = squeeze(figSpecs(f).withinReal(:, :, REG));  % sessions × bins
        wShuf = squeeze(figSpecs(f).withinShuf(:, :, REG));
        cReal = squeeze(figSpecs(f).crossReal(:, :, REG));
        cShuf = squeeze(figSpecs(f).crossShuf(:, :, REG));

        validBins = find(any(~isnan(wReal), 1));
        if isempty(validBins)
            title(areaLabels{REG}); continue
        end

        % ── Shuffled baseline (pool within and cross shuffles) ────────
        shufPool = [wShuf(:, validBins); cShuf(:, validBins)];
        mu_shuf  = nanmean(shufPool, 1);
        sem_shuf = nanstd(shufPool, 0, 1);
        fill([tVec(validBins) fliplr(tVec(validBins))], ...
             [mu_shuf+sem_shuf fliplr(mu_shuf-sem_shuf)], ...
             [0 0 0], 'FaceAlpha', 0.08, 'EdgeColor', 'none');
        plot(tVec(validBins), mu_shuf, 'k-', 'LineWidth', 0.5);

        yline(0.5, '--', 'Color', [0.7 0.7 0.7]);
        xline(0, '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5);

        % ── Within accuracy (area color) ──────────────────────────────
        mu_w  = nanmean(wReal(:, validBins), 1);
        nS_w  = sum(~isnan(wReal(:, validBins)), 1);
        sem_w = nanstd(wReal(:, validBins), 0, 1) ./ sqrt(nS_w);

        fill([tVec(validBins) fliplr(tVec(validBins))], ...
             [mu_w+sem_w fliplr(mu_w-sem_w)], ...
             Colors(REG,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        plot(tVec(validBins), mu_w, '-', 'Color', Colors(REG,:), 'LineWidth', 2);

        % ── Cross accuracy (dark gray) ────────────────────────────────
        validBinsC = find(any(~isnan(cReal), 1));
        if ~isempty(validBinsC)
            mu_c  = nanmean(cReal(:, validBinsC), 1);
            nS_c  = sum(~isnan(cReal(:, validBinsC)), 1);
            sem_c = nanstd(cReal(:, validBinsC), 0, 1) ./ sqrt(nS_c);

            fill([tVec(validBinsC) fliplr(tVec(validBinsC))], ...
                 [mu_c+sem_c fliplr(mu_c-sem_c)], ...
                 crossColor, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
            plot(tVec(validBinsC), mu_c, '-', 'Color', crossColor, 'LineWidth', 2);
        end

        % ── Significance dots ─────────────────────────────────────────
        % Compute ylim from data, then place dots above
       yl = ylim;
        dotStep  = (yl(2) - yl(1)) * 0.025;
        dotBase  = yl(2) + dotStep * 0.5;
        ylim([0.45  dotBase + 3.5 * dotStep])

        % Row 1 (bottom, area color): within vs its shuffle
        sigWithin = false(1, nBinsData);
        for b = validBins
            vs = find(~isnan(wReal(:,b)) & ~isnan(wShuf(:,b)));
            if length(vs) < 5; continue; end
            [~, pval] = ttest(wReal(vs,b), wShuf(vs,b));
            sigWithin(b) = pval < alphaLevel;
        end
        sigWithin = filterConsec(sigWithin, minConsecBins);
        sb = find(sigWithin);
        if ~isempty(sb)
            plot(tVec(sb), repmat(dotBase, 1, length(sb)), '.', ...
                'Color', Colors(REG,:), 'MarkerSize', 8);
        end

        % Row 2 (middle, gray): cross vs its shuffle
        sigCross = false(1, nBinsData);
        for b = validBinsC
            vs = find(~isnan(cReal(:,b)) & ~isnan(cShuf(:,b)));
            if length(vs) < 5; continue; end
            [~, pval] = ttest(cReal(vs,b), cShuf(vs,b));
            sigCross(b) = pval < alphaLevel;
        end
        sigCross = filterConsec(sigCross, minConsecBins);
        sb = find(sigCross);
        if ~isempty(sb)
            plot(tVec(sb), repmat(dotBase + dotStep, 1, length(sb)), '.', ...
                'Color', crossColor, 'MarkerSize', 8);
        end

        % Row 3 (top, black): within vs cross (paired t-test)
        sigDiff = false(1, nBinsData);
        binsCommon = intersect(validBins, validBinsC);
        for b = binsCommon
            vs = find(~isnan(wReal(:,b)) & ~isnan(cReal(:,b)));
            if length(vs) < 5; continue; end
            [~, pval] = ttest(wReal(vs,b), cReal(vs,b));
            sigDiff(b) = pval < alphaLevel;
        end
        sigDiff = filterConsec(sigDiff, minConsecBins);
        sb = find(sigDiff);
        if ~isempty(sb)
            plot(tVec(sb), repmat(dotBase + 2*dotStep, 1, length(sb)), '.', ...
                'Color', diffColor, 'MarkerSize', 8);
        end

        title(areaLabels{REG}, 'FontSize', 11)
        if REG == 1 || REG == 5
            ylabel('Accuracy')
        end
        if REG >= 5
            xlabel(figSpecs(f).xLabel)
        end
%         set(gca, 'FontSize', 9)
%         ylim([0.4 0.75])
xlim([-600 1200])
% axis ([-600 1200 0.4 ylim(2)])
 xticks = [-600 :600:1200];
        yticks = [.4:0.05:1];

                set(gca, ...
                    'XTick', xticks, ...
                    'YTick', yticks, ...
                    'TickDir','out', ...
                    'FontSize',7);

        axis square
        grid off
    end

    sgtitle(figSpecs(f).title, 'FontSize', 14)
end
%% ══════════════════════════════════════════════════════════════════════
%  SUMMARY: Extract windowed mean accuracy per session/area/condition
% ══════════════════════════════════════════════════════════════════════

% ── MODIFIABLE WINDOW (bins) ──────────────────────────────────────────
winBins_Val = 27:39;   % ← MODIFY: bins for value window
winBins_Out = 30:40;   % ← MODIFY: bins for outcome window

% Storage: sessions × areas — separate for saccade and reach
Sum_Val_WithinEye = nan(length(Sessions), nAreas);
Sum_Val_WithinArm = nan(length(Sessions), nAreas);
Sum_Val_CrossAE   = nan(length(Sessions), nAreas);  % train Arm test Eye → saccade test
Sum_Val_CrossEA   = nan(length(Sessions), nAreas);  % train Eye test Arm → reach test

Sum_Out_WithinEye = nan(length(Sessions), nAreas);
Sum_Out_WithinArm = nan(length(Sessions), nAreas);
Sum_Out_CrossAE   = nan(length(Sessions), nAreas);
Sum_Out_CrossEA   = nan(length(Sessions), nAreas);

for REG = 1:nAreas
    for s = 1:length(Sessions)
        Sum_Val_WithinEye(s,REG) = nanmean(Acc_Val_WithinEye(s, winBins_Val, REG));
        Sum_Val_WithinArm(s,REG) = nanmean(Acc_Val_WithinArm(s, winBins_Val, REG));
        Sum_Val_CrossAE(s,REG)   = nanmean(Acc_Val_TrainArm_TestEye(s, winBins_Val, REG));
        Sum_Val_CrossEA(s,REG)   = nanmean(Acc_Val_TrainEye_TestArm(s, winBins_Val, REG));

        Sum_Out_WithinEye(s,REG) = nanmean(Acc_Out_WithinEye(s, winBins_Out, REG));
        Sum_Out_WithinArm(s,REG) = nanmean(Acc_Out_WithinArm(s, winBins_Out, REG));
        Sum_Out_CrossAE(s,REG)   = nanmean(Acc_Out_TrainArm_TestEye(s, winBins_Out, REG));
        Sum_Out_CrossEA(s,REG)   = nanmean(Acc_Out_TrainEye_TestArm(s, winBins_Out, REG));
    end
end

%% ══════════════════════════════════════════════════════════════════════
%  SCATTER PLOTS — y = within, x = cross
%  Saccade and Reach separate, Value and Outcome separate
% ══════════════════════════════════════════════════════════════════════

areaLabels = {'PMd','vlPFC','Put','Cd','lVS','mVS','GPi','Amy'};
Colors = [ [54 140 66]/255;
           [210 212 113]/255;
           [59 127 137]/255;
           [175 149 132]/255;
           [67 170 175]/255;
           [232 174 135]/255;
           [140 140 140]/255;
           [243 168 168]/255 ];

% ── VALUE scatter ─────────────────────────────────────────────────────
figure('Position', [100 100 700 300], 'Color', 'w')

scatterPanels = {
    Sum_Val_WithinEye, Sum_Val_CrossAE, 'Value — Saccade';
    Sum_Val_WithinArm, Sum_Val_CrossEA, 'Value — Reach'};

for p = 1:2
    subplot(1,2,p); hold on
    withinData = scatterPanels{p,1};
    crossData  = scatterPanels{p,2};

    plot([0.4 0.85], [0.4 0.85], 'k--', 'LineWidth', 2)

    legendStr = cell(nAreas,1);
    legendH   = gobjects(nAreas,1);

    for REG = 1:nAreas
        valid = find(~isnan(withinData(:,REG)) & ~isnan(crossData(:,REG)));
        if length(valid) < 3
            legendStr{REG} = areaLabels{REG};
            legendH(REG) = plot(NaN, NaN, 'o', 'Color', Colors(REG,:));
            continue
        end

        w = withinData(valid, REG);
        c = crossData(valid, REG);

        mw = nanmean(w); mc = nanmean(c);
        sw = nanstd(w)/sqrt(length(w));
        sc = nanstd(c)/sqrt(length(c));

        [~, pval] = ttest(w, c);
        stars = sigStars(pval);

        % x = cross, y = within
        legendH(REG) = errorbar(mc, mw, sw, sw, sc, sc, 'o', ...
            'Color', Colors(REG,:), 'MarkerFaceColor', Colors(REG,:), ...
            'MarkerSize', 10, 'LineWidth', 2.5, 'CapSize', 0);

        legendStr{REG} = [stars '  ' areaLabels{REG}];
    end

    xlabel('Cross-System Accuracy'); ylabel('Within-System Accuracy')
    title(scatterPanels{p,3})
    axis equal; xlim([0.5 0.75]); ylim([0.5 0.75])
    legend(legendH, legendStr, 'Location', 'southeast', 'FontSize', 9,'Box','off')
     xticks = [0.5:0.05:0.75];
        yticks =  [0.5:0.05:0.75];

                set(gca, ...
                    'XTick', xticks, ...
                    'YTick', yticks, ...
                    'TickDir','out', ...
                    'FontSize',9);

%     set(gca, 'FontSize', 12, 'Box', 'off')
end
sgtitle('Value: Within vs Cross-System Decoding')

% ── OUTCOME scatter ───────────────────────────────────────────────────
figure('Position', [100 100 1100 500], 'Color', 'w')

scatterPanels = {
    Sum_Out_WithinEye, Sum_Out_CrossAE, 'Outcome — Saccade';
    Sum_Out_WithinArm, Sum_Out_CrossEA, 'Outcome — Reach'};

for p = 1:2
    subplot(1,2,p); hold on
    withinData = scatterPanels{p,1};
    crossData  = scatterPanels{p,2};

    plot([0.4 0.85], [0.4 0.85], 'k--', 'LineWidth', 2)

    legendStr = cell(nAreas,1);
    legendH   = gobjects(nAreas,1);

    for REG = 1:nAreas
        valid = find(~isnan(withinData(:,REG)) & ~isnan(crossData(:,REG)));
        if length(valid) < 3
            legendStr{REG} = areaLabels{REG};
            legendH(REG) = plot(NaN, NaN, 'o', 'Color', Colors(REG,:));
            continue
        end

        w = withinData(valid, REG);
        c = crossData(valid, REG);

        mw = nanmean(w); mc = nanmean(c);
        sw = nanstd(w)/sqrt(length(w));
        sc = nanstd(c)/sqrt(length(c));

        [~, pval] = ttest(w, c);
        stars = sigStars(pval);

        legendH(REG) = errorbar(mc, mw, sw, sw, sc, sc, 'o', ...
            'Color', Colors(REG,:), 'MarkerFaceColor', Colors(REG,:), ...
            'MarkerSize', 10, 'LineWidth', 2.5, 'CapSize', 0);

        legendStr{REG} = [stars '  ' areaLabels{REG}];
    end

    xlabel('Cross-System Accuracy'); ylabel('Within-System Accuracy')
    title(scatterPanels{p,3})
    axis equal; xlim([0.4 0.85]); ylim([0.4 0.85])
    legend(legendH, legendStr, 'Location', 'southeast', 'FontSize', 9)
    set(gca, 'FontSize', 12, 'Box', 'on')
end
sgtitle('Outcome: Within vs Cross-System Decoding')

%%

%% ══════════════════════════════════════════════════════════════════════
%  ANOVAN — 4 separate analyses
%  Each: Condition (within vs cross) × Area, with MonkeySession blocking
%  1) Value — Saccade
%  2) Value — Reach
%  3) Outcome — Saccade
%  4) Outcome — Reach
% ══════════════════════════════════════════════════════════════════════

anovaSpecs = {
    Sum_Val_WithinEye, Sum_Val_CrossAE, 'Value — Saccade';
    Sum_Val_WithinArm, Sum_Val_CrossEA, 'Value — Reach';
    Sum_Out_WithinEye, Sum_Out_CrossAE, 'Outcome — Saccade';
    Sum_Out_WithinArm, Sum_Out_CrossEA, 'Outcome — Reach'};

for a = 1:2

    withinMat = anovaSpecs{a,1};  % sessions × areas
    crossMat  = anovaSpecs{a,2};
    anaName   = anovaSpecs{a,3};

    % ── Build long-format vectors ─────────────────────────────────────
    acc_vec   = [];
    cond_vec  = {};
    area_vec  = {};
    mSess_vec = {};

    for ar = 1:nAreas
        for s = 1:length(Sessions)

            if s <= 32
                monk = 'M1';
            else
                monk = 'M2';
            end
            sessLabel = sprintf('%s_S%02d', monk, s);

            % Within
            d1 = withinMat(s, ar);
            if ~isnan(d1)
                acc_vec(end+1)    = d1;
                cond_vec{end+1}   = 'Within';
                area_vec{end+1}   = areaLabels{ar};
                mSess_vec{end+1}  = sessLabel;
            end

            % Cross
            d2 = crossMat(s, ar);
            if ~isnan(d2)
                acc_vec(end+1)    = d2;
                cond_vec{end+1}   = 'Cross';
                area_vec{end+1}   = areaLabels{ar};
                mSess_vec{end+1}  = sessLabel;
            end
        end
    end

    % ── Data summary ──────────────────────────────────────────────────
    fprintf('\n══════════════════════════════════════════════════════\n')
    fprintf('  %s\n', anaName)
    fprintf('══════════════════════════════════════════════════════\n')
    fprintf('Total observations:  %d\n', length(acc_vec))
    fprintf('Within observations: %d\n', sum(strcmp(cond_vec, 'Within')))
    fprintf('Cross observations:  %d\n', sum(strcmp(cond_vec, 'Cross')))
    fprintf('\nObservations per area:\n')
    for ar = 1:nAreas
        n_w = sum(strcmp(area_vec, areaLabels{ar}) & strcmp(cond_vec, 'Within'));
        n_c = sum(strcmp(area_vec, areaLabels{ar}) & strcmp(cond_vec, 'Cross'));
        fprintf('  %-8s within=%d  cross=%d\n', areaLabels{ar}, n_w, n_c)
    end

    % ── ANOVAN ────────────────────────────────────────────────────────
    modelMatrix = [...
        1 0 0;   % Condition
        0 1 0;   % Area
        0 0 1;   % MonkeySession (blocking)
        1 1 0];  % Condition × Area

    [p_anovan, tbl_anovan, stats_anovan] = anovan(acc_vec', ...
        {cond_vec', area_vec', mSess_vec'}, ...
        'model',    modelMatrix, ...
        'varnames', {'Condition','Area','MonkeySession'}, ...
        'display',  'off');

    % ── Parse table ───────────────────────────────────────────────────
    p_cond = NaN; F_cond = NaN; df1_cond = NaN;
    p_area = NaN; F_area = NaN; df1_area = NaN;
    p_int  = NaN; F_int  = NaN; df1_int  = NaN;
    df_error = tbl_anovan{end-1, 3};

    for row = 2:size(tbl_anovan,1)-1
        tname = strtrim(tbl_anovan{row,1});
        if strcmpi(tname, 'Condition')
            F_cond = tbl_anovan{row,6}; p_cond = tbl_anovan{row,7}; df1_cond = tbl_anovan{row,3};
        elseif strcmpi(tname, 'Area')
            F_area = tbl_anovan{row,6}; p_area = tbl_anovan{row,7}; df1_area = tbl_anovan{row,3};
        elseif ~isempty(strfind(tname,'Condition')) && ~isempty(strfind(tname,'Area'))
            F_int = tbl_anovan{row,6}; p_int = tbl_anovan{row,7}; df1_int = tbl_anovan{row,3};
        end
    end

    fprintf('\n--- ANOVAN results ---\n')
    if ~isnan(F_cond)
        fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', 'Condition', df1_cond, df_error, F_cond, p_cond)
    end
    if ~isnan(F_area)
        fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', 'Area', df1_area, df_error, F_area, p_area)
    end
    if ~isnan(F_int)
        fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', 'Condition x Area', df1_int, df_error, F_int, p_int)
    end

    % ── Post-hoc: paired t-test per area ──────────────────────────────
    pvals_r      = nan(1, nAreas);
    tstats_r     = nan(1, nAreas);
    within_means = nan(1, nAreas);
    cross_means  = nan(1, nAreas);
    df_r         = nan(1, nAreas);

    for ar = 1:nAreas
        d1    = withinMat(:, ar);
        d2    = crossMat(:, ar);
        valid = ~isnan(d1) & ~isnan(d2);
        if sum(valid) < 1; continue; end

        [~, p, ~, stats] = ttest(d1(valid), d2(valid));
        pvals_r(ar)      = p;
        tstats_r(ar)     = stats.tstat;
        within_means(ar) = mean(d1(valid));
        cross_means(ar)  = mean(d2(valid));
        df_r(ar)         = stats.df;
    end

    pvals_bonf = min(pvals_r * nAreas, 1);

    if ~isnan(p_int) && p_int < 0.05

        fprintf('\n--- Post-hoc: Condition per area (Bonferroni) ---\n')
        fprintf('Interaction significant — testing within vs cross per area\n\n')
        fprintf('%-8s %12s %12s %10s %8s %10s %10s %8s\n', ...
            'Area','Within mean','Cross mean','t','df','p (raw)','p (Bonf)','sig')

        for ar = 1:nAreas
            if isnan(pvals_r(ar)); continue; end
            if pvals_bonf(ar) < 0.001;      sig = '***';
            elseif pvals_bonf(ar) < 0.01;   sig = '**';
            elseif pvals_bonf(ar) < 0.05;   sig = '*';
            else;                             sig = 'ns';
            end
            fprintf('%-8s %12.4f %12.4f %10.3f %8.0f %10.4f %10.4f %8s\n', ...
                areaLabels{ar}, within_means(ar), cross_means(ar), ...
                tstats_r(ar), df_r(ar), pvals_r(ar), pvals_bonf(ar), sig)
        end

    elseif ~isnan(p_cond) && p_cond < 0.05

        fprintf('\nCondition significant (p=%.4f), interaction not significant (p=%.4f)\n', ...
            p_cond, p_int)
        fprintf('Effect consistent across areas — no post-hoc needed.\n')
        fprintf('\nPer-area paired t-tests (uncorrected, descriptive only):\n')
        fprintf('%-8s %12s %12s %10s %8s %10s\n', ...
            'Area','Within mean','Cross mean','t','df','p (raw)')
        for ar = 1:nAreas
            if isnan(pvals_r(ar)); continue; end
            fprintf('%-8s %12.4f %12.4f %10.3f %8.0f %10.4f\n', ...
                areaLabels{ar}, within_means(ar), cross_means(ar), ...
                tstats_r(ar), df_r(ar), pvals_r(ar))
        end

    else
        fprintf('\nCondition not significant (p=%.4f) — no post-hoc conducted.\n', p_cond)
        fprintf('\nPer-area paired t-tests (uncorrected, descriptive only):\n')
        fprintf('%-8s %12s %12s %10s %8s %10s\n', ...
            'Area','Within mean','Cross mean','t','df','p (raw)')
        for ar = 1:nAreas
            if isnan(pvals_r(ar)); continue; end
            fprintf('%-8s %12.4f %12.4f %10.3f %8.0f %10.4f\n', ...
                areaLabels{ar}, within_means(ar), cross_means(ar), ...
                tstats_r(ar), df_r(ar), pvals_r(ar))
        end
    end

    % ── Descriptive summary ───────────────────────────────────────────
    fprintf('\n--- Descriptive summary ---\n')
    fprintf('%-8s %22s %22s %12s\n', 'Area','Within','Cross','Reduction')
    for ar = 1:nAreas
        d1 = withinMat(:,ar); d2 = crossMat(:,ar);
        valid = ~isnan(d1) & ~isnan(d2);
        if sum(valid) < 1; continue; end
        m1 = mean(d1(valid)); sem1 = std(d1(valid))/sqrt(sum(valid));
        m2 = mean(d2(valid)); sem2 = std(d2(valid))/sqrt(sum(valid));
        red = (m1 - m2)/m1 * 100;
        fprintf('%-8s %10.4f +- %6.4f %10.4f +- %6.4f %10.1f%%\n', ...
            areaLabels{ar}, m1, sem1, m2, sem2, red)
    end

    fprintf('\nOverall:\n')
    fprintf('  Within:    %.4f +- %.4f\n', ...
        mean(within_means,'omitnan'), std(within_means,'omitnan')/sqrt(sum(~isnan(within_means))))
    fprintf('  Cross:     %.4f +- %.4f\n', ...
        mean(cross_means,'omitnan'), std(cross_means,'omitnan')/sqrt(sum(~isnan(cross_means))))
    fprintf('  Reduction: %.1f%%\n', ...
        mean((within_means-cross_means)./within_means*100,'omitnan'))

end % 4 ANOVAs

%%

%% ══════════════════════════════════════════════════════════════════════
%  SCATTER PLOTS + ANOVAN — Separated by monkey
%  M1 = sessions 1:32, M2 = sessions 33:50
% ══════════════════════════════════════════════════════════════════════

monkeyIdx = {1:32, 33:length(Sessions)};
monkeyNames = {'M1', 'M2'};

for mk = 1:2
    mSess = monkeyIdx{mk};
    mName = monkeyNames{mk};

    % ── Extract windowed summaries for this monkey ────────────────────
    mSum_Val_WithinEye = Sum_Val_WithinEye(mSess, :);
    mSum_Val_WithinArm = Sum_Val_WithinArm(mSess, :);
    mSum_Val_CrossAE   = Sum_Val_CrossAE(mSess, :);
    mSum_Val_CrossEA   = Sum_Val_CrossEA(mSess, :);
    mSum_Out_WithinEye = Sum_Out_WithinEye(mSess, :);
    mSum_Out_WithinArm = Sum_Out_WithinArm(mSess, :);
    mSum_Out_CrossAE   = Sum_Out_CrossAE(mSess, :);
    mSum_Out_CrossEA   = Sum_Out_CrossEA(mSess, :);

    % ── VALUE scatter ─────────────────────────────────────────────────
    figure('Position', [100+300*(mk-1) 100 700 300], 'Color', 'w')

    scatterPanels = {
        mSum_Val_WithinEye, mSum_Val_CrossAE, ['Value — Saccade (' mName ')'];
        mSum_Val_WithinArm, mSum_Val_CrossEA, ['Value — Reach (' mName ')']};

    for p = 1:2
        subplot(1,2,p); hold on
        withinData = scatterPanels{p,1};
        crossData  = scatterPanels{p,2};

        plot([0.4 0.85], [0.4 0.85], 'k--', 'LineWidth', 2)

        legendStr = cell(nAreas,1);
        legendH   = gobjects(nAreas,1);

        for REG = 1:nAreas
            valid = find(~isnan(withinData(:,REG)) & ~isnan(crossData(:,REG)));
            if length(valid) < 3
                legendStr{REG} = areaLabels{REG};
                legendH(REG) = plot(NaN, NaN, 'o', 'Color', Colors(REG,:));
                continue
            end

            w = withinData(valid, REG);
            c = crossData(valid, REG);
            mw = nanmean(w); mc = nanmean(c);
            sw = nanstd(w)/sqrt(length(w));
            sc = nanstd(c)/sqrt(length(c));

            [~, pval] = ttest(w, c);
            stars = sigStars(pval);

            legendH(REG) = errorbar(mc, mw, sw, sw, sc, sc, 'o', ...
                'Color', Colors(REG,:), 'MarkerFaceColor', Colors(REG,:), ...
                'MarkerSize', 10, 'LineWidth', 2.5, 'CapSize', 0);
            legendStr{REG} = [stars '  ' areaLabels{REG}];
        end

        xlabel('Cross-System Accuracy'); ylabel('Within-System Accuracy')
        title(scatterPanels{p,3})
        legend(legendH, legendStr, 'Location', 'southeast', 'FontSize', 9,'Box','off')
        
        
        if mk==1
        axis equal; xlim([0.4 0.8]); ylim([0.4 0.8])
        set(gca, 'FontSize', 12, 'Box', 'off')
        xticks = [-.4:.1:.8 ];
        yticks = [-.4:.1:.8];

                set(gca, ...
                    'XTick', xticks, ...
                    'YTick', yticks, ...
                    'TickDir','out', ...
                    'FontSize',10, ...
                    'Box', 'off');

        axis square
        grid off
        elseif mk==2
        axis equal; xlim([0.4 0.7]); ylim([0.4 0.7])
        set(gca, 'FontSize', 12, 'Box', 'off')
        xticks = [-.4:.1:.7 ];
        yticks = [-.4:.1:.7];

                set(gca, ...
                    'XTick', xticks, ...
                    'YTick', yticks, ...
                    'TickDir','out', ...
                    'FontSize',10, ...
                    'Box', 'off');
        axis square
        grid off
        end
    end
    sgtitle([mName ' — Value: Within vs Cross-System Decoding'])

    % ── OUTCOME scatter ───────────────────────────────────────────────
    figure('Position', [100+300*(mk-1) 100 1100 500], 'Color', 'w')

    scatterPanels = {
        mSum_Out_WithinEye, mSum_Out_CrossAE, ['Outcome — Saccade (' mName ')'];
        mSum_Out_WithinArm, mSum_Out_CrossEA, ['Outcome — Reach (' mName ')']};

    for p = 1:2
        subplot(1,2,p); hold on
        withinData = scatterPanels{p,1};
        crossData  = scatterPanels{p,2};

        plot([0.4 0.85], [0.4 0.85], 'k--', 'LineWidth', 2)

        legendStr = cell(nAreas,1);
        legendH   = gobjects(nAreas,1);

        for REG = 1:nAreas
            valid = find(~isnan(withinData(:,REG)) & ~isnan(crossData(:,REG)));
            if length(valid) < 3
                legendStr{REG} = areaLabels{REG};
                legendH(REG) = plot(NaN, NaN, 'o', 'Color', Colors(REG,:));
                continue
            end

            w = withinData(valid, REG);
            c = crossData(valid, REG);
            mw = nanmean(w); mc = nanmean(c);
            sw = nanstd(w)/sqrt(length(w));
            sc = nanstd(c)/sqrt(length(c));

            [~, pval] = ttest(w, c);
            stars = sigStars(pval);

            legendH(REG) = errorbar(mc, mw, sw, sw, sc, sc, 'o', ...
                'Color', Colors(REG,:), 'MarkerFaceColor', Colors(REG,:), ...
                'MarkerSize', 10, 'LineWidth', 2.5, 'CapSize', 0);
            legendStr{REG} = [stars '  ' areaLabels{REG}];
        end

        xlabel('Cross-System Accuracy'); ylabel('Within-System Accuracy')
        title(scatterPanels{p,3})
        axis equal; xlim([0.4 0.85]); ylim([0.4 0.85])
        legend(legendH, legendStr, 'Location', 'southeast', 'FontSize', 9)
        set(gca, 'FontSize', 12, 'Box', 'on')
    end
    sgtitle([mName ' — Outcome: Within vs Cross-System Decoding'])

    % ══════════════════════════════════════════════════════════════════
    %  ANOVAN for this monkey — 4 analyses
    % ══════════════════════════════════════════════════════════════════

    anovaSpecs = {
        mSum_Val_WithinEye, mSum_Val_CrossAE, [mName ' — Value — Saccade'];
        mSum_Val_WithinArm, mSum_Val_CrossEA, [mName ' — Value — Reach']};
%         mSum_Out_WithinEye, mSum_Out_CrossAE, [mName ' — Outcome — Saccade'];
%         mSum_Out_WithinArm, mSum_Out_CrossEA, [mName ' — Outcome — Reach']};

    for a = 1:2 % 1:4 if I add the outcome
        withinMat = anovaSpecs{a,1};
        crossMat  = anovaSpecs{a,2};
        anaName   = anovaSpecs{a,3};

        acc_vec  = [];
        cond_vec = {};
        area_vec = {};
        sess_vec = {};

        for ar = 1:nAreas
            for si = 1:length(mSess)
                s = mSess(si);
                sessLabel = sprintf('%s_S%02d', mName, s);

                d1 = withinMat(si, ar);
                if ~isnan(d1)
                    acc_vec(end+1)   = d1;
                    cond_vec{end+1}  = 'Within';
                    area_vec{end+1}  = areaLabels{ar};
                    sess_vec{end+1}  = sessLabel;
                end

                d2 = crossMat(si, ar);
                if ~isnan(d2)
                    acc_vec(end+1)   = d2;
                    cond_vec{end+1}  = 'Cross';
                    area_vec{end+1}  = areaLabels{ar};
                    sess_vec{end+1}  = sessLabel;
                end
            end
        end

        fprintf('\n══════════════════════════════════════════════════════\n')
        fprintf('  %s\n', anaName)
        fprintf('══════════════════════════════════════════════════════\n')
        fprintf('Total observations:  %d\n', length(acc_vec))
        fprintf('Within observations: %d\n', sum(strcmp(cond_vec, 'Within')))
        fprintf('Cross observations:  %d\n', sum(strcmp(cond_vec, 'Cross')))

        % ANOVAN: Condition × Area + Session blocking
        modelMatrix = [1 0 0; 0 1 0; 0 0 1; 1 1 0];

        [p_anovan, tbl_anovan, ~] = anovan(acc_vec', ...
            {cond_vec', area_vec', sess_vec'}, ...
            'model', modelMatrix, ...
            'varnames', {'Condition','Area','Session'}, ...
            'display', 'off');

        % Parse
        p_cond = NaN; F_cond = NaN; df1_cond = NaN;
        p_area = NaN; F_area = NaN; df1_area = NaN;
        p_int  = NaN; F_int  = NaN; df1_int  = NaN;
        df_error = tbl_anovan{end-1, 3};

        for row = 2:size(tbl_anovan,1)-1
            tname = strtrim(tbl_anovan{row,1});
            if strcmpi(tname, 'Condition')
                F_cond = tbl_anovan{row,6}; p_cond = tbl_anovan{row,7}; df1_cond = tbl_anovan{row,3};
            elseif strcmpi(tname, 'Area')
                F_area = tbl_anovan{row,6}; p_area = tbl_anovan{row,7}; df1_area = tbl_anovan{row,3};
            elseif ~isempty(strfind(tname,'Condition')) && ~isempty(strfind(tname,'Area'))
                F_int = tbl_anovan{row,6}; p_int = tbl_anovan{row,7}; df1_int = tbl_anovan{row,3};
            end
        end

        fprintf('\n--- ANOVAN results ---\n')
        if ~isnan(F_cond)
            fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', 'Condition', df1_cond, df_error, F_cond, p_cond)
        end
        if ~isnan(F_area)
            fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', 'Area', df1_area, df_error, F_area, p_area)
        end
        if ~isnan(F_int)
            fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', 'Condition x Area', df1_int, df_error, F_int, p_int)
        end

        % Post-hoc per area
        pvals_r = nan(1, nAreas);
        tstats_r = nan(1, nAreas);
        within_means = nan(1, nAreas);
        cross_means  = nan(1, nAreas);
        df_r = nan(1, nAreas);

        for ar = 1:nAreas
            d1 = withinMat(:, ar);
            d2 = crossMat(:, ar);
            valid = ~isnan(d1) & ~isnan(d2);
            if sum(valid) < 1; continue; end
            [~, pp, ~, stats] = ttest(d1(valid), d2(valid));
            pvals_r(ar)      = pp;
            tstats_r(ar)     = stats.tstat;
            within_means(ar) = mean(d1(valid));
            cross_means(ar)  = mean(d2(valid));
            df_r(ar)         = stats.df;
        end

        pvals_bonf = min(pvals_r * nAreas, 1);

        if ~isnan(p_int) && p_int < 0.05
            fprintf('\n--- Post-hoc: Condition per area (Bonferroni) ---\n')
            fprintf('%-8s %12s %12s %10s %8s %10s %10s %8s\n', ...
                'Area','Within','Cross','t','df','p(raw)','p(Bonf)','sig')
            for ar = 1:nAreas
                if isnan(pvals_r(ar)); continue; end
                fprintf('%-8s %12.4f %12.4f %10.3f %8.0f %10.4f %10.4f %8s\n', ...
                    areaLabels{ar}, within_means(ar), cross_means(ar), ...
                    tstats_r(ar), df_r(ar), pvals_r(ar), pvals_bonf(ar), sigStars(pvals_bonf(ar)))
            end
        elseif ~isnan(p_cond) && p_cond < 0.05
            fprintf('\nCondition significant (p=%.4f), interaction n.s. (p=%.4f)\n', p_cond, p_int)
            fprintf('%-8s %12s %12s %10s %8s %10s\n', 'Area','Within','Cross','t','df','p(raw)')
            for ar = 1:nAreas
                if isnan(pvals_r(ar)); continue; end
                fprintf('%-8s %12.4f %12.4f %10.3f %8.0f %10.4f\n', ...
                    areaLabels{ar}, within_means(ar), cross_means(ar), ...
                    tstats_r(ar), df_r(ar), pvals_r(ar))
            end
        else
            fprintf('\nCondition n.s. (p=%.4f)\n', p_cond)
            fprintf('%-8s %12s %12s %10s %8s %10s\n', 'Area','Within','Cross','t','df','p(raw)')
            for ar = 1:nAreas
                if isnan(pvals_r(ar)); continue; end
                fprintf('%-8s %12.4f %12.4f %10.3f %8.0f %10.4f\n', ...
                    areaLabels{ar}, within_means(ar), cross_means(ar), ...
                    tstats_r(ar), df_r(ar), pvals_r(ar))
            end
        end

        % Descriptive
        fprintf('\n--- Descriptive ---\n')
        fprintf('%-8s %22s %22s %12s\n', 'Area','Within','Cross','Reduction')
        for ar = 1:nAreas
            d1 = withinMat(:,ar); d2 = crossMat(:,ar);
            valid = ~isnan(d1) & ~isnan(d2);
            if sum(valid) < 1; continue; end
            m1 = mean(d1(valid)); sem1 = std(d1(valid))/sqrt(sum(valid));
            m2 = mean(d2(valid)); sem2 = std(d2(valid))/sqrt(sum(valid));
            red = (m1-m2)/m1*100;
            fprintf('%-8s %10.4f +- %6.4f %10.4f +- %6.4f %10.1f%%\n', ...
                areaLabels{ar}, m1, sem1, m2, sem2, red)
        end
    end
end


%% %% ----------------------------------------------------
%% ══════════════════════════════════════════════════════════════════════
%  SVM DECODING — Similar behavior sessions
%  Scatter plots + subset ANOVAN + full-dataset ANOVAN with BehavSimilarity
% ══════════════════════════════════════════════════════════════════════

Sim_behavSess = [4, 5, 15, 34, 39, 40, 50];

% ── Extract summaries for selected sessions ───────────────────────────
Sub_Val_WithinEye = Sum_Val_WithinEye(Sim_behavSess, :);
Sub_Val_WithinArm = Sum_Val_WithinArm(Sim_behavSess, :);
Sub_Val_CrossAE   = Sum_Val_CrossAE(Sim_behavSess, :);
Sub_Val_CrossEA   = Sum_Val_CrossEA(Sim_behavSess, :);

% ══════════════════════════════════════════════════════════════════════
%  SCATTER PLOTS — Selected sessions only
% ══════════════════════════════════════════════════════════════════════
figure('Position', [100 100 700 300], 'Color', 'w')

scatterPanels = {
    Sub_Val_WithinEye, Sub_Val_CrossAE, 'Value — Saccade (sim. behav.)';
    Sub_Val_WithinArm, Sub_Val_CrossEA, 'Value — Reach (sim. behav.)'};

for p = 1:2
    subplot(1,2,p); hold on
    withinData = scatterPanels{p,1};
    crossData  = scatterPanels{p,2};

    plot([0.4 0.85], [0.4 0.85], 'k--', 'LineWidth', 2)

    legendStr = cell(nAreas,1);
    legendH   = gobjects(nAreas,1);

    for REG = 1:nAreas
        valid = find(~isnan(withinData(:,REG)) & ~isnan(crossData(:,REG)));
        if length(valid) < 1
            legendStr{REG} = areaLabels{REG};
            legendH(REG) = plot(NaN, NaN, 'o', 'Color', Colors(REG,:));
            continue
        end

        w = withinData(valid, REG);
        c = crossData(valid, REG);
        mw = nanmean(w); mc = nanmean(c);
        sw = nanstd(w)/sqrt(length(w));
        sc = nanstd(c)/sqrt(length(c));

        if length(valid) >= 2
            [~, pval] = ttest(w, c);
            stars = sigStars(pval);
        else
            stars = '';
        end

        legendH(REG) = errorbar(mc, mw, sw, sw, sc, sc, 'o', ...
            'Color', Colors(REG,:), 'MarkerFaceColor', Colors(REG,:), ...
            'MarkerSize', 10, 'LineWidth', 2.5, 'CapSize', 0);
        legendStr{REG} = [stars '  ' areaLabels{REG}];
    end

    xlabel('Cross-System Accuracy'); ylabel('Within-System Accuracy')
    title(scatterPanels{p,3})
    axis equal; xlim([0.45 0.7]); ylim([0.45 0.7])
    legend(legendH, legendStr, 'Location', 'southeast', 'FontSize', 9, 'Box', 'off')
    set(gca, 'XTick', 0.45:0.05:0.75, 'YTick', 0.45:0.05:0.75, ...
        'TickDir', 'out', 'FontSize', 9)
    axis square; grid off
end
sgtitle(sprintf('Value decoding — similar behavior sessions %s', mat2str(Sim_behavSess)))

% ══════════════════════════════════════════════════════════════════════
%  ANOVAN — Selected sessions only (saccade and reach separate)
% ══════════════════════════════════════════════════════════════════════

anovaSpecs_sub = {
    Sub_Val_WithinEye, Sub_Val_CrossAE, 'Value — Saccade (sim. behav.)';
    Sub_Val_WithinArm, Sub_Val_CrossEA, 'Value — Reach (sim. behav.)'};

for a = 1:2
    withinMat = anovaSpecs_sub{a,1};
    crossMat  = anovaSpecs_sub{a,2};
    anaName   = anovaSpecs_sub{a,3};

    acc_vec   = [];
    cond_vec  = {};
    area_vec  = {};
    mSess_vec = {};

    for ar = 1:nAreas
        for si = 1:length(Sim_behavSess)
            s = Sim_behavSess(si);

            if s <= 32; monk = 'M1'; else; monk = 'M2'; end
            sessLabel = sprintf('%s_S%02d', monk, s);

            d1 = withinMat(si, ar);
            if ~isnan(d1)
                acc_vec(end+1)    = d1;
                cond_vec{end+1}   = 'Within';
                area_vec{end+1}   = areaLabels{ar};
                mSess_vec{end+1}  = sessLabel;
            end

            d2 = crossMat(si, ar);
            if ~isnan(d2)
                acc_vec(end+1)    = d2;
                cond_vec{end+1}   = 'Cross';
                area_vec{end+1}   = areaLabels{ar};
                mSess_vec{end+1}  = sessLabel;
            end
        end
    end

    fprintf('\n══════════════════════════════════════════════════════\n')
    fprintf('  %s\n', anaName)
    fprintf('══════════════════════════════════════════════════════\n')
    fprintf('Sessions: %s\n', mat2str(Sim_behavSess))
    fprintf('Total observations:  %d\n', length(acc_vec))
    fprintf('Within observations: %d\n', sum(strcmp(cond_vec, 'Within')))
    fprintf('Cross observations:  %d\n', sum(strcmp(cond_vec, 'Cross')))

    modelMatrix = [1 0 0; 0 1 0; 0 0 1; 1 1 0];

    [p_anovan_sub, tbl_anovan_sub, ~] = anovan(acc_vec', ...
        {cond_vec', area_vec', mSess_vec'}, ...
        'model', modelMatrix, ...
        'varnames', {'Condition','Area','MonkeySession'}, ...
        'display', 'off');

    p_cond_s = NaN; F_cond_s = NaN; df1_cond_s = NaN;
    p_area_s = NaN; F_area_s = NaN; df1_area_s = NaN;
    p_int_s  = NaN; F_int_s  = NaN; df1_int_s  = NaN;
    df_error_s = tbl_anovan_sub{end-1, 3};

    for row = 2:size(tbl_anovan_sub,1)-1
        tname = strtrim(tbl_anovan_sub{row,1});
        if strcmpi(tname, 'Condition')
            F_cond_s = tbl_anovan_sub{row,6}; p_cond_s = tbl_anovan_sub{row,7}; df1_cond_s = tbl_anovan_sub{row,3};
        elseif strcmpi(tname, 'Area')
            F_area_s = tbl_anovan_sub{row,6}; p_area_s = tbl_anovan_sub{row,7}; df1_area_s = tbl_anovan_sub{row,3};
        elseif ~isempty(strfind(tname,'Condition')) && ~isempty(strfind(tname,'Area'))
            F_int_s = tbl_anovan_sub{row,6}; p_int_s = tbl_anovan_sub{row,7}; df1_int_s = tbl_anovan_sub{row,3};
        end
    end

    fprintf('\n--- ANOVAN results ---\n')
    if ~isnan(F_cond_s)
        fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', 'Condition', df1_cond_s, df_error_s, F_cond_s, p_cond_s)
    end
    if ~isnan(F_area_s)
        fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', 'Area', df1_area_s, df_error_s, F_area_s, p_area_s)
    end
    if ~isnan(F_int_s)
        fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', 'Condition x Area', df1_int_s, df_error_s, F_int_s, p_int_s)
    end

    % Post-hoc
    pvals_sub = nan(1, nAreas);
    within_means_s = nan(1, nAreas);
    cross_means_s  = nan(1, nAreas);

    for ar = 1:nAreas
        d1 = withinMat(:, ar); d2 = crossMat(:, ar);
        valid = ~isnan(d1) & ~isnan(d2);
        if sum(valid) < 1; continue; end
        [~, pp, ~, stats] = ttest(d1(valid), d2(valid));
        pvals_sub(ar) = pp;
        within_means_s(ar) = mean(d1(valid));
        cross_means_s(ar)  = mean(d2(valid));
    end

    pvals_bonf_sub = min(pvals_sub * nAreas, 1);

    if ~isnan(p_cond_s) && p_cond_s < 0.05
        fprintf('\nCondition significant (p=%.4f)\n', p_cond_s)
        fprintf('%-8s %12s %12s %10s %8s\n', 'Area','Within','Cross','p(raw)','sig')
        for ar = 1:nAreas
            if isnan(pvals_sub(ar)); continue; end
            fprintf('%-8s %12.4f %12.4f %10.4f %8s\n', ...
                areaLabels{ar}, within_means_s(ar), cross_means_s(ar), ...
                pvals_sub(ar), sigStars(pvals_sub(ar)))
        end
    else
        fprintf('\nCondition not significant (p=%.4f)\n', p_cond_s)
    end

    % Descriptive
    fprintf('\n--- Descriptive ---\n')
    fprintf('%-8s %22s %22s %12s\n', 'Area','Within','Cross','Reduction')
    match_desc = nan(1, nAreas);
    cross_desc = nan(1, nAreas);
    for ar = 1:nAreas
        d1 = withinMat(:,ar); d2 = crossMat(:,ar);
        valid = ~isnan(d1) & ~isnan(d2);
        if sum(valid) < 1; continue; end
        m1 = mean(d1(valid)); sem1 = std(d1(valid))/sqrt(sum(valid));
        m2 = mean(d2(valid)); sem2 = std(d2(valid))/sqrt(sum(valid));
        match_desc(ar) = m1; cross_desc(ar) = m2;
        red = (m1-m2)/m1*100;
        fprintf('%-8s %10.4f +- %6.4f %10.4f +- %6.4f %10.1f%%\n', ...
            areaLabels{ar}, m1, sem1, m2, sem2, red)
    end
    fprintf('\nOverall:\n')
    fprintf('  Within: %.4f +- %.4f\n', ...
        mean(match_desc,'omitnan'), std(match_desc,'omitnan')/sqrt(sum(~isnan(match_desc))))
    fprintf('  Cross:  %.4f +- %.4f\n', ...
        mean(cross_desc,'omitnan'), std(cross_desc,'omitnan')/sqrt(sum(~isnan(cross_desc))))
end

% ══════════════════════════════════════════════════════════════════════
%  ANOVAN — Full dataset with BehavSimilarity factor
%  Saccade and Reach separate
%  Factors: Condition, BehavSimilarity, Area, Monkey (blocking)
% ══════════════════════════════════════════════════════════════════════

anovaSpecs_full = {
    Sum_Val_WithinEye, Sum_Val_CrossAE, 'Value — Saccade (BehavSimilarity)';
    Sum_Val_WithinArm, Sum_Val_CrossEA, 'Value — Reach (BehavSimilarity)'};

for a = 1:2
    withinMat = anovaSpecs_full{a,1};
    crossMat  = anovaSpecs_full{a,2};
    anaName   = anovaSpecs_full{a,3};

    acc_vec_bs   = [];
    cond_vec_bs  = {};
    area_vec_bs  = {};
    behav_vec_bs = {};
    monk_vec_bs  = {};

    for ar = 1:nAreas
        for s = 1:size(withinMat, 1)

            if s <= 32; monkLabel = 'M1'; else; monkLabel = 'M2'; end

            if ismember(s, Sim_behavSess)
                behavLabel = 'Similar';
            else
                behavLabel = 'Different';
            end

            d1 = withinMat(s, ar);
            if ~isnan(d1)
                acc_vec_bs(end+1)    = d1;
                cond_vec_bs{end+1}   = 'Within';
                area_vec_bs{end+1}   = areaLabels{ar};
                behav_vec_bs{end+1}  = behavLabel;
                monk_vec_bs{end+1}   = monkLabel;
            end

            d2 = crossMat(s, ar);
            if ~isnan(d2)
                acc_vec_bs(end+1)    = d2;
                cond_vec_bs{end+1}   = 'Cross';
                area_vec_bs{end+1}   = areaLabels{ar};
                behav_vec_bs{end+1}  = behavLabel;
                monk_vec_bs{end+1}   = monkLabel;
            end
        end
    end

    fprintf('\n══════════════════════════════════════════════════════\n')
    fprintf('  %s\n', anaName)
    fprintf('══════════════════════════════════════════════════════\n')
    fprintf('Total observations:   %d\n', length(acc_vec_bs))
    fprintf('Within observations:  %d\n', sum(strcmp(cond_vec_bs, 'Within')))
    fprintf('Cross observations:   %d\n', sum(strcmp(cond_vec_bs, 'Cross')))
    fprintf('Similar sessions:     %d\n', sum(strcmp(behav_vec_bs, 'Similar')))
    fprintf('Different sessions:   %d\n', sum(strcmp(behav_vec_bs, 'Different')))

    modelMatrix_bs = [...
        1 0 0 0;   % Condition
        0 1 0 0;   % BehavSimilarity
        0 0 1 0;   % Area
        0 0 0 1;   % Monkey (blocking)
        1 1 0 0;   % Condition × BehavSimilarity
        1 0 1 0];  % Condition × Area

    [p_bs, tbl_bs, ~] = anovan(acc_vec_bs', ...
        {cond_vec_bs', behav_vec_bs', area_vec_bs', monk_vec_bs'}, ...
        'model', modelMatrix_bs, ...
        'varnames', {'Condition','BehavSimilarity','Area','Monkey'}, ...
        'display', 'off');

    df_err_bs = tbl_bs{end-1, 3};

    fprintf('\n--- ANOVAN results ---\n')
    for row = 2:size(tbl_bs,1)-1
        tname = strtrim(tbl_bs{row,1});
        F_val = tbl_bs{row,6};
        p_val = tbl_bs{row,7};
        df1   = tbl_bs{row,3};
        if ~isnan(F_val)
            fprintf('%-30s F(%d,%d) = %.3f, p = %.4f\n', ...
                tname, df1, df_err_bs, F_val, p_val)
        end
    end

    % Descriptive by behavioral similarity
    fprintf('\nPer-area descriptive by behavioral similarity:\n')
    for bv = {'Similar', 'Different'}
        fprintf('\n  %s sessions:\n', bv{1})
        fprintf('  %-8s %12s %12s %12s\n', 'Area', 'Within', 'Cross', 'Reduction')

        if strcmp(bv{1}, 'Similar')
            sessSet = Sim_behavSess;
        else
            sessSet = setdiff(1:size(withinMat,1), Sim_behavSess);
        end

        match_means_bv = nan(1, nAreas);
        cross_means_bv = nan(1, nAreas);

        for ar = 1:nAreas
            d1 = withinMat(sessSet, ar);
            d2 = crossMat(sessSet, ar);
            valid = ~isnan(d1) & ~isnan(d2);
            if sum(valid) < 1; continue; end
            mm = mean(d1(valid)); mc = mean(d2(valid));
            match_means_bv(ar) = mm;
            cross_means_bv(ar) = mc;
            red = (mm - mc) / mm * 100;
            fprintf('  %-8s %10.4f +- %6.4f %10.4f +- %6.4f %10.1f%%\n', ...
                areaLabels{ar}, mm, std(d1(valid))/sqrt(sum(valid)), ...
                mc, std(d2(valid))/sqrt(sum(valid)), red)
        end

        fprintf('  Overall (mean of area means):\n')
        fprintf('    Within: %.4f +- %.4f\n', ...
            mean(match_means_bv,'omitnan'), std(match_means_bv,'omitnan')/sqrt(sum(~isnan(match_means_bv))))
        fprintf('    Cross:  %.4f +- %.4f\n', ...
            mean(cross_means_bv,'omitnan'), std(cross_means_bv,'omitnan')/sqrt(sum(~isnan(cross_means_bv))))
    end
end

fprintf('\nSVM decoding behavioral similarity analysis done.\n')


%%
% ══════════════════════════════════════════════════════════════════════
% FUNCTIONS
% ══════════════════════════════════════════════════════════════════════

function acc = SVMWithinDecode(Data, Labels)
% 10-fold cross-validated SVM (linear kernel, uniform prior)
% Data: trials × neurons, Labels: trials × 1 (0/1)
    try
        Mdl = fitcsvm(Data, Labels, 'Prior', 'uniform', ...
            'KernelFunction', 'linear', 'KFold', 10);
        acc = 1 - kfoldLoss(Mdl);
    catch
        acc = NaN;
    end
end

function acc = SVMCrossDecode(TrainData, TrainLabels, TestData, TestLabels)
% Train on one system, test on the other. No CV — full train/test split.
% Data: trials × neurons, Labels: trials × 1 (0/1)
    try
        Mdl = fitcsvm(TrainData, TrainLabels, 'Prior', 'uniform', ...
            'KernelFunction', 'linear');
        pred = predict(Mdl, TestData);
        acc  = mean(pred == TestLabels);
    catch
        acc = NaN;
    end
end



%% ----------------------------------------------------------------------------------------------------------

function s = sigStars(p)
    if p < 0.001
        s = '***';
    elseif p < 0.01
        s = '**';
    elseif p < 0.05
        s = '*';
    else
        s = 'n.s.';
    end
end
%% ══════════════════════════════════════════════════════════════════════
%  HELPER: filter isolated significant bins
% ══════════════════════════════════════════════════════════════════════
function mask = filterConsec(mask_in, minRun)
    mask = false(size(mask_in));
    d = diff([0 mask_in(:)' 0]);
    starts = find(d == 1);
    ends   = find(d == -1) - 1;
    for r = 1:length(starts)
        if (ends(r) - starts(r) + 1) >= minRun
            mask(starts(r):ends(r)) = true;
        end
    end
end