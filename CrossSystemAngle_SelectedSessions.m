%% ══════════════════════════════════════════════════════════════════════
%  CIRCULAR PLOTS — Selected sessions only
%  Cross-system value angle (angle index 3)
%  Sessions: 4, 5, 15, 34, 36, 50
% ══════════════════════════════════════════════════════════════════════

areaLabels = {'PMd','vlPFC','Put','Cd','lVS','mVS','GPi','Amy'};
nAreas = length(areaLabels);

Colors = [ [54  140  66]/255;
           [210 212 113]/255;
           [59  127 137]/255;
           [175 149 132]/255;
           [67  170 175]/255;
           [232 174 135]/255;
           [140 140 140]/255;
           [243 168 168]/255 ];

lineLen = 0.85;
valIdx  = 3;  % cross-system value angle

% ── Selected sessions ─────────────────────────────────────────────────
selSessions = [ 11  15  34  35 37  45  49  50];

% ══════════════════════════════════════════════════════════════════════
% EXTRACT ANGLES FOR SELECTED SESSIONS
% ══════════════════════════════════════════════════════════════════════
% Angles_sess is nSess × nAngles × nAreas (from main geometry code)

selAngles = nan(length(selSessions), nAreas);
for si = 1:length(selSessions)
    s = selSessions(si);
    if s <= size(Angles_sess, 1)
        selAngles(si, :) = squeeze(Angles_sess(s, valIdx, :))';
    end
end

% Per-area: mean and SEM (or single value if only one session)
areaMean = nan(1, nAreas);
areaSEM  = nan(1, nAreas);
areaN    = zeros(1, nAreas);

for ar = 1:nAreas
    vals = selAngles(:, ar);
    vals = vals(~isnan(vals));
    areaN(ar) = length(vals);
    if areaN(ar) >= 1
        areaMean(ar) = mean(vals);
        if areaN(ar) > 1
            areaSEM(ar) = std(vals) / sqrt(areaN(ar));
        else
            areaSEM(ar) = 0;  % single session, no SEM
        end
    end
end

% Print summary
fprintf('=== Selected sessions: %s ===\n', mat2str(selSessions))
fprintf('\n%-8s %8s %10s %8s %8s\n', 'Area', 'N sess', 'Mean (°)', 'SEM', 'Sessions')
for ar = 1:nAreas
    vals = selAngles(:, ar);
    validIdx = find(~isnan(vals));
    sessStr = strjoin(arrayfun(@num2str, selSessions(validIdx), 'UniformOutput', false), ',');
    if areaN(ar) > 0
        fprintf('%-8s %8d %10.2f %8.2f    [%s]\n', ...
            areaLabels{ar}, areaN(ar), areaMean(ar), areaSEM(ar), sessStr)
    else
        fprintf('%-8s %8d %10s %8s    —\n', areaLabels{ar}, 0, 'N/A', 'N/A')
    end
end
%% PLOTS START
% ══════════════════════════════════════════════════════════════════════
% FIGURE 1 — Per-area circular plots (selected sessions)
% ══════════════════════════════════════════════════════════════════════
figure('Color', 'w', 'Position', [100 100 600 300])
sgtitle(sprintf('Cross-system value angle — sessions %s', mat2str(selSessions)), ...
    'FontSize', 11)

for ar = 1:nAreas

    subplot(2, 4, ar); hold on
    c = Colors(ar,:);

    % ── Quarter circle ────────────────────────────────────────────────
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
         'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle')
    text(0.00,  1.10, '90°', 'FontSize', 7, ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')

    % ── Plot individual session dots on arc ────────────────────────────
    vals = selAngles(:, ar);
    vals = vals(~isnan(vals));

%     for vi = 1:length(vals)
%         th = deg2rad(vals(vi));
%        scatter(lineLen*cos(th), lineLen*sin(th), 25, c, 'filled', ...
%     'MarkerFaceAlpha', 0.4, 'MarkerEdgeColor', c)
%     end

    % ── Plot mean (± SEM wedge if >1 session) ─────────────────────────
    if areaN(ar) >= 1
        mu = areaMean(ar);
        theta_mean = deg2rad(mu);

        if areaN(ar) > 1 && areaSEM(ar) > 0
            sem = areaSEM(ar);
            theta_lo = deg2rad(max(mu - sem, 0));
            theta_hi = deg2rad(min(mu + sem, 90));
            theta_wedge = linspace(theta_lo, theta_hi, 50);
            xW = [0, lineLen*cos(theta_wedge), 0];
            yW = [0, lineLen*sin(theta_wedge), 0];
            fill(xW, yW, c, 'FaceAlpha', 0.25, 'EdgeColor', 'none')
        end

        plot([0 lineLen*cos(theta_mean)], [0 lineLen*sin(theta_mean)], ...
             '-', 'Color', c, 'LineWidth', 2)
    end

    % ── Area label with n ──────────────────────────────────────────────
    text(0.5, -0.15, sprintf('%s (n=%d)', areaLabels{ar}, areaN(ar)), ...
        'FontSize', 8, 'HorizontalAlignment', 'center')

    axis equal; axis off
    xlim([-0.15 1.25]); ylim([-0.25 1.20])
end

% ══════════════════════════════════════════════════════════════════════
% FIGURE 2 — Single pooled angle (all areas, all selected sessions)
% ══════════════════════════════════════════════════════════════════════
allVals = selAngles(:);
allVals = allVals(~isnan(allVals));
poolMean = mean(allVals);
poolSEM  = std(allVals) / sqrt(length(allVals));
poolN    = length(allVals);

fprintf('\n=== Pooled across areas ===\n')
fprintf('N observations: %d\n', poolN)
fprintf('Mean: %.2f +- %.2f (SEM) deg\n', poolMean, poolSEM)

figure('Color', 'w', 'Position', [100 100 250 250])
hold on

% ── Quarter circle ────────────────────────────────────────────────────
theta_arc = linspace(0, pi/2, 100);
plot(cos(theta_arc), sin(theta_arc), 'k-', 'LineWidth', 0.8)
plot([0 1], [0 0], 'k-', 'LineWidth', 0.8)
plot([0 0], [0 1], 'k-', 'LineWidth', 0.8)

for refAngle = [30 60]
    tr = deg2rad(refAngle);
    plot([0 cos(tr)], [0 sin(tr)], ':', ...
         'Color', [0.8 0.8 0.8], 'LineWidth', 0.5)
end

text(1.08,  0.00, '0°',  'FontSize', 8, ...
     'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle')
text(0.00,  1.10, '90°', 'FontSize', 8, ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')

% ── Individual points (colored by area) ───────────────────────────────
% for ar = 1:nAreas
%     vals = selAngles(:, ar);
%     vals = vals(~isnan(vals));
%     for vi = 1:length(vals)
%         th = deg2rad(vals(vi));
%        scatter(lineLen*cos(th), lineLen*sin(th), 35, Colors(ar,:), 'filled', ...
%     'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', Colors(ar,:))
%     end
% end

% ── Mean + SEM wedge ──────────────────────────────────────────────────
theta_mean = deg2rad(poolMean);
theta_lo   = deg2rad(max(poolMean - poolSEM, 0));
theta_hi   = deg2rad(min(poolMean + poolSEM, 90));
theta_wedge = linspace(theta_lo, theta_hi, 50);
xW = [0, lineLen*cos(theta_wedge), 0];
yW = [0, lineLen*sin(theta_wedge), 0];
fill(xW, yW, [0.3 0.3 0.3], 'FaceAlpha', 0.2, 'EdgeColor', 'none')
plot([0 lineLen*cos(theta_mean)], [0 lineLen*sin(theta_mean)], ...
     '-', 'Color', [0.2 0.2 0.2], 'LineWidth', 2.5)

text(0.5, -0.15, sprintf('Pooled (n=%d)', poolN), ...
    'FontSize', 9, 'HorizontalAlignment', 'center')
text(0.5, -0.25, sprintf('%.1f° ± %.1f°', poolMean, poolSEM), ...
    'FontSize', 8, 'HorizontalAlignment', 'center', 'Color', [0.3 0.3 0.3])

title('Cross-system value angle', 'FontSize', 10)
axis equal; axis off
xlim([-0.15 1.25]); ylim([-0.35 1.20])
%% PLOTS END


%% PLOTS 0-180 START
% ══════════════════════════════════════════════════════════════════════
% FIGURE 1 — Per-area circular plots (selected sessions)
% ══════════════════════════════════════════════════════════════════════
figure('Color', 'w', 'Position', [100 100 700 400])
sgtitle(sprintf('Cross-system value angle — sessions %s', mat2str(selSessions)), ...
    'FontSize', 11)

for ar = 1:nAreas

    subplot(2, 4, ar); hold on
    c = Colors(ar,:);

    % ── Half circle (0–180°) ──────────────────────────────────────────
    theta_arc = linspace(0, pi, 100);
    plot(cos(theta_arc), sin(theta_arc), 'k-', 'LineWidth', 0.8)
    plot([-1 1], [0 0], 'k-', 'LineWidth', 0.8)   % baseline
    plot([0 0], [0 1], 'k-', 'LineWidth', 0.8)    % 90° reference

    for refAngle = [30 60 120 150]
        tr = deg2rad(refAngle);
        plot([0 cos(tr)], [0 sin(tr)], ':', ...
             'Color', [0.8 0.8 0.8], 'LineWidth', 0.5)
    end

    text(1.08,  0.00, '0°',   'FontSize', 7, ...
         'HorizontalAlignment', 'left',   'VerticalAlignment', 'middle')
    text(0.00,  1.10, '90°',  'FontSize', 7, ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
    text(-1.08, 0.00, '180°', 'FontSize', 7, ...
         'HorizontalAlignment', 'right',  'VerticalAlignment', 'middle')

    % ── Plot individual session dots on arc ────────────────────────────
    vals = selAngles(:, ar);
    vals = vals(~isnan(vals));

%     for vi = 1:length(vals)
%         th = deg2rad(vals(vi));
%        scatter(lineLen*cos(th), lineLen*sin(th), 25, c, 'filled', ...
%     'MarkerFaceAlpha', 0.4, 'MarkerEdgeColor', c)
%     end

    % ── Plot mean (± SEM wedge if >1 session) ─────────────────────────
    if areaN(ar) >= 1
        mu = areaMean(ar);
        theta_mean = deg2rad(mu);

        if areaN(ar) > 1 && areaSEM(ar) > 0
            sem = areaSEM(ar);
            theta_lo = deg2rad(max(mu - sem, 0));
            theta_hi = deg2rad(min(mu + sem, 180));
            theta_wedge = linspace(theta_lo, theta_hi, 50);
            xW = [0, lineLen*cos(theta_wedge), 0];
            yW = [0, lineLen*sin(theta_wedge), 0];
            fill(xW, yW, c, 'FaceAlpha', 0.25, 'EdgeColor', 'none')
        end

        plot([0 lineLen*cos(theta_mean)], [0 lineLen*sin(theta_mean)], ...
             '-', 'Color', c, 'LineWidth', 2)
    end

    % ── Area label with n ──────────────────────────────────────────────
    text(0, -0.15, sprintf('%s (n=%d)', areaLabels{ar}, areaN(ar)), ...
        'FontSize', 8, 'HorizontalAlignment', 'center')

    axis equal; axis off
    xlim([-1.25 1.25]); ylim([-0.25 1.20])
end

% ══════════════════════════════════════════════════════════════════════
% FIGURE 2 — Single pooled angle (all areas, all selected sessions)
% ══════════════════════════════════════════════════════════════════════
allVals = selAngles(:);
allVals = allVals(~isnan(allVals));
poolMean = mean(allVals);
poolSEM  = std(allVals) / sqrt(length(allVals));
poolN    = length(allVals);

fprintf('\n=== Pooled across areas ===\n')
fprintf('N observations: %d\n', poolN)
fprintf('Mean: %.2f +- %.2f (SEM) deg\n', poolMean, poolSEM)

figure('Color', 'w', 'Position', [100 100 350 280])
hold on

% ── Half circle (0–180°) ──────────────────────────────────────────────
theta_arc = linspace(0, pi, 100);
plot(cos(theta_arc), sin(theta_arc), 'k-', 'LineWidth', 0.8)
plot([-1 1], [0 0], 'k-', 'LineWidth', 0.8)
plot([0 0], [0 1], 'k-', 'LineWidth', 0.8)

for refAngle = [30 60 120 150]
    tr = deg2rad(refAngle);
    plot([0 cos(tr)], [0 sin(tr)], ':', ...
         'Color', [0.8 0.8 0.8], 'LineWidth', 0.5)
end

text(1.08,  0.00, '0°',   'FontSize', 8, ...
     'HorizontalAlignment', 'left',   'VerticalAlignment', 'middle')
text(0.00,  1.10, '90°',  'FontSize', 8, ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
text(-1.08, 0.00, '180°', 'FontSize', 8, ...
     'HorizontalAlignment', 'right',  'VerticalAlignment', 'middle')

% ── Individual points (colored by area) ───────────────────────────────
% for ar = 1:nAreas
%     vals = selAngles(:, ar);
%     vals = vals(~isnan(vals));
%     for vi = 1:length(vals)
%         th = deg2rad(vals(vi));
%        scatter(lineLen*cos(th), lineLen*sin(th), 35, Colors(ar,:), 'filled', ...
%     'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', Colors(ar,:))
%     end
% end

% ── Mean + SEM wedge ──────────────────────────────────────────────────
theta_mean = deg2rad(poolMean);
theta_lo   = deg2rad(max(poolMean - poolSEM, 0));
theta_hi   = deg2rad(min(poolMean + poolSEM, 180));
theta_wedge = linspace(theta_lo, theta_hi, 50);
xW = [0, lineLen*cos(theta_wedge), 0];
yW = [0, lineLen*sin(theta_wedge), 0];
fill(xW, yW, [0.3 0.3 0.3], 'FaceAlpha', 0.2, 'EdgeColor', 'none')
plot([0 lineLen*cos(theta_mean)], [0 lineLen*sin(theta_mean)], ...
     '-', 'Color', [0.2 0.2 0.2], 'LineWidth', 2.5)

text(0, -0.15, sprintf('Pooled (n=%d)', poolN), ...
    'FontSize', 9, 'HorizontalAlignment', 'center')
text(0, -0.25, sprintf('%.1f° ± %.1f°', poolMean, poolSEM), ...
    'FontSize', 8, 'HorizontalAlignment', 'center', 'Color', [0.3 0.3 0.3])

title('Cross-system value angle', 'FontSize', 10)
axis equal; axis off
xlim([-1.25 1.25]); ylim([-0.35 1.20])

%% PLOTS 0-180 END

%% ══════════════════════════════════════════════════════════════════════
% STATISTICS — Cross-system value angle (selected sessions only)
% ANOVAN: Area + MonkeySession (blocking)
% ══════════════════════════════════════════════════════════════════════

% ── Build long format vectors ─────────────────────────────────────────
angle_vec_sel   = [];
area_vec_sel    = {};
mSess_vec_sel   = {};

for ar = 1:nAreas
    for si = 1:length(selSessions)
        s = selSessions(si);

        if s <= 32
            monk = 'M1';
        else
            monk = 'M2';
        end
        sessLabel = sprintf('%s_S%02d', monk, s);

        val = selAngles(si, ar);
        if ~isnan(val)
            angle_vec_sel(end+1)   = val;
            area_vec_sel{end+1}    = areaLabels{ar};
            mSess_vec_sel{end+1}   = sessLabel;
        end
    end
end

% ── Data summary ──────────────────────────────────────────────────────
fprintf('\n=== Cross-system value angle — Selected sessions ===\n')
fprintf('Sessions: %s\n', mat2str(selSessions))
fprintf('Total observations: %d\n', length(angle_vec_sel))
fprintf('\nObservations per area:\n')
for ar = 1:nAreas
    n = sum(strcmp(area_vec_sel, areaLabels{ar}));
    fprintf('  %-8s n=%d\n', areaLabels{ar}, n)
end

% ── ANOVAN: Area + MonkeySession (blocking) ───────────────────────────
[p_sel, tbl_sel, stats_sel] = anovan(angle_vec_sel', ...
    {area_vec_sel', mSess_vec_sel'}, ...
    'model',    'linear', ...
    'varnames', {'Area','MonkeySession'}, ...
    'display',  'off');

p_area_sel = NaN; F_area_sel = NaN; df1_area_sel = NaN;
df_err_sel = tbl_sel{end-1, 3};

for row = 2:size(tbl_sel,1)-1
    tname = strtrim(tbl_sel{row,1});
    if strcmpi(tname, 'Area')
        F_area_sel   = tbl_sel{row,6};
        p_area_sel   = tbl_sel{row,7};
        df1_area_sel = tbl_sel{row,3};
    end
end

fprintf('\n--- ANOVAN results (selected sessions) ---\n')
fprintf('Area: F(%d,%d) = %.3f, p = %.4f\n', ...
    df1_area_sel, df_err_sel, F_area_sel, p_area_sel)

% ── Descriptive summary ──────────────────────────────────────────────
fprintf('\n--- Descriptive summary ---\n')
fprintf('%-8s %10s %8s %8s\n', 'Area', 'Mean (°)', 'SEM', 'N')
for ar = 1:nAreas
    if areaN(ar) == 0; continue; end
    fprintf('%-8s %10.2f %8.2f %8d\n', ...
        areaLabels{ar}, areaMean(ar), areaSEM(ar), areaN(ar))
end

fprintf('\nPooled across areas: %.2f +- %.2f deg (n=%d)\n', ...
    poolMean, poolSEM, poolN)

% ── Compare selected sessions vs full dataset ─────────────────────────
fprintf('\n--- Comparison: selected vs full dataset ---\n')
fprintf('%-8s %15s %15s\n', 'Area', 'Full (°)', 'Selected (°)')
for ar = 1:nAreas
    fullVal = AngleMean_sess(3, ar);
    selVal  = areaMean(ar);
    if isnan(selVal)
        fprintf('%-8s %15.2f %15s\n', areaLabels{ar}, fullVal, 'N/A')
    else
        fprintf('%-8s %15.2f %15.2f\n', areaLabels{ar}, fullVal, selVal)
    end
end

fprintf('\nOverall full dataset:      %.2f +- %.2f deg\n', ...
    mean(AngleMean_sess(3,:)), std(AngleMean_sess(3,:))/sqrt(nAreas))
fprintf('Overall selected sessions: %.2f +- %.2f deg\n', ...
    poolMean, poolSEM)

fprintf('\nSelected sessions angle statistics done.\n')


%%

%% ══════════════════════════════════════════════════════════════════════
% ANOVAN — Value angle with Behavioral Similarity factor
% Factors: BehavSimilarity (similar vs different), Area, Monkey (blocking)
% ══════════════════════════════════════════════════════════════════════

Sim_behavSess = [ 11  15  34  35 37  45  49  50 ];

angle_vec_bs   = [];
area_vec_bs    = {};
behav_vec_bs   = {};
monk_vec_bs    = {};

for ar = 1:nAreas
    for s = 1:size(Angles_sess, 1)

        val = Angles_sess(s, 3, ar);
        if isnan(val); continue; end

        if s <= 32
            monkLabel = 'M1';
        else
            monkLabel = 'M2';
        end

        if ismember(s, Sim_behavSess)
            behavLabel = 'Similar';
        else
            behavLabel = 'Different';
        end

        angle_vec_bs(end+1)   = val;
        area_vec_bs{end+1}    = areaLabels{ar};
        behav_vec_bs{end+1}   = behavLabel;
        monk_vec_bs{end+1}    = monkLabel;
    end
end

% ── Data summary ──────────────────────────────────────────────────────
fprintf('\n=== Value angle with Behavioral Similarity factor ===\n')
fprintf('Total observations:   %d\n', length(angle_vec_bs))
fprintf('Similar sessions:     %d\n', sum(strcmp(behav_vec_bs, 'Similar')))
fprintf('Different sessions:   %d\n', sum(strcmp(behav_vec_bs, 'Different')))
fprintf('M1 observations:      %d\n', sum(strcmp(monk_vec_bs, 'M1')))
fprintf('M2 observations:      %d\n', sum(strcmp(monk_vec_bs, 'M2')))

% ── ANOVAN ────────────────────────────────────────────────────────────
modelMatrix_bs = [...
    1 0 0;   % BehavSimilarity
    0 1 0;   % Area
    0 0 1;   % Monkey (blocking)
    1 1 0];  % BehavSimilarity × Area

[p_bs, tbl_bs, stats_bs] = anovan(angle_vec_bs', ...
    {behav_vec_bs', area_vec_bs', monk_vec_bs'}, ...
    'model',    modelMatrix_bs, ...
    'varnames', {'BehavSimilarity','Area','Monkey'}, ...
    'display',  'off');

% ── Parse table ───────────────────────────────────────────────────────
p_behav   = NaN; F_behav   = NaN; df1_behav   = NaN;
p_area_bs = NaN; F_area_bs = NaN; df1_area_bs = NaN;
p_int_bs  = NaN; F_int_bs  = NaN; df1_int_bs  = NaN;
p_monk_bs = NaN; F_monk_bs = NaN; df1_monk_bs = NaN;
df_err_bs = tbl_bs{end-1, 3};

for row = 2:size(tbl_bs,1)-1
    tname = strtrim(tbl_bs{row,1});
    if strcmpi(tname, 'BehavSimilarity')
        F_behav = tbl_bs{row,6}; p_behav = tbl_bs{row,7}; df1_behav = tbl_bs{row,3};
    elseif strcmpi(tname, 'Area')
        F_area_bs = tbl_bs{row,6}; p_area_bs = tbl_bs{row,7}; df1_area_bs = tbl_bs{row,3};
    elseif strcmpi(tname, 'Monkey')
        F_monk_bs = tbl_bs{row,6}; p_monk_bs = tbl_bs{row,7}; df1_monk_bs = tbl_bs{row,3};
    elseif ~isempty(strfind(tname,'BehavSimilarity')) && ~isempty(strfind(tname,'Area'))
        F_int_bs = tbl_bs{row,6}; p_int_bs = tbl_bs{row,7}; df1_int_bs = tbl_bs{row,3};
    end
end

fprintf('\n--- ANOVAN results ---\n')
if ~isnan(F_behav)
    fprintf('%-30s F(%d,%d) = %.3f, p = %.4f\n', ...
        'BehavSimilarity', df1_behav, df_err_bs, F_behav, p_behav)
end
if ~isnan(F_area_bs)
    fprintf('%-30s F(%d,%d) = %.3f, p = %.4f\n', ...
        'Area', df1_area_bs, df_err_bs, F_area_bs, p_area_bs)
end
if ~isnan(F_monk_bs)
    fprintf('%-30s F(%d,%d) = %.3f, p = %.4f\n', ...
        'Monkey', df1_monk_bs, df_err_bs, F_monk_bs, p_monk_bs)
end
if ~isnan(F_int_bs)
    fprintf('%-30s F(%d,%d) = %.3f, p = %.4f\n', ...
        'BehavSimilarity x Area', df1_int_bs, df_err_bs, F_int_bs, p_int_bs)
end

% ── Descriptive: mean angle by behavioral similarity ──────────────────
simIdx  = strcmp(behav_vec_bs, 'Similar');
diffIdx = strcmp(behav_vec_bs, 'Different');

fprintf('\nMean angle:\n')
fprintf('  Similar behavior sessions:   %.2f +- %.2f deg (n=%d)\n', ...
    mean(angle_vec_bs(simIdx)), std(angle_vec_bs(simIdx))/sqrt(sum(simIdx)), sum(simIdx))
fprintf('  Different behavior sessions: %.2f +- %.2f deg (n=%d)\n', ...
    mean(angle_vec_bs(diffIdx)), std(angle_vec_bs(diffIdx))/sqrt(sum(diffIdx)), sum(diffIdx))

% ── Per-area breakdown ────────────────────────────────────────────────
fprintf('\nPer-area mean angle by behavioral similarity:\n')
fprintf('%-8s %15s %15s\n', 'Area', 'Similar (°)', 'Different (°)')
for ar = 1:nAreas
    arIdx = strcmp(area_vec_bs, areaLabels{ar});
    simAr  = angle_vec_bs(arIdx & simIdx);
    diffAr = angle_vec_bs(arIdx & diffIdx);

    if isempty(simAr)
        simStr = 'N/A';
    else
        simStr = sprintf('%.2f +- %.2f', mean(simAr), std(simAr)/sqrt(length(simAr)));
    end
    if isempty(diffAr)
        diffStr = 'N/A';
    else
        diffStr = sprintf('%.2f +- %.2f', mean(diffAr), std(diffAr)/sqrt(length(diffAr)));
    end

    fprintf('%-8s %15s %15s\n', areaLabels{ar}, simStr, diffStr)
end

fprintf('\nBehavioral similarity analysis done.\n')