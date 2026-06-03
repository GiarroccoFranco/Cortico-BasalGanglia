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

keyboard

%%
% ══════════════════════════════════════════════════════════════════════
% HELPER
% ══════════════════════════════════════════════════════════════════════
fold = @(theta) min(theta, 180 - theta);

% ══════════════════════════════════════════════════════════════════════
% SINGLE SESSION ANGLES
% ══════════════════════════════════════════════════════════════════════
nSess   = size(Ortgn, 1);
nAngles = 4;

AngleMean_sess = nan(nAngles, nAreas);
AngleSEM_sess  = nan(nAngles, nAreas);
Angles_sess    = nan(nSess, nAngles, nAreas);

for ar = 1:nAreas
    for ag = 1:nAngles

        dots  = Ortgn(:, ag, ar);
        valid = ~isnan(dots);
        if ~any(valid); continue; end

        % Clamp to [-1 1] for numerical safety
        dots_cl      = min(max(dots(valid), -1), 1);

        % Convert to angle then fold to [0 90]
        theta        = acosd(dots_cl);
%          theta_folded = theta;
        theta_folded = fold(theta);
        %%% Uncomment this to have angles
%         in the 0-90 range

        % Store per-session folded angles
        tmp = nan(nSess, 1);
        tmp(valid) = theta_folded;
        Angles_sess(:, ag, ar) = tmp;

        % Average folded angles
        AngleMean_sess(ag, ar) = mean(theta_folded);
        AngleSEM_sess(ag, ar)  = std(theta_folded) / sqrt(sum(valid));
    end
end

% ══════════════════════════════════════════════════════════════════════
% CONCATENATE ACROSS SESSIONS
% ══════════════════════════════════════════════════════════════════════
nNeuMax = size(All_Vectors, 1);
newN    = nNeuMax * nSess;

All_Dim_concat = nan(newN, 4, nAreas);
Sig_Neu_concat = nan(newN, 4, nAreas);

rowStart = 1;
for s = 1:nSess
    All_Dim_concat(rowStart:rowStart+nNeuMax-1, :, :) = All_Vectors(:,:,:,s);
    Sig_Neu_concat(rowStart:rowStart+nNeuMax-1, :, :) = Sig_Neurons(:,:,:,s);
    rowStart = rowStart + nNeuMax;
end

% ══════════════════════════════════════════════════════════════════════
% PSEUDO-POPULATION BOOTSTRAP
% ══════════════════════════════════════════════════════════════════════
nBoot  = 1000;
nPools = 3;

% Angle definitions [col_a, col_b]
% Col 1 = Value saccade
% Col 2 = Value reach
% Col 3 = Outcome saccade
% Col 4 = Outcome reach
angleDefs = [1 3;   % within-saccade: value vs outcome
             2 4;   % within-reach:   value vs outcome
             1 2;   % cross-system:   value
             3 4];  % cross-system:   outcome

angleBoot_all    = nan(nAreas, nAngles, nBoot);
angleBoot_coding = nan(nAreas, nAngles, nBoot);
angleBoot_shared = nan(nAreas, nAngles, nBoot);

for ar = 1:nAreas

    M = All_Dim_concat(:, :, ar);
    N = Sig_Neu_concat(:, :, ar);

    % Remove padding rows
    validRows = ~all(isnan(M), 2);
    Mclean    = M(validRows, :);
    Nclean    = N(validRows, :);
    nNeu_     = size(Mclean, 1);

    for ag = 1:nAngles

        col_a = angleDefs(ag, 1);
        col_b = angleDefs(ag, 2);

        % Significant neuron pools for this angle
        idx_a_sig = find(Nclean(:, col_a) == 1);
        idx_b_sig = find(Nclean(:, col_b) == 1);
        idx_union = union(idx_a_sig, idx_b_sig);
        idx_inter = intersect(idx_a_sig, idx_b_sig);

        for b = 1:nBoot

            % ── Pool 1: All neurons ────────────────────────────────────
            idx = randi(nNeu_, nNeu_, 1);
            Mb  = Mclean(idx, :);

            % Normalize columns
            for c = 1:4
                cn = norm(Mb(:,c));
                if cn > 0; Mb(:,c) = Mb(:,c) / cn; end
            end

            d = dot(Mb(:, col_a), Mb(:, col_b));
            angleBoot_all(ar, ag, b) = fold(acosd(d));
%             angleBoot_all(ar, ag, b) = acosd(d);

            % ── Pool 2: Coding neurons (union) ─────────────────────────
            if ~isempty(idx_union)
                idx2 = idx_union(randi(numel(idx_union), numel(idx_union), 1));
                va   = Mclean(idx2, col_a);
                vb   = Mclean(idx2, col_b);
                if norm(va) > 0 && norm(vb) > 0
                    d = dot(va/norm(va), vb/norm(vb));
                    angleBoot_coding(ar, ag, b) = fold(acosd(d));
                end
            end

            % ── Pool 3: Shared neurons (intersection) ──────────────────
            if ~isempty(idx_inter)
                idx3 = idx_inter(randi(numel(idx_inter), numel(idx_inter), 1));
                va   = Mclean(idx3, col_a);
                vb   = Mclean(idx3, col_b);
                if norm(va) > 0 && norm(vb) > 0
                    d = dot(va/norm(va), vb/norm(vb));
                    angleBoot_shared(ar, ag, b) = fold(acosd(d));
                end
            end

        end % boot
    end % angle
end % area

% ── Summarize ─────────────────────────────────────────────────────────
AngleMean_all    = mean(angleBoot_all,    3, 'omitnan');
AngleSEM_all     = std(angleBoot_all,     [], 3, 'omitnan');
AngleMean_coding = mean(angleBoot_coding, 3, 'omitnan');
AngleSEM_coding  = std(angleBoot_coding,  [], 3, 'omitnan');
AngleMean_shared = mean(angleBoot_shared, 3, 'omitnan');
AngleSEM_shared  = std(angleBoot_shared,  [], 3, 'omitnan');

AngleCI_all_low     = prctile(angleBoot_all,     2.5, 3);
AngleCI_all_high    = prctile(angleBoot_all,    97.5, 3);
AngleCI_coding_low  = prctile(angleBoot_coding,  2.5, 3);
AngleCI_coding_high = prctile(angleBoot_coding, 97.5, 3);
AngleCI_shared_low  = prctile(angleBoot_shared,  2.5, 3);
AngleCI_shared_high = prctile(angleBoot_shared, 97.5, 3);

% ══════════════════════════════════════════════════════════════════════
% PLOTTING
% ══════════════════════════════════════════════════════════════════════
angleTitles = {'Within-Saccade: Value vs Outcome', ...
               'Within-Reach: Value vs Outcome', ...
               'Cross-System: Value', ...
               'Cross-System: Outcome'};

poolLabels  = {'All neurons', ...
               'Coding neurons (union)', ...
               'Shared neurons (intersection)'};

poolMeans = {AngleMean_all,    AngleMean_coding,    AngleMean_shared};
poolSEMs  = {AngleSEM_all,     AngleSEM_coding,     AngleSEM_shared};
poolCIlo  = {AngleCI_all_low,  AngleCI_coding_low,  AngleCI_shared_low};
poolCIhi  = {AngleCI_all_high, AngleCI_coding_high, AngleCI_shared_high};

x = 1:nAreas;

% ── Figure 1: Single session results ──────────────────────────────────
figure('Color', 'w', 'Position', [100 100 900 700])
sgtitle('Population geometry — single session', 'FontSize', 12)

for ag = 1:nAngles
    subplot(2, 2, ag)
    hold on

    mu  = AngleMean_sess(ag, :);
    sem = AngleSEM_sess(ag, :);

    errorbar(x, mu, sem, 'k', 'LineWidth', 1, ...
             'CapSize', 6, 'LineStyle', 'none')
    plot(x, mu, 'o', 'MarkerFaceColor', 'k', ...
         'MarkerSize', 5, 'MarkerEdgeColor', 'k')
    line([0 nAreas+1], [90 90], ...
         'LineStyle', ':', 'LineWidth', 0.5, 'Color', 'k')

    xlim([0.5 nAreas+0.5])
    ylim([0 100])
    xticks(x)
    xticklabels(areaLabels)
    yticks(0:30:90)
    ylabel('Angle (°)')
    set(gca, 'TickDir', 'out', 'FontSize', 8)
    axis square
    box off
    title(angleTitles{ag}, 'FontSize', 9, 'FontWeight', 'normal')
end

% ── Figure 2: Bootstrap — all neurons ─────────────────────────────────
figure('Color', 'w', 'Position', [100 100 900 700])
sgtitle('Population geometry — bootstrap, all neurons', 'FontSize', 12)

for ag = 1:nAngles
    subplot(2, 2, ag)
    hold on

    mu  = AngleMean_all(:, ag)';
    sem = AngleSEM_all(:, ag)';

    errorbar(x, mu, sem, 'k', 'LineWidth', 1, ...
             'CapSize', 6, 'LineStyle', 'none')
    plot(x, mu, 'o', 'MarkerFaceColor', 'k', ...
         'MarkerSize', 5, 'MarkerEdgeColor', 'k')
    line([0 nAreas+1], [90 90], ...
         'LineStyle', ':', 'LineWidth', 0.5, 'Color', 'k')

    xlim([0.5 nAreas+0.5])
    ylim([0 100])
    xticks(x)
    xticklabels(areaLabels)
    yticks(0:30:90)
    ylabel('Angle (°)')
    set(gca, 'TickDir', 'out', 'FontSize', 8)
    axis square
    box off
    title(angleTitles{ag}, 'FontSize', 9, 'FontWeight', 'normal')
end

% ── Figure 3: Bootstrap — coding neurons ──────────────────────────────
figure('Color', 'w', 'Position', [100 100 900 700])
sgtitle('Population geometry — bootstrap, coding neurons', 'FontSize', 12)

for ag = 1:nAngles
    subplot(2, 2, ag)
    hold on

    mu  = AngleMean_coding(:, ag)';
    sem = AngleSEM_coding(:, ag)';

    errorbar(x, mu, sem, 'k', 'LineWidth', 1, ...
             'CapSize', 6, 'LineStyle', 'none')
    plot(x, mu, 'o', 'MarkerFaceColor', 'k', ...
         'MarkerSize', 5, 'MarkerEdgeColor', 'k')
    line([0 nAreas+1], [90 90], ...
         'LineStyle', ':', 'LineWidth', 0.5, 'Color', 'k')

    xlim([0.5 nAreas+0.5])
    ylim([0 100])
    xticks(x)
    xticklabels(areaLabels)
    yticks(0:30:90)
    ylabel('Angle (°)')
    set(gca, 'TickDir', 'out', 'FontSize', 8)
    axis square
    box off
    title(angleTitles{ag}, 'FontSize', 9, 'FontWeight', 'normal')
end

% ── Figure 4: Bootstrap — shared neurons ──────────────────────────────
figure('Color', 'w', 'Position', [100 100 900 700])
sgtitle('Population geometry — bootstrap, shared neurons', 'FontSize', 12)

for ag = 1:nAngles
    subplot(2, 2, ag)
    hold on

    mu  = AngleMean_shared(:, ag)';
    sem = AngleSEM_shared(:, ag)';

    errorbar(x, mu, sem, 'k', 'LineWidth', 1, ...
             'CapSize', 6, 'LineStyle', 'none')
    plot(x, mu, 'o', 'MarkerFaceColor', 'k', ...
         'MarkerSize', 5, 'MarkerEdgeColor', 'k')
    line([0 nAreas+1], [90 90], ...
         'LineStyle', ':', 'LineWidth', 0.5, 'Color', 'k')

    xlim([0.5 nAreas+0.5])
    ylim([0 100])
    xticks(x)
    xticklabels(areaLabels)
    yticks(0:30:90)
    ylabel('Angle (°)')
    set(gca, 'TickDir', 'out', 'FontSize', 8)
    axis square
    box off
    title(angleTitles{ag}, 'FontSize', 9, 'FontWeight', 'normal')
end

% ── Figure 5: Summary — all four angles per area ──────────────────────
% One subplot per area showing all four angles as points with CI bars
figure('Color', 'w', 'Position', [100 100 1100 500])
sgtitle('All angles per area — all neurons bootstrap', 'FontSize', 12)

lineColors = {[0.2 0.5 0.8], ...   % within-saccade — blue
              [0.0 0.6 0.4], ...   % within-reach — teal
              [0.8 0.3 0.1], ...   % cross-system value — orange
              [0.5 0.2 0.7]};      % cross-system outcome — purple

for ar = 1:nAreas
    subplot(2, 4, ar)
    hold on

    for ag = 1:nAngles
        mu    = AngleMean_all(ar, ag);
        ci_lo = AngleCI_all_low(ar, ag);
        ci_hi = AngleCI_all_high(ar, ag);

        errorbar(ag, mu, mu - ci_lo, ci_hi - mu, ...
                 'Color', lineColors{ag}, ...
                 'LineWidth', 1.5, 'CapSize', 6, 'LineStyle', 'none')
        plot(ag, mu, 'o', ...
             'MarkerFaceColor', lineColors{ag}, ...
             'MarkerSize', 6, ...
             'MarkerEdgeColor', lineColors{ag})
    end

    line([0 5], [90 90], ...
         'LineStyle', ':', 'LineWidth', 0.5, 'Color', 'k')

    xlim([0.5 4.5])
    ylim([0 100])
    xticks(1:4)
    xticklabels({'W-Eye','W-Arm','X-Val','X-Out'})
    yticks(0:30:90)
    if ar == 1 || ar == 5
        ylabel('Angle (°)')
    end
    set(gca, 'TickDir', 'out', 'FontSize', 7)
    axis square
    box off
    title(areaLabels{ar}, 'FontSize', 9, 'FontWeight', 'normal')
end

% Legend on first subplot
subplot(2, 4, 1)
for ag = 1:nAngles
    plot(NaN, NaN, '-o', ...
         'Color', lineColors{ag}, ...
         'MarkerFaceColor', lineColors{ag}, ...
         'DisplayName', angleTitles{ag})
end
% legend('Location', 'southwest', 'FontSize', 6, 'Box', 'off')

fprintf('\nDone.\n')
%%

% ══════════════════════════════════════════════════════════════════════
% SEMICIRCULAR PLOTS — 0 to 90 degrees (quarter circle)
% ══════════════════════════════════════════════════════════════════════

Colors = [ [54  140  66]/255;
           [210 212 113]/255;
           [59  127 137]/255;
           [175 149 132]/255;
           [67  170 175]/255;
           [232 174 135]/255;
           [140 140 140]/255;
           [243 168 168]/255 ];

% Line length (normalized radius)


% ══════════════════════════════════════════════════════════════════════
% FIGURE 1 (SUPPLEMENTARY) — Within-system value-outcome angles
% ══════════════════════════════════════════════════════════════════════
figure('Color', 'w', 'Position', [100 100 600 300])
sgtitle('Within-system: Value vs Outcome subspace angles', 'FontSize', 11)

% Line length (normalized radius)
lineLen = 0.85;

for ar = 1:nAreas

    ax = subplot(2, 4, ar);
    hold on

    c = Colors(ar,:);

    % ── Format quarter circle ──────────────────────────────────────────
    % Arc
    theta_arc = linspace(0, pi/2, 100);
    plot(cos(theta_arc), sin(theta_arc), 'k-', 'LineWidth', 0.8)

    % Baseline and vertical
    plot([0 1], [0 0], 'k-', 'LineWidth', 0.8)
    plot([0 0], [0 1], 'k-', 'LineWidth', 0.8)

    % Reference lines at 30 and 60
    for refAngle = [30 60]
        tr = deg2rad(refAngle);
        plot([0 cos(tr)], [0 sin(tr)], ':', ...
             'Color', [0.8 0.8 0.8], 'LineWidth', 0.5)
    end

    % Angle labels
    text(1.08,  0.00, '0°',  'FontSize', 7, ...
         'HorizontalAlignment', 'left',   'VerticalAlignment', 'middle')
    text(0.00,  1.10, '90°', 'FontSize', 7, ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
%     text(cos(deg2rad(30))*1.10, sin(deg2rad(30))*1.10, '30°', ...
%          'FontSize', 6, 'HorizontalAlignment', 'left')
%     text(cos(deg2rad(60))*1.10, sin(deg2rad(60))*1.10, '60°', ...
%          'FontSize', 6, 'HorizontalAlignment', 'left')

    % Area label
    text(0.5, -0.15, areaLabels{ar}, 'FontSize', 9, ...
         'HorizontalAlignment', 'center')

    % ── W-Eye — solid ─────────────────────────────────────────────────
    mu  = AngleMean_sess(1, ar);
    sem = AngleSEM_sess(1, ar);

    theta_mean = deg2rad(mu);
    theta_lo   = deg2rad(max(mu - sem, 0));
    theta_hi   = deg2rad(min(mu + sem, 90));

    theta_wedge = linspace(theta_lo, theta_hi, 50);
    xW = [0, lineLen*cos(theta_wedge), 0];
    yW = [0, lineLen*sin(theta_wedge), 0];
    fill(xW, yW, c, 'FaceAlpha', 0.25, 'EdgeColor', 'none')
    plot([0 lineLen*cos(theta_mean)], [0 lineLen*sin(theta_mean)], ...
         '-', 'Color', c, 'LineWidth', 2)

    % ── W-Arm — dashed ────────────────────────────────────────────────
    mu  = AngleMean_sess(2, ar);
    sem = AngleSEM_sess(2, ar);

    theta_mean = deg2rad(mu);
    theta_lo   = deg2rad(max(mu - sem, 0));
    theta_hi   = deg2rad(min(mu + sem, 90));

    theta_wedge = linspace(theta_lo, theta_hi, 50);
    xW = [0, lineLen*cos(theta_wedge), 0];
    yW = [0, lineLen*sin(theta_wedge), 0];
    fill(xW, yW, c, 'FaceAlpha', 0.25, 'EdgeColor', 'none')
    plot([0 lineLen*cos(theta_mean)], [0 lineLen*sin(theta_mean)], ...
         '--', 'Color', c, 'LineWidth', 2)

    axis equal
    axis off
    xlim([-0.15 1.25])
    ylim([-0.25 1.20])

end

annotation('textbox', [0.01 0.02 0.3 0.06], ...
    'String', '— Saccade    - - Reach', ...
    'FontSize', 8, 'EdgeColor', 'none')

% ══════════════════════════════════════════════════════════════════════
% FIGURE 2 (MAIN) — Cross-system angles: Value and Outcome
% ══════════════════════════════════════════════════════════════════════
figure('Color', 'w', 'Position', [100 100 600 300])
sgtitle('Cross-system subspace angles: Value and Outcome', 'FontSize', 11)

for ar = 1:nAreas

    ax = subplot(2, 4, ar);
    hold on

    c = Colors(ar,:);

    % ── Format quarter circle ──────────────────────────────────────────
    theta_arc = linspace(0, pi/2, 100);
    plot(cos(theta_arc), sin(theta_arc), 'k-', 'LineWidth', 0.8)
    plot([0 1], [0 0], 'k-', 'LineWidth', 0.8)
    plot([0 0], [0 1], 'k-', 'LineWidth', 0.8)

    for refAngle = [30 60]
        tr = deg2rad(refAngle);
        plot([0 cos(tr)], [0 sin(tr)], ':', ...
             'Color', [0.8 0.8 0.8], 'LineWidth', 0.5)
    end

    text(1.08,  0.00, '0°',  'FontSize', 7, ...
         'HorizontalAlignment', 'left',   'VerticalAlignment', 'middle')
    text(0.00,  1.10, '90°', 'FontSize', 7, ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
%     text(cos(deg2rad(30))*1.10, sin(deg2rad(30))*1.10, '30°', ...
%          'FontSize', 6, 'HorizontalAlignment', 'left')
%     text(cos(deg2rad(60))*1.10, sin(deg2rad(60))*1.10, '60°', ...
%          'FontSize', 6, 'HorizontalAlignment', 'left')

    text(0.5, -0.15, areaLabels{ar}, 'FontSize', 9, ...
         'HorizontalAlignment', 'center')

    % ── X-Val — solid (angle index 3) ─────────────────────────────────
    mu  = AngleMean_sess(3, ar);
    sem = AngleSEM_sess(3, ar);

    theta_mean = deg2rad(mu);
    theta_lo   = deg2rad(max(mu - sem, 0));
    theta_hi   = deg2rad(min(mu + sem, 90));

    theta_wedge = linspace(theta_lo, theta_hi, 50);
    xW = [0, lineLen*cos(theta_wedge), 0];
    yW = [0, lineLen*sin(theta_wedge), 0];
    fill(xW, yW, c, 'FaceAlpha', 0.25, 'EdgeColor', 'none')
    plot([0 lineLen*cos(theta_mean)], [0 lineLen*sin(theta_mean)], ...
         '-', 'Color', c, 'LineWidth', 2)

    % ── X-Out — dashed (angle index 4) ────────────────────────────────
    mu  = AngleMean_sess(4, ar);
    sem = AngleSEM_sess(4, ar);

    theta_mean = deg2rad(mu);
    theta_lo   = deg2rad(max(mu - sem, 0));
    theta_hi   = deg2rad(min(mu + sem, 90));

    theta_wedge = linspace(theta_lo, theta_hi, 50);
    xW = [0, lineLen*cos(theta_wedge), 0];
    yW = [0, lineLen*sin(theta_wedge), 0];
    fill(xW, yW, c, 'FaceAlpha', 0.25, 'EdgeColor', 'none')
    plot([0 lineLen*cos(theta_mean)], [0 lineLen*sin(theta_mean)], ...
         '--', 'Color', c, 'LineWidth', 2)

    axis equal
    axis off
    xlim([-0.15 1.25])
    ylim([-0.25 1.20])

end

annotation('textbox', [0.01 0.02 0.35 0.06], ...
    'String', '— Value (cross-system)    - - Outcome (cross-system)', ...
    'FontSize', 8, 'EdgeColor', 'none')

%%

% ══════════════════════════════════════════════════════════════════════
% FIGURE — Cross-system value angle by neuron pool (pseudo-population)
% 8 subplots one per area
% Three lines per subplot:
%   Solid  — all neurons
%   Dashed — coding neurons (union of significant)
%   Dotted — shared neurons (intersection of significant)
% Shaded wedge = 95% CI from bootstrap
% Cross-system value = angle index 3
% ══════════════════════════════════════════════════════════════════════

lineLen = 0.85;
valIdx  = 3;  % cross-system value angle index

figure('Color', 'w', 'Position', [100 100 600 300])
sgtitle('Cross-system value angle by neuron pool', 'FontSize', 11)

for ar = 1:nAreas

    ax = subplot(2, 4, ar);
    hold on

    c = Colors(ar,:);

    % ── Format quarter circle ──────────────────────────────────────────
    theta_arc = linspace(0, pi/2, 100);
    plot(cos(theta_arc), sin(theta_arc), 'k-', 'LineWidth', 0.8)
    plot([0 1], [0 0], 'k-', 'LineWidth', 0.8)
    plot([0 0], [0 1], 'k-', 'LineWidth', 0.8)

    % Reference lines at 30 and 60
    for refAngle = [30 60]
        tr = deg2rad(refAngle);
        plot([0 cos(tr)], [0 sin(tr)], ':', ...
             'Color', [0.8 0.8 0.8], 'LineWidth', 0.5)
    end

    % Angle labels
    text(1.08,  0.00, '0°',  'FontSize', 7, ...
         'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle')
    text(0.00,  1.10, '90°', 'FontSize', 7, ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')

    % Area label
    text(0.5, -0.15, areaLabels{ar}, 'FontSize', 9, ...
         'HorizontalAlignment', 'center')

    % ── Pool 1: All neurons — solid ────────────────────────────────────
    mu    = AngleMean_all(ar, valIdx);
    ci_lo = AngleCI_all_low(ar, valIdx);
    ci_hi = AngleCI_all_high(ar, valIdx);

    if ~isnan(mu)
        theta_mean  = deg2rad(mu);
        theta_lo    = deg2rad(max(ci_lo, 0));
        theta_hi    = deg2rad(min(ci_hi, 90));
        theta_wedge = linspace(theta_lo, theta_hi, 50);
        xW = [0, lineLen*cos(theta_wedge), 0];
        yW = [0, lineLen*sin(theta_wedge), 0];
        fill(xW, yW, c, 'FaceAlpha', 0.20, 'EdgeColor', 'none')
        plot([0 lineLen*cos(theta_mean)], [0 lineLen*sin(theta_mean)], ...
             '-', 'Color', c, 'LineWidth', 2)
    end

    % ── Pool 2: Coding neurons — dashed ───────────────────────────────
    mu    = AngleMean_coding(ar, valIdx);
    ci_lo = AngleCI_coding_low(ar, valIdx);
    ci_hi = AngleCI_coding_high(ar, valIdx);

    if ~isnan(mu)
        theta_mean  = deg2rad(mu);
        theta_lo    = deg2rad(max(ci_lo, 0));
        theta_hi    = deg2rad(min(ci_hi, 90));
        theta_wedge = linspace(theta_lo, theta_hi, 50);
        xW = [0, lineLen*cos(theta_wedge), 0];
        yW = [0, lineLen*sin(theta_wedge), 0];
        fill(xW, yW, c, 'FaceAlpha', 0.15, 'EdgeColor', 'none')
        plot([0 lineLen*cos(theta_mean)], [0 lineLen*sin(theta_mean)], ...
             '--', 'Color', c, 'LineWidth', 2)
    end

    % ── Pool 3: Shared neurons — dotted ───────────────────────────────
    mu    = AngleMean_shared(ar, valIdx);
    ci_lo = AngleCI_shared_low(ar, valIdx);
    ci_hi = AngleCI_shared_high(ar, valIdx);

    if ~isnan(mu)
        theta_mean  = deg2rad(mu);
        theta_lo    = deg2rad(max(ci_lo, 0));
        theta_hi    = deg2rad(min(ci_hi, 90));
        theta_wedge = linspace(theta_lo, theta_hi, 50);
        xW = [0, lineLen*cos(theta_wedge), 0];
        yW = [0, lineLen*sin(theta_wedge), 0];
        fill(xW, yW, c, 'FaceAlpha', 0.10, 'EdgeColor', 'none')
        plot([0 lineLen*cos(theta_mean)], [0 lineLen*sin(theta_mean)], ...
             ':', 'Color', c, 'LineWidth', 2.5)
    end

    axis equal
    axis off
    xlim([-0.15 1.25])
    ylim([-0.25 1.20])

end

% ── Legend ─────────────────────────────────────────────────────────────
annotation('textbox', [0.01 0.01 0.50 0.06], ...
    'String', '— All neurons    - - Coding neurons    ··· Shared neurons', ...
    'FontSize', 8, 'EdgeColor', 'none', ...
    'HorizontalAlignment', 'left')
%%

%%
% ══════════════════════════════════════════════════════════════════════
% STATISTICS — Final version
%
% Main figure:           ANOVAN (MonkeySession as blocking factor)
% First supplementary:   ANOVAN (MonkeySession as blocking factor)
% Second supplementary:  Two-way ANOVA without replication (unchanged)
%
% Monkey assignment: sessions 1-32 = M1, sessions 33+ = M2
% ══════════════════════════════════════════════════════════════════════

% ── Verify neuron counts per session per area ─────────────────────────
fprintf('=== Neuron counts per session per area ===\n')
fprintf('%10s', 'Session')
for ar = 1:nAreas
    fprintf('%8s', areaLabels{ar})
end
fprintf('\n')
for s = 1:size(nneurons, 1)
    if any(nneurons(s,:) > 0)
        fprintf('%10d', s)
        for ar = 1:nAreas
            fprintf('%8d', nneurons(s,ar))
        end
        fprintf('\n')
    end
end

% ══════════════════════════════════════════════════════════════════════
% BUILD LONG FORMAT VECTORS — Main figure
% Cross-system angles: Value (index 3) and Outcome (index 4)
% ══════════════════════════════════════════════════════════════════════
angle_vec    = [];
variable_vec = {};
area_vec     = {};
mSess_vec    = {};

for ar = 1:nAreas
    for s = 1:size(Angles_sess, 1)

        if s <= 32
            monk = 'M1';
        else
            monk = 'M2';
        end

        sessLabel = sprintf('%s_S%02d', monk, s);

        % Cross-system value
        val = Angles_sess(s, 3, ar);
        if ~isnan(val)
            angle_vec(end+1)    = val;
            variable_vec{end+1} = 'Value';
            area_vec{end+1}     = areaLabels{ar};
            mSess_vec{end+1}    = sessLabel;
        end

        % Cross-system outcome
        out = Angles_sess(s, 4, ar);
        if ~isnan(out)
            angle_vec(end+1)    = out;
            variable_vec{end+1} = 'Outcome';
            area_vec{end+1}     = areaLabels{ar};
            mSess_vec{end+1}    = sessLabel;
        end
    end
end

fprintf('\n=== Main figure data summary ===\n')
fprintf('Total observations:   %d\n', length(angle_vec))
fprintf('M1 observations:      %d\n', sum(contains(mSess_vec, 'M1')))
fprintf('M2 observations:      %d\n', sum(contains(mSess_vec, 'M2')))
fprintf('Value observations:   %d\n', sum(strcmp(variable_vec, 'Value')))
fprintf('Outcome observations: %d\n', sum(strcmp(variable_vec, 'Outcome')))
fprintf('\nObservations per area:\n')
for ar = 1:nAreas
    fprintf('  %s: %d\n', areaLabels{ar}, sum(strcmp(area_vec, areaLabels{ar})))
end

% ══════════════════════════════════════════════════════════════════════
% ANOVAN — Main figure
% Factors:  Variable(1), Area(2), MonkeySession(3)
% Model:    Variable + Area + MonkeySession + Variable:Area
% MonkeySession = blocking factor
% ══════════════════════════════════════════════════════════════════════
fprintf('\nFitting main figure ANOVAN model...\n')

modelMatrix_main = [...
    1 0 0;   % Variable
    0 1 0;   % Area
    0 0 1;   % MonkeySession (blocking)
    1 1 0];  % Variable x Area interaction

[p_main, tbl_main, stats_main] = anovan(angle_vec', ...
    {variable_vec', area_vec', mSess_vec'}, ...
    'model',    modelMatrix_main, ...
    'varnames', {'Variable','Area','MonkeySession'}, ...
    'display',  'off');

fprintf('\nFull ANOVAN table (main figure):\n')
disp(tbl_main)

% ── Parse table robustly ──────────────────────────────────────────────
p_var  = NaN; F_var  = NaN; df1_var  = NaN;
p_area = NaN; F_area = NaN; df1_area = NaN;
p_int  = NaN; F_int  = NaN; df1_int  = NaN;

df_error_main = tbl_main{end-1, 3};

for row = 2:size(tbl_main,1)-1
    tname = strtrim(tbl_main{row,1});
    if strcmpi(tname, 'Variable')
        F_var   = tbl_main{row,6}; p_var   = tbl_main{row,7};
        df1_var = tbl_main{row,3};
    elseif strcmpi(tname, 'Area')
        F_area   = tbl_main{row,6}; p_area   = tbl_main{row,7};
        df1_area = tbl_main{row,3};
    elseif ~isempty(strfind(tname,'Variable')) && ~isempty(strfind(tname,'Area'))
        F_int   = tbl_main{row,6}; p_int   = tbl_main{row,7};
        df1_int = tbl_main{row,3};
    end
end

fprintf('\n=== Main figure ANOVAN results ===\n')
if ~isnan(F_var)
    fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', ...
        'Variable', df1_var, df_error_main, F_var, p_var)
end
if ~isnan(F_area)
    fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', ...
        'Area', df1_area, df_error_main, F_area, p_area)
end
if ~isnan(F_int)
    fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', ...
        'Variable x Area', df1_int, df_error_main, F_int, p_int)
end

% ── Separate ANOVAN for value only and outcome only ───────────────────
% Value only
valIdx_v  = strcmp(variable_vec, 'Value');
[p_val_only, tbl_val_only] = anovan(angle_vec(valIdx_v)', ...
    {area_vec(valIdx_v)', mSess_vec(valIdx_v)'}, ...
    'model',    'linear', ...
    'varnames', {'Area','MonkeySession'}, ...
    'display',  'off');

% Outcome only
outIdx_v  = strcmp(variable_vec, 'Outcome');
[p_out_only, tbl_out_only] = anovan(angle_vec(outIdx_v)', ...
    {area_vec(outIdx_v)', mSess_vec(outIdx_v)'}, ...
    'model',    'linear', ...
    'varnames', {'Area','MonkeySession'}, ...
    'display',  'off');

fprintf('\n=== Area effect — Value only ===\n')
fprintf('Area: F(%d,%d) = %.3f, p = %.4f\n', ...
    tbl_val_only{2,3}, tbl_val_only{end-1,3}, ...
    tbl_val_only{2,6}, tbl_val_only{2,7})

fprintf('\n=== Area effect — Outcome only ===\n')
fprintf('Area: F(%d,%d) = %.3f, p = %.4f\n', ...
    tbl_out_only{2,3}, tbl_out_only{end-1,3}, ...
    tbl_out_only{2,6}, tbl_out_only{2,7})

% ── Coefficient of variation ──────────────────────────────────────────
valMeans = nan(1, nAreas);
outMeans = nan(1, nAreas);
for ar = 1:nAreas
    angVal = Angles_sess(:, 3, ar);
    angOut = Angles_sess(:, 4, ar);
    valMeans(ar) = mean(angVal(~isnan(angVal)));
    outMeans(ar) = mean(angOut(~isnan(angOut)));
end

cv_val = std(valMeans) / mean(valMeans) * 100;
cv_out = std(outMeans) / mean(outMeans) * 100;

fprintf('\n=== Variability across areas ===\n')
fprintf('Value:   mean = %.2f, SD = %.2f, CV = %.1f%%\n', ...
    mean(valMeans), std(valMeans), cv_val)
fprintf('Outcome: mean = %.2f, SD = %.2f, CV = %.1f%%\n', ...
    mean(outMeans), std(outMeans), cv_out)

% ══════════════════════════════════════════════════════════════════════
% POST-HOC — Variable x Area interaction
% Paired t-test per area: Value vs Outcome cross-system angle
% If interaction significant: Bonferroni corrected
% If only Variable significant: uncorrected descriptive
% ══════════════════════════════════════════════════════════════════════
pvals_posthoc  = nan(1, nAreas);
tstats_posthoc = nan(1, nAreas);
val_means      = nan(1, nAreas);
out_means      = nan(1, nAreas);
df_vec_ph      = nan(1, nAreas);

for ar = 1:nAreas
    angVal = Angles_sess(:, 3, ar);
    angOut = Angles_sess(:, 4, ar);
    valid  = ~isnan(angVal) & ~isnan(angOut);

    if sum(valid) < 2
        continue
    end

    [~, p, ~, stats]   = ttest(angVal(valid), angOut(valid));
    pvals_posthoc(ar)  = p;
    tstats_posthoc(ar) = stats.tstat;
    val_means(ar)      = mean(angVal(valid));
    out_means(ar)      = mean(angOut(valid));
    df_vec_ph(ar)      = stats.df;
end

pvals_bonf_main = min(pvals_posthoc * nAreas, 1);

if ~isnan(p_int) && p_int < 0.05

    fprintf('\n=== Post-hoc: Value vs Outcome per area (Bonferroni corrected) ===\n')
    fprintf('Interaction significant — Bonferroni corrected\n\n')
    fprintf('%-8s %10s %10s %10s %8s %10s %10s %8s\n', ...
        'Area','Val mean','Out mean','t','df','p (raw)','p (Bonf)','sig')

    for ar = 1:nAreas
        if isnan(pvals_posthoc(ar)); continue; end
        if pvals_bonf_main(ar) < 0.001;     sig = '***';
        elseif pvals_bonf_main(ar) < 0.01;  sig = '**';
        elseif pvals_bonf_main(ar) < 0.05;  sig = '*';
        else;                                sig = 'ns';
        end
        fprintf('%-8s %10.2f %10.2f %10.3f %8.0f %10.4f %10.4f %8s\n', ...
            areaLabels{ar}, val_means(ar), out_means(ar), ...
            tstats_posthoc(ar), df_vec_ph(ar), ...
            pvals_posthoc(ar), pvals_bonf_main(ar), sig)
    end

elseif ~isnan(p_var) && p_var < 0.05

    fprintf('\n=== Post-hoc: Value vs Outcome per area (Bonferroni corrected) ===\n')
    fprintf('Variable significant (p=%.4f), interaction not significant (p=%.4f)\n', ...
        p_var, p_int)
    fprintf('Bonferroni corrected to confirm consistency across areas\n\n')
    fprintf('%-8s %10s %10s %10s %8s %10s %10s %8s\n', ...
        'Area','Val mean','Out mean','t','df','p (raw)','p (Bonf)','sig')

    for ar = 1:nAreas
        if isnan(pvals_posthoc(ar)); continue; end
        if pvals_bonf_main(ar) < 0.001;     sig = '***';
        elseif pvals_bonf_main(ar) < 0.01;  sig = '**';
        elseif pvals_bonf_main(ar) < 0.05;  sig = '*';
        else;                                sig = 'ns';
        end
        fprintf('%-8s %10.2f %10.2f %10.3f %8.0f %10.4f %10.4f %8s\n', ...
            areaLabels{ar}, val_means(ar), out_means(ar), ...
            tstats_posthoc(ar), df_vec_ph(ar), ...
            pvals_posthoc(ar), pvals_bonf_main(ar), sig)
    end

else
    fprintf('\nVariable not significant (p=%.4f) — no post-hoc conducted.\n', p_var)
end

% ══════════════════════════════════════════════════════════════════════
% DESCRIPTIVE SUMMARY — Main figure
% ══════════════════════════════════════════════════════════════════════
fprintf('\n=== Descriptive summary — Main figure ===\n')
fprintf('Mean +- SEM across sessions (cross-system angles)\n\n')
fprintf('%-8s %20s %20s\n', 'Area','Value (deg)','Outcome (deg)')
fprintf('%-8s %20s %20s\n', '----','------------------','------------------')

for ar = 1:nAreas
    angVal = Angles_sess(:, 3, ar);
    angOut = Angles_sess(:, 4, ar);

    validVal = ~isnan(angVal);
    validOut = ~isnan(angOut);

    if sum(validVal) < 2 || sum(validOut) < 2
        fprintf('%-8s  insufficient data\n', areaLabels{ar})
        continue
    end

    mVal   = mean(angVal(validVal));
    semVal = std(angVal(validVal)) / sqrt(sum(validVal));
    mOut   = mean(angOut(validOut));
    semOut = std(angOut(validOut)) / sqrt(sum(validOut));

    fprintf('%-8s %10.2f +- %5.2f %10.2f +- %5.2f\n', ...
        areaLabels{ar}, mVal, semVal, mOut, semOut)
end

fprintf('\nOverall (mean across areas):\n')
fprintf('  Value:   %.2f +- %.2f deg (mean +- SEM across areas)\n', ...
    mean(valMeans), std(valMeans)/sqrt(nAreas))
fprintf('  Outcome: %.2f +- %.2f deg (mean +- SEM across areas)\n', ...
    mean(outMeans), std(outMeans)/sqrt(nAreas))

fprintf('\nMain figure statistics done.\n')

%% two main separate anovan for value and outcome angles. 
% ══════════════════════════════════════════════════════════════════════
% SEPARATE ANOVAN — Value only and Outcome only
% Factors:  Area(1), MonkeySession(2)
% Model:    Area + MonkeySession (main effects only)
% MonkeySession = blocking factor
% ══════════════════════════════════════════════════════════════════════

% ── Value only ────────────────────────────────────────────────────────
valIdx_v = strcmp(variable_vec, 'Value');

[p_val_only, tbl_val_only, stats_val_only] = anovan(angle_vec(valIdx_v)', ...
    {area_vec(valIdx_v)', mSess_vec(valIdx_v)'}, ...
    'model',    'linear', ...
    'varnames', {'Area','MonkeySession'}, ...
    'display',  'off');

p_area_val = NaN; F_area_val = NaN; df1_area_val = NaN;
df_err_val = tbl_val_only{end-1, 3};

for row = 2:size(tbl_val_only,1)-1
    tname = strtrim(tbl_val_only{row,1});
    if strcmpi(tname, 'Area')
        F_area_val   = tbl_val_only{row,6};
        p_area_val   = tbl_val_only{row,7};
        df1_area_val = tbl_val_only{row,3};
    end
end

fprintf('\n=== ANOVAN — Value only ===\n')
fprintf('Area + MonkeySession (blocking)\n')
fprintf('Area: F(%d,%d) = %.3f, p = %.4f\n', ...
    df1_area_val, df_err_val, F_area_val, p_area_val)

if ~isnan(p_area_val) && p_area_val < 0.05
    fprintf('\n--- Post-hoc: Area pairwise comparisons (Bonferroni) ---\n')

    [comparison_val, means_val, ~, gnames_val] = multcompare(stats_val_only, ...
        'Dimension', 1, ...
        'CType',     'bonferroni', ...
        'Display',   'off');

    fprintf('\nMarginal means per area (value):\n')
    for g = 1:length(gnames_val)
        fprintf('  %s: %.2f deg\n', gnames_val{g}, means_val(g))
    end

    fprintf('\nAll pairwise comparisons (df_err = %d):\n', df_err_val)
    for i = 1:size(comparison_val,1)
        diff_est = comparison_val(i,4);
        ci_lo    = comparison_val(i,3);
        ci_hi    = comparison_val(i,5);
        p_bonf   = comparison_val(i,6);
        fprintf('%10s vs %-10s  diff = %7.2f   CI = [%7.2f, %7.2f]   p_bonf = %.4f   %s\n', ...
            gnames_val{comparison_val(i,1)}, ...
            gnames_val{comparison_val(i,2)}, ...
            diff_est, ci_lo, ci_hi, p_bonf, sigStr(p_bonf))
    end
else
    fprintf('Area effect not significant — no post-hoc needed.\n')
end

% ── Outcome only ──────────────────────────────────────────────────────
outIdx_v = strcmp(variable_vec, 'Outcome');

[p_out_only, tbl_out_only, stats_out_only] = anovan(angle_vec(outIdx_v)', ...
    {area_vec(outIdx_v)', mSess_vec(outIdx_v)'}, ...
    'model',    'linear', ...
    'varnames', {'Area','MonkeySession'}, ...
    'display',  'off');

p_area_out = NaN; F_area_out = NaN; df1_area_out = NaN;
df_err_out = tbl_out_only{end-1, 3};

for row = 2:size(tbl_out_only,1)-1
    tname = strtrim(tbl_out_only{row,1});
    if strcmpi(tname, 'Area')
        F_area_out   = tbl_out_only{row,6};
        p_area_out   = tbl_out_only{row,7};
        df1_area_out = tbl_out_only{row,3};
    end
end

fprintf('\n=== ANOVAN — Outcome only ===\n')
fprintf('Area + MonkeySession (blocking)\n')
fprintf('Area: F(%d,%d) = %.3f, p = %.4f\n', ...
    df1_area_out, df_err_out, F_area_out, p_area_out)

if ~isnan(p_area_out) && p_area_out < 0.05
    fprintf('\n--- Post-hoc: Area pairwise comparisons (Bonferroni) ---\n')

    [comparison_out, means_out, ~, gnames_out] = multcompare(stats_out_only, ...
        'Dimension', 1, ...
        'CType',     'bonferroni', ...
        'Display',   'off');

    fprintf('\nMarginal means per area (outcome):\n')
    for g = 1:length(gnames_out)
        fprintf('  %s: %.2f deg\n', gnames_out{g}, means_out(g))
    end

    fprintf('\nSignificant pairwise comparisons:\n')
    anySig = false;
    for i = 1:size(comparison_out,1)
        if comparison_out(i,6) < 0.05
            fprintf('  %s vs %s: diff = %.2f deg, p_bonf = %.4f\n', ...
                gnames_out{comparison_out(i,1)}, ...
                gnames_out{comparison_out(i,2)}, ...
                comparison_out(i,4), comparison_out(i,6))
            anySig = true;
        end
    end
    if ~anySig
        fprintf('  No significant pairwise comparisons after Bonferroni correction.\n')
    end
else
    fprintf('Area effect not significant — no post-hoc needed.\n')
end

% ── Coefficient of variation ──────────────────────────────────────────
valMeans = nan(1, nAreas);
outMeans = nan(1, nAreas);
for ar = 1:nAreas
    angVal = Angles_sess(:, 3, ar);
    angOut = Angles_sess(:, 4, ar);
    valMeans(ar) = mean(angVal(~isnan(angVal)));
    outMeans(ar) = mean(angOut(~isnan(angOut)));
end

cv_val = std(valMeans) / mean(valMeans) * 100;
cv_out = std(outMeans) / mean(outMeans) * 100;

fprintf('\n=== Variability across areas ===\n')
fprintf('Value:   mean = %.2f, SD = %.2f, CV = %.1f%%\n', ...
    mean(valMeans), std(valMeans), cv_val)
fprintf('Outcome: mean = %.2f, SD = %.2f, CV = %.1f%%\n', ...
    mean(outMeans), std(outMeans), cv_out)

%%
% ══════════════════════════════════════════════════════════════════════
% DESCRIPTIVE SUMMARY — Main figure
% ══════════════════════════════════════════════════════════════════════
fprintf('\n=== Descriptive summary — Main figure ===\n')
fprintf('Mean +- SEM across sessions (cross-system angles)\n\n')
fprintf('%-8s %20s %20s\n', 'Area','Value (deg)','Outcome (deg)')
fprintf('%-8s %20s %20s\n', '----','------------------','------------------')

for ar = 1:nAreas
    angVal = Angles_sess(:, 3, ar);
    angOut = Angles_sess(:, 4, ar);

    validVal = ~isnan(angVal);
    validOut = ~isnan(angOut);

    if sum(validVal) < 2 || sum(validOut) < 2
        fprintf('%-8s  insufficient data\n', areaLabels{ar})
        continue
    end

    mVal   = mean(angVal(validVal));
    semVal = std(angVal(validVal)) / sqrt(sum(validVal));
    mOut   = mean(angOut(validOut));
    semOut = std(angOut(validOut)) / sqrt(sum(validOut));

    fprintf('%-8s %10.2f +- %5.2f %10.2f +- %5.2f\n', ...
        areaLabels{ar}, mVal, semVal, mOut, semOut)
end

fprintf('\nOverall (mean across areas):\n')
fprintf('  Value:   %.2f +- %.2f deg (mean +- SEM across areas)\n', ...
    mean(valMeans), std(valMeans)/sqrt(nAreas))
fprintf('  Outcome: %.2f +- %.2f deg (mean +- SEM across areas)\n', ...
    mean(outMeans), std(outMeans)/sqrt(nAreas))

fprintf('\nMain figure statistics done.\n')
%%
% ── Outcome only ──────────────────────────────────────────────────────
outIdx_v = strcmp(variable_vec, 'Outcome');

[p_out_only, tbl_out_only] = anovan(angle_vec(outIdx_v)', ...
    {area_vec(outIdx_v)', mSess_vec(outIdx_v)'}, ...
    'model',    'linear', ...
    'varnames', {'Area','MonkeySession'}, ...
    'display',  'off');

% Parse outcome-only table
p_area_out = NaN; F_area_out = NaN; df1_area_out = NaN;
df_err_out = tbl_out_only{end-1, 3};

for row = 2:size(tbl_out_only,1)-1
    tname = strtrim(tbl_out_only{row,1});
    if strcmpi(tname, 'Area')
        F_area_out   = tbl_out_only{row,6};
        p_area_out   = tbl_out_only{row,7};
        df1_area_out = tbl_out_only{row,3};
    end
end

fprintf('\n=== ANOVAN — Outcome only ===\n')
fprintf('Area + MonkeySession (blocking)\n\n')
fprintf('Full table:\n')
disp(tbl_out_only)
fprintf('Area: F(%d,%d) = %.3f, p = %.4f\n', ...
    df1_area_out, df_err_out, F_area_out, p_area_out)

% Post-hoc on Area if significant
if ~isnan(p_area_out) && p_area_out < 0.05
    fprintf('\n--- Post-hoc: Area pairwise comparisons (Bonferroni) ---\n')

    [~, stats_out_only] = anovan(angle_vec(outIdx_v)', ...
        {area_vec(outIdx_v)', mSess_vec(outIdx_v)'}, ...
        'model',    'linear', ...
        'varnames', {'Area','MonkeySession'}, ...
        'display',  'off');

    [comparison_out, means_out, ~, gnames_out] = multcompare(stats_out_only, ...
        'Dimension', 1, ...
        'CType',     'bonferroni', ...
        'Display',   'off');

    fprintf('\nMarginal means per area (outcome):\n')
    for g = 1:length(gnames_out)
        fprintf('  %s: %.2f deg\n', gnames_out{g}, means_out(g))
    end

    fprintf('\nSignificant pairwise comparisons:\n')
    anySig = false;
    for i = 1:size(comparison_out,1)
        if comparison_out(i,6) < 0.05
            fprintf('  %s vs %s: diff = %.2f deg, p_bonf = %.4f\n', ...
                gnames_out{comparison_out(i,1)}, ...
                gnames_out{comparison_out(i,2)}, ...
                comparison_out(i,4), comparison_out(i,6))
            anySig = true;
        end
    end
    if ~anySig
        fprintf('  No significant pairwise comparisons after Bonferroni correction.\n')
    end
else
    fprintf('Area effect not significant — no post-hoc needed.\n')
end

%%
% ══════════════════════════════════════════════════════════════════════
% BUILD LONG FORMAT VECTORS — First supplementary figure
% Within-system angles: Saccade (index 1) and Reach (index 2)
% ══════════════════════════════════════════════════════════════════════
angle_vec_s  = [];
motorsys_vec = {};
area_vec_s   = {};
mSess_vec_s  = {};

for ar = 1:nAreas
    for s = 1:size(Angles_sess, 1)

        if s <= 32
            monk = 'M1';
        else
            monk = 'M2';
        end

        sessLabel = sprintf('%s_S%02d', monk, s);

        eye = Angles_sess(s, 1, ar);
        if ~isnan(eye)
            angle_vec_s(end+1)   = eye;
            motorsys_vec{end+1}  = 'Saccade';
            area_vec_s{end+1}    = areaLabels{ar};
            mSess_vec_s{end+1}   = sessLabel;
        end

        arm = Angles_sess(s, 2, ar);
        if ~isnan(arm)
            angle_vec_s(end+1)   = arm;
            motorsys_vec{end+1}  = 'Reach';
            area_vec_s{end+1}    = areaLabels{ar};
            mSess_vec_s{end+1}   = sessLabel;
        end
    end
end

fprintf('\n=== First supplementary figure data summary ===\n')
fprintf('Total observations:    %d\n', length(angle_vec_s))
fprintf('M1 observations:       %d\n', sum(contains(mSess_vec_s, 'M1')))
fprintf('M2 observations:       %d\n', sum(contains(mSess_vec_s, 'M2')))
fprintf('Saccade observations:  %d\n', sum(strcmp(motorsys_vec, 'Saccade')))
fprintf('Reach observations:    %d\n', sum(strcmp(motorsys_vec, 'Reach')))
fprintf('\nObservations per area:\n')
for ar = 1:nAreas
    fprintf('  %s: %d\n', areaLabels{ar}, sum(strcmp(area_vec_s, areaLabels{ar})))
end

% ══════════════════════════════════════════════════════════════════════
% ANOVAN — First supplementary figure
% Factors:  MotorSystem(1), Area(2), MonkeySession(3)
% Model:    MotorSystem + Area + MonkeySession + MotorSystem:Area
% MonkeySession = blocking factor
% ══════════════════════════════════════════════════════════════════════
fprintf('\nFitting first supplementary figure ANOVAN model...\n')

modelMatrix_supp = [...
    1 0 0;   % MotorSystem
    0 1 0;   % Area
    0 0 1;   % MonkeySession (blocking)
    1 1 0];  % MotorSystem x Area interaction

[p_supp, tbl_supp, stats_supp] = anovan(angle_vec_s', ...
    {motorsys_vec', area_vec_s', mSess_vec_s'}, ...
    'model',    modelMatrix_supp, ...
    'varnames', {'MotorSystem','Area','MonkeySession'}, ...
    'display',  'off');

fprintf('\nFull ANOVAN table (first supplementary):\n')
disp(tbl_supp)

% ── Parse table robustly ──────────────────────────────────────────────
p_ms   = NaN; F_ms   = NaN; df1_ms   = NaN;
p_as   = NaN; F_as   = NaN; df1_as   = NaN;
p_ints = NaN; F_ints = NaN; df1_ints = NaN;

df_error_supp = tbl_supp{end-1, 3};

for row = 2:size(tbl_supp,1)-1
    tname = strtrim(tbl_supp{row,1});
    if strcmpi(tname, 'MotorSystem')
        F_ms   = tbl_supp{row,6}; p_ms   = tbl_supp{row,7};
        df1_ms = tbl_supp{row,3};
    elseif strcmpi(tname, 'Area')
        F_as   = tbl_supp{row,6}; p_as   = tbl_supp{row,7};
        df1_as = tbl_supp{row,3};
    elseif ~isempty(strfind(tname,'MotorSystem')) && ~isempty(strfind(tname,'Area'))
        F_ints   = tbl_supp{row,6}; p_ints   = tbl_supp{row,7};
        df1_ints = tbl_supp{row,3};
    end
end

fprintf('\n=== First supplementary figure ANOVAN results ===\n')
if ~isnan(F_ms)
    fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', ...
        'MotorSystem', df1_ms, df_error_supp, F_ms, p_ms)
end
if ~isnan(F_as)
    fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', ...
        'Area', df1_as, df_error_supp, F_as, p_as)
end
if ~isnan(F_ints)
    fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', ...
        'MotorSystem x Area', df1_ints, df_error_supp, F_ints, p_ints)
end

% ── Post-hoc on Area if significant ───────────────────────────────────
if ~isnan(p_as) && p_as < 0.05
    fprintf('\n--- Post-hoc: Area effect ---\n')
    fprintf('Area significant but MotorSystem not significant\n')
    fprintf('Marginal means per area averaged across motor systems:\n\n')

    for ar = 1:nAreas
        angEye = Angles_sess(:, 1, ar);
        angArm = Angles_sess(:, 2, ar);
        valid  = ~isnan(angEye) & ~isnan(angArm);
        if sum(valid) < 2; continue; end
        fprintf('  %-8s mean = %.2f deg (n=%d sessions)\n', ...
            areaLabels{ar}, ...
            mean([angEye(valid); angArm(valid)]), ...
            sum(valid))
    end
    fprintf('\nNote: Area effect (p=%.4f) — no pairwise post-hoc conducted\n', p_as)
    fprintf('Primary result is non-significant MotorSystem effect.\n')
else
    fprintf('\nArea effect not significant — no post-hoc needed.\n')
end

% ══════════════════════════════════════════════════════════════════════
% DESCRIPTIVE SUMMARY — First supplementary figure
% ══════════════════════════════════════════════════════════════════════
fprintf('\n=== Descriptive summary — First supplementary figure ===\n')
fprintf('Mean +- SEM across sessions (within-system value-outcome angles)\n\n')
fprintf('%-8s %20s %20s\n', 'Area','Saccade (deg)','Reach (deg)')
fprintf('%-8s %20s %20s\n', '----','------------------','------------------')

eyeMeans = nan(1, nAreas);
armMeans = nan(1, nAreas);

for ar = 1:nAreas
    angEye = Angles_sess(:, 1, ar);
    angArm = Angles_sess(:, 2, ar);

    validEye = ~isnan(angEye);
    validArm = ~isnan(angArm);

    if sum(validEye) < 2 || sum(validArm) < 2
        fprintf('%-8s  insufficient data\n', areaLabels{ar})
        continue
    end

    mEye   = mean(angEye(validEye));
    semEye = std(angEye(validEye)) / sqrt(sum(validEye));
    mArm   = mean(angArm(validArm));
    semArm = std(angArm(validArm)) / sqrt(sum(validArm));

    eyeMeans(ar) = mEye;
    armMeans(ar) = mArm;

    fprintf('%-8s %10.2f +- %5.2f %10.2f +- %5.2f\n', ...
        areaLabels{ar}, mEye, semEye, mArm, semArm)
end

fprintf('\nOverall (mean across areas):\n')
fprintf('  Saccade: %.2f +- %.2f deg (mean +- SEM across areas)\n', ...
    mean(eyeMeans,'omitnan'), std(eyeMeans,'omitnan')/sqrt(sum(~isnan(eyeMeans))))
fprintf('  Reach:   %.2f +- %.2f deg (mean +- SEM across areas)\n', ...
    mean(armMeans,'omitnan'), std(armMeans,'omitnan')/sqrt(sum(~isnan(armMeans))))

fprintf('\nFirst supplementary figure statistics done.\n')

%%
% ══════════════════════════════════════════════════════════════════════
% SECOND SUPPLEMENTARY FIGURE
% Neuron pool comparison: All vs Coding vs Shared
% Two-way ANOVA without replication
% ══════════════════════════════════════════════════════════════════════
valIdx     = 3;
angle_pool = [];
area_pool  = {};
pool_pool  = {};

for ar = 1:nAreas
    angle_pool(end+1) = AngleMean_all(ar, valIdx);
    area_pool{end+1}  = areaLabels{ar};
    pool_pool{end+1}  = 'All';

    angle_pool(end+1) = AngleMean_coding(ar, valIdx);
    area_pool{end+1}  = areaLabels{ar};
    pool_pool{end+1}  = 'Coding';

    angle_pool(end+1) = AngleMean_shared(ar, valIdx);
    area_pool{end+1}  = areaLabels{ar};
    pool_pool{end+1}  = 'Shared';
end

validObs = ~isnan(angle_pool);
angle_v  = angle_pool(validObs)';
area_v   = area_pool(validObs)';
pool_v   = pool_pool(validObs)';

allIdx = strcmp(pool_v, 'All');
codIdx = strcmp(pool_v, 'Coding');
shrIdx = strcmp(pool_v, 'Shared');

fprintf('\n=== Two-way ANOVA without replication — Neuron pool ===\n')
fprintf('Design: %d areas x 3 neuron pools = %d observations\n', ...
    nAreas, length(angle_v))
fprintf('Area = blocking factor, NeuronPool = factor of interest\n\n')

fprintf('Mean angles per pool:\n')
fprintf('  All neurons:    %.2f +- %.2f deg\n', ...
    mean(angle_v(allIdx)), std(angle_v(allIdx)))
fprintf('  Coding neurons: %.2f +- %.2f deg\n', ...
    mean(angle_v(codIdx)), std(angle_v(codIdx)))
fprintf('  Shared neurons: %.2f +- %.2f deg\n', ...
    mean(angle_v(shrIdx)), std(angle_v(shrIdx)))

fprintf('\nPer area:\n')
fprintf('%-8s %12s %12s %12s\n', 'Area','All','Coding','Shared')
for ar = 1:nAreas
    aIdx = strcmp(area_v, areaLabels{ar}) & allIdx;
    cIdx = strcmp(area_v, areaLabels{ar}) & codIdx;
    sIdx = strcmp(area_v, areaLabels{ar}) & shrIdx;
    if any(aIdx) && any(cIdx) && any(sIdx)
        fprintf('%-8s %12.2f %12.2f %12.2f\n', ...
            areaLabels{ar}, angle_v(aIdx), angle_v(cIdx), angle_v(sIdx))
    end
end

[p_anovan, tbl_anovan, stats_anovan] = anovan(angle_v, ...
    {area_v, pool_v}, ...
    'model',    'linear', ...
    'varnames', {'Area','NeuronPool'}, ...
    'display',  'off');

fprintf('\n=== ANOVA results — Neuron pool ===\n')
fprintf('Area       (blocking): F(%d,%d) = %.3f, p = %.4f\n', ...
    tbl_anovan{2,3}, tbl_anovan{5,3}, ...
    tbl_anovan{2,6}, tbl_anovan{2,7})
fprintf('NeuronPool (effect):   F(%d,%d) = %.3f, p = %.4f\n', ...
    tbl_anovan{3,3}, tbl_anovan{5,3}, ...
    tbl_anovan{3,6}, tbl_anovan{3,7})

if p_anovan(2) < 0.05

    fprintf('\n--- Post-hoc: NeuronPool pairwise comparisons (Bonferroni) ---\n')

    [comparison, means_ph, ~, gnames] = multcompare(stats_anovan, ...
        'Dimension', 2, ...
        'CType',     'bonferroni', ...
        'Display',   'off');

    fprintf('%-20s %-20s %10s %10s %8s\n', ...
        'Group 1','Group 2','Diff (deg)','p (Bonf)','sig')

    for i = 1:size(comparison,1)
        p_comp = comparison(i,6);
        if p_comp < 0.001;     sig = '***';
        elseif p_comp < 0.01;  sig = '**';
        elseif p_comp < 0.05;  sig = '*';
        else;                   sig = 'ns';
        end
        fprintf('%-20s %-20s %10.2f %10.4f %8s\n', ...
            gnames{comparison(i,1)}, ...
            gnames{comparison(i,2)}, ...
            comparison(i,4), p_comp, sig)
    end

    fprintf('\nMarginal means from ANOVA:\n')
    for g = 1:length(gnames)
        fprintf('  %s: %.2f deg\n', gnames{g}, means_ph(g))
    end

else
    fprintf('\nNeuronPool effect not significant (p = %.4f)\n', p_anovan(2))
    fprintf('Conclusion: cross-system value angle consistent across neuron pools.\n')
end

% ══════════════════════════════════════════════════════════════════════
% DESCRIPTIVE SUMMARY — Second supplementary figure
% Mean +- 95% CI from bootstrap per area per pool
% ══════════════════════════════════════════════════════════════════════
fprintf('\n=== Descriptive summary — Second supplementary figure ===\n')
fprintf('Bootstrap mean +- 95%% CI (cross-system value angle by neuron pool)\n\n')
fprintf('%-8s %22s %22s %22s\n', ...
    'Area','All neurons','Coding neurons','Shared neurons')
fprintf('%-8s %22s %22s %22s\n', ...
    '----','--------------------','--------------------','--------------------')

for ar = 1:nAreas
    mAll  = AngleMean_all(ar, valIdx);
    loAll = AngleCI_all_low(ar, valIdx);
    hiAll = AngleCI_all_high(ar, valIdx);

    mCod  = AngleMean_coding(ar, valIdx);
    loCod = AngleCI_coding_low(ar, valIdx);
    hiCod = AngleCI_coding_high(ar, valIdx);

    mShr  = AngleMean_shared(ar, valIdx);
    loShr = AngleCI_shared_low(ar, valIdx);
    hiShr = AngleCI_shared_high(ar, valIdx);

    fprintf('%-8s %7.2f [%5.2f %5.2f] %7.2f [%5.2f %5.2f] %7.2f [%5.2f %5.2f]\n', ...
        areaLabels{ar}, ...
        mAll,  loAll, hiAll, ...
        mCod,  loCod, hiCod, ...
        mShr,  loShr, hiShr)
end

fprintf('\nOverall (mean across areas):\n')
fprintf('  All neurons:    %.2f +- %.2f deg (mean +- SD across areas)\n', ...
    mean(angle_v(allIdx)), std(angle_v(allIdx)))
fprintf('  Coding neurons: %.2f +- %.2f deg\n', ...
    mean(angle_v(codIdx)), std(angle_v(codIdx)))
fprintf('  Shared neurons: %.2f +- %.2f deg\n', ...
    mean(angle_v(shrIdx)), std(angle_v(shrIdx)))

fprintf('\nAll statistics done.\n')

%%

% ══════════════════════════════════════════════════════════════════════
% BOOTSTRAP HELPER
% Inputs:
%   M       - N x 4 matrix of beta vectors
%   idx_a   - neuron indices for vector a
%   col_a   - column index for vector a
%   idx_b   - neuron indices for vector b
%   col_b   - column index for vector b
%   nBoot   - number of bootstrap iterations
% Output:
%   bootAngles - 1 x nBoot vector of angles
% ══════════════════════════════════════════════════════════════════════
function bootAngles = bootstrapAngle(M, idx_a, col_a, idx_b, col_b, nBoot)
    bootAngles = nan(1, nBoot);
    for b = 1:nBoot
        % Same index set for both vectors — ensures same length
        n    = numel(idx_a);
        samp = idx_a(randi(n, n, 1));
        va   = M(samp, col_a);
        vb   = M(samp, col_b);
        if norm(va) > 0 && norm(vb) > 0
            d = dot(va/norm(va), vb/norm(vb));
            bootAngles(b) = min(acosd(d), 180 - acosd(d));
        end
    end
end

function str = sigStr(p)
        if p < 0.001;      str = '***';
        elseif p < 0.01;   str = '**';
        elseif p < 0.05;   str = '*';
        else;              str = 'ns';
        end
    end