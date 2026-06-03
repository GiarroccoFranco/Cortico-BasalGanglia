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
        ylim([yl(1)  dotBase + 3.5 * dotStep])

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
        set(gca, 'FontSize', 9)
%         ylim([0.4 0.75])
xlim([-600 1200])
    end

    sgtitle(figSpecs(f).title, 'FontSize', 14)
end


%% ══════════════════════════════════════════════════════════════════════
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
