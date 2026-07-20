
%% ============================================================

areaLabels = {
    'PMd'
    'vlPFC'
    'Put'
    'Cd'
    'lVS'
    'mVS'
    'GPi'
    'Amygdala'
};
Sess_numb = unique(Arm.Session);

Dist_LowHigh_Arm_1_boot = nan(length(Sess_numb), nAreas);   % SAME
Dist_LowHigh_Arm_2_boot = nan(length(Sess_numb), nAreas);   % OTHER
Delta_boot              = nan(length(Sess_numb), nAreas);   % SAME - OTHER



getTrialGroups = @(M) struct( ...
    'Left',  find(M(:,1) == -1), ...
    'Right', find(M(:,1) == 1),  ...
    'StimLow', find(M(:,2) == 1), 'StimHigh', find(M(:,2) == 3), ...
    'ActLow', find(M(:,3) == 1), 'ActHigh', find(M(:,3) == 3), ...
    'Session', []...
    );

% ============================
%  PROCESS EYE TRIALS
% ============================
Arm = getTrialGroups(allLabelArm);

Arm.Session =  allLabelArm(:,5);

% ============================
%  PROCESS ARM TRIALS
% ============================
Arm = getTrialGroups(allLabelArm);

Arm.Session =  allLabelArm(:,5);



%%%%%----------------------------------


 for b=  Sess_numb' 

sess_labels = find(Arm.Session==b);

ArmLowSess= intersect (Arm.StimLow,sess_labels);
ArmHighSess= intersect (Arm.StimHigh,sess_labels);

Left  = intersect(Arm.Left,sess_labels);
Right = intersect(Arm.Right,sess_labels);

idx_LL0 = intersect ( ArmLowSess,  Left );
idx_LR0 = intersect ( ArmLowSess,  Right );
idx_HL0 = intersect ( ArmHighSess, Left );
idx_HR0 = intersect ( ArmHighSess, Right );

 
 for ar = 1:nAreas
        % =========================================================
        % =============== SAME (Proj_1) ============================
        % x = choice direction, y = action value
        % ---------------------------------------------------------
        x_LL = nanmean(Proj_1_B_Dir_Arm_All(idx_LL0, 5:60, ar), 1);
        y_LL = nanmean(Proj_1_B_SV_Arm_All (idx_LL0, 5:60, ar), 1);

        x_LR = nanmean(Proj_1_B_Dir_Arm_All(idx_LR0, 5:60, ar), 1);
        y_LR = nanmean(Proj_1_B_SV_Arm_All (idx_LR0, 5:60, ar), 1);

        x_HL = nanmean(Proj_1_B_Dir_Arm_All(idx_HL0, 5:60, ar), 1);
        y_HL = nanmean(Proj_1_B_SV_Arm_All (idx_HL0, 5:60, ar), 1);

        x_HR = nanmean(Proj_1_B_Dir_Arm_All(idx_HR0, 5:60, ar), 1);
        y_HR = nanmean(Proj_1_B_SV_Arm_All (idx_HR0, 5:60, ar), 1);

        Left_w= abs(y_LL-y_HL);  [maxDist_Left, Bin_Left(ar)] = max(Left_w);
        Right_w= abs(y_LR-y_HR); [maxDist_Right, Bin_Right(ar)] = max(Right_w);

%         figure,
% subplot(2,2,1)
%  plot(y_LL); hold on; plot (y_HL); hold on; plot(Left_w)
% subplot(2,2,2)
%  plot(y_LR); hold on; plot (y_HR); hold on; plot(Right_w)
% 
 end


time_u = -1200:50:2000;
window_size_L = Bin_Left+4;
window_size_R = Bin_Right+4;
Bin_Ext =3;


nAreas = size(Proj_1_B_SV_Arm_All,3);

% ------------------------------------------------------------
% Build the 4 index sets ONCE (not inside parfor)
% ------------------------------------------------------------

% Safety
if isempty(idx_LL0) || isempty(idx_LR0) || isempty(idx_HL0) || isempty(idx_HR0)
    error('One of the Arm index groups is empty (LL/LR/HL/HR). Check Arm.* indices.');
end

% ------------------------------------------------------------
% One parfor that computes BOTH same and other per bootstrap
% ------------------------------------------------------------


   
    idx_LL = idx_LL0;
    idx_LR = idx_LR0;
    idx_HL = idx_HL0;
    idx_HR = idx_HR0;

    for ar = 1:nAreas

        % =========================================================
        % =============== SAME (Proj_1) ============================
        % x = choice direction, y = action value
        % ---------------------------------------------------------
        x_LL = nanmean(Proj_1_B_Dir_Arm_All(idx_LL, window_size_L(ar)-Bin_Ext:window_size_L(ar)+Bin_Ext, ar), 1);
        y_LL = nanmean(Proj_1_B_SV_Arm_All (idx_LL,  window_size_L(ar)-Bin_Ext:window_size_L(ar)+Bin_Ext, ar), 1);

        x_LR = nanmean(Proj_1_B_Dir_Arm_All(idx_LR,  window_size_R(ar)-Bin_Ext:window_size_R(ar)+Bin_Ext, ar), 1);
        y_LR = nanmean(Proj_1_B_SV_Arm_All (idx_LR,  window_size_R(ar)-Bin_Ext:window_size_R(ar)+Bin_Ext, ar), 1);

        x_HL = nanmean(Proj_1_B_Dir_Arm_All(idx_HL,  window_size_L(ar)-Bin_Ext:window_size_L(ar)+Bin_Ext, ar), 1);
        y_HL = nanmean(Proj_1_B_SV_Arm_All (idx_HL,  window_size_L(ar)-Bin_Ext:window_size_L(ar)+Bin_Ext, ar), 1);

        x_HR = nanmean(Proj_1_B_Dir_Arm_All(idx_HR,  window_size_R(ar)-Bin_Ext:window_size_R(ar)+Bin_Ext, ar), 1);
        y_HR = nanmean(Proj_1_B_SV_Arm_All (idx_HR,  window_size_R(ar)-Bin_Ext:window_size_R(ar)+Bin_Ext, ar), 1);

        % Single point per condition = average over time
        LL = [nanmean(x_LL), nanmean(y_LL)];
        LR = [nanmean(x_LR), nanmean(y_LR)];
        HL = [nanmean(x_HL), nanmean(y_HL)];
        HR = [nanmean(x_HR), nanmean(y_HR)];

        D_left_same  = norm(HL - LL);
        D_right_same = norm(HR - LR);

        D_same = mean([D_left_same, D_right_same]);

        % =========================================================
        % =============== OTHER (Proj_2) ===========================
        % x = choice direction, y = action value
        % ---------------------------------------------------------
        x_LL = nanmean(Proj_1_B_Dir_Arm_All(idx_LL,  window_size_L(ar)-Bin_Ext:window_size_L(ar)+Bin_Ext, ar), 1);
        y_LL = nanmean(Proj_2_B_SV_Arm_All (idx_LL,  window_size_L(ar)-Bin_Ext:window_size_L(ar)+Bin_Ext, ar), 1);

        x_LR = nanmean(Proj_1_B_Dir_Arm_All(idx_LR,  window_size_R(ar)-Bin_Ext:window_size_R(ar)+Bin_Ext, ar), 1);
        y_LR = nanmean(Proj_2_B_SV_Arm_All (idx_LR,  window_size_R(ar)-Bin_Ext:window_size_R(ar)+Bin_Ext, ar), 1);

        x_HL = nanmean(Proj_1_B_Dir_Arm_All(idx_HL,  window_size_L(ar)-Bin_Ext:window_size_L(ar)+Bin_Ext, ar), 1);
        y_HL = nanmean(Proj_2_B_SV_Arm_All (idx_HL,  window_size_L(ar)-Bin_Ext:window_size_L(ar)+Bin_Ext, ar), 1);

        x_HR = nanmean(Proj_1_B_Dir_Arm_All(idx_HR,  window_size_R(ar)-Bin_Ext:window_size_R(ar)+Bin_Ext, ar), 1);
        y_HR = nanmean(Proj_2_B_SV_Arm_All (idx_HR,  window_size_R(ar)-Bin_Ext:window_size_R(ar)+Bin_Ext, ar), 1);

        LL = [nanmean(x_LL), nanmean(y_LL)];
        LR = [nanmean(x_LR), nanmean(y_LR)];
        HL = [nanmean(x_HL), nanmean(y_HL)];
        HR = [nanmean(x_HR), nanmean(y_HR)];

        D_left_other  = norm(HL - LL);
        D_right_other = norm(HR - LR);

        D_other = mean([D_left_other, D_right_other]);

        % Store
        Dist_LowHigh_Arm_1_boot(b, ar) = D_same;
        Dist_LowHigh_Arm_2_boot(b, ar) = D_other;
        Delta_boot(b, ar)              = D_same - D_other;

    end
end






%%

for a= 1:8
nsess_areas(a) = numel(find(~isnan(Dist_LowHigh_Arm_1_boot(:,a))==1));
end
mean1 = mean(Dist_LowHigh_Arm_1_boot, 1, 'omitnan');   % SAME
mean2 = mean(Dist_LowHigh_Arm_2_boot, 1, 'omitnan');   % OTHER

std_1  = std(Dist_LowHigh_Arm_1_boot, [], 1, 'omitnan')./sqrt(nsess_areas);
std_2  = std(Dist_LowHigh_Arm_2_boot, [], 1, 'omitnan')./sqrt(nsess_areas);

bArmeans = reshape([mean1; mean2], 1, []);  % 1 x 16
barSEMs  = reshape([std_1;  std_2 ], 1, []);  % 1 x 16

x_value = [1 2 4 5 7 8 10 11 13 14 16 17 19 20 22 23];



%%
diff_boot = Dist_LowHigh_Arm_1_boot - Dist_LowHigh_Arm_2_boot;
[h,p] = ttest(Dist_LowHigh_Arm_1_boot,Dist_LowHigh_Arm_2_boot);

% Point estimate per area
sepIdx = mean(diff_boot, 1, 'omitnan');     % 1 x 8
% Bootstrap uncertainty (SD)
sepIdxSD = std(diff_boot, [], 1, 'omitnan')./sqrt(nsess_areas); % 1 x 8

% (Optional but often preferred) 95% bootstrap CI
ciLow = prctile(diff_boot, 2.5, 1);
ciHigh = prctile(diff_boot, 97.5, 1);

% X axis
x = 1:nAreas;


%% correlation value difference and angle during reach trials (supplementary fig)
var_angle =2; % 1 = choice dir; 2 = Act value; 3 = Stim value.
figure('Color','w','Position',[300 300 800 400]); hold on;
for area = 1:8
area_angle=[];
area_angle = AllangleFolded (:,var_angle, area);
valid_area_angle=[]; valid_area_angle_r = [];
valid_area_angle_r = area_angle(~isnan(area_angle));
angle_more90=[]; angle_more90 = find (valid_area_angle_r>90);
diffangle =[]; diffangle = 90-(valid_area_angle_r(angle_more90)-90);


% valid_area_angle=valid_area_angle_r;      % % uncomment these two to flip theta
% valid_area_angle(angle_more90)=diffangle; 

valid_area_angle  =  valid_area_angle_r; % % comment these two to flip theta
 Matched_Dist= diff_boot(~isnan(diff_boot(:,area)),area);
subplot(2,4,area)
plot(valid_area_angle,Matched_Dist,'.','Color','c'); hold on
X = valid_area_angle;
Y = Matched_Dist;
 mdl = fitlm(X,Y);
            xx = linspace(min(X), max(X), 100);
            [yy, yCI] = predict(mdl, xx');

            plot(xx, yy, 'c','LineWidth',.75); hold on
%             plot(xx, yCI(:,1), 'r--')
%             plot(xx, yCI(:,2), 'r--')

            R = corr(X,Y,'rows','complete');
            text(0.05, 0.95, sprintf('r = %.2f',R), ...
                 'Units','normalized','FontSize',10,'FontWeight','normal','Color','c'); hold on


title(areaLabels{area})
ylabel('delta value difference')
xlabel('angle')
if area == 1 || area == 2 || area == 4
ylim ([-.5 1.5])
else 
    ylim ([-.5 1.05])
end
xlim([0 90])
sgtitle('Stimulus value - arm')
end

%% 
%%
Colors = [ [54 140 66]/255;     
           [210 212 113]/255;
           [59 127 137]/255;
           [175 149 132]/255;
           [67 170 175]/255;
           [232 174 135]/255;
           [140 140 140]/255;
           [243 168 168]/255 ];

figure('Color','w','Position',[300 300 400 400]); hold on;

% Colors
col_vert = [0 0 0];   % vertical error (std_1)
col_horz = [0 0 0];   % horizontal error (std_2)

% Determine axis limits
% maxVal = max([mean1 + std_1, mean2 + std_2], [], 'all');
maxVal =2.5;
% Diagonal reference (y = x)
plot([0 maxVal], [0 maxVal], 'k--', 'LineWidth', 1);

% Plot points with orthogonal error bars
for ar = 1:nAreas

    % Horizontal error bar: std of mean2 (X)
    plot([mean2(ar)-std_2(ar), mean2(ar)+std_2(ar)], ...
         [mean1(ar), mean1(ar)], ...
         'Color', Colors(ar,:), 'LineWidth', 1.5);

    % Vertical error bar: std of mean1 (Y)
    plot([mean2(ar), mean2(ar)], ...
         [mean1(ar)-std_1(ar), mean1(ar)+std_1(ar)], ...
         'Color', Colors(ar,:), 'LineWidth', 1.5);

    % Central point
    plot(mean2(ar), mean1(ar), 'o', ...
         'MarkerFaceColor', Colors(ar,:), ...
         'MarkerEdgeColor', 'none', ...
         'MarkerSize', 8);
   
end

% Axes formatting
axis square;

 xticks = [.2 1 1.6];
        yticks = [.2 1 1.6];

                set(gca, ...
                    'XTick', xticks, ...
                    'YTick', yticks, ...
                    'TickDir','out', ...
                      'LineWidth', .5,  ...
                    'FontSize',5);

xlim([.2 1.6]);
ylim([.2 1.6]);

xlabel('other');
ylabel('same');

title('Arm - Stim value');


box off;
f = gcf; 
            filename = strcat('Arm - Stim value','.pdf');
%             exportgraphics(f, filename, 'Resolution', 500);


%% ══════════════════════════════════════════════════════════════════════
% ══════════════════════════════════════════════════════════════════════
% STATISTICS — Cross-system readout
% Two-way ANOVAN with MonkeySession as blocking factor
% Factors: Condition (matched vs cross), Area
% Blocking: MonkeySession (accounts for session and monkey variance)
%
% Monkey assignment: sessions 1-32 = M1, sessions 33+ = M2
% ══════════════════════════════════════════════════════════════════════

% ── Build long format vectors ─────────────────────────────────────────
dist_vec   = [];
cond_vec   = {};
area_vec_r = {};
mSess_vec  = {};

nSessions = size(Dist_LowHigh_Arm_1_boot, 1);

for ar = 1:nAreas
    for s = 1:nSessions

        if s <= 32
            monk = 'M1';
        else
            monk = 'M2';
        end

        sessLabel = sprintf('%s_S%02d', monk, s);

        % Matched condition
        d1 = Dist_LowHigh_Arm_1_boot(s, ar);
        if ~isnan(d1)
            dist_vec(end+1)   = d1;
            cond_vec{end+1}   = 'Matched';
            area_vec_r{end+1} = areaLabels{ar};
            mSess_vec{end+1}  = sessLabel;
        end

        % Cross condition
        d2 = Dist_LowHigh_Arm_2_boot(s, ar);
        if ~isnan(d2)
            dist_vec(end+1)   = d2;
            cond_vec{end+1}   = 'Cross';
            area_vec_r{end+1} = areaLabels{ar};
            mSess_vec{end+1}  = sessLabel;
        end
    end
end

% ── Data summary ──────────────────────────────────────────────────────
fprintf('=== Cross-system readout data summary ===\n')
fprintf('Total observations:    %d\n', length(dist_vec))
fprintf('Matched observations:  %d\n', sum(strcmp(cond_vec, 'Matched')))
fprintf('Cross observations:    %d\n', sum(strcmp(cond_vec, 'Cross')))
fprintf('\nObservations per area:\n')
for ar = 1:nAreas
    n_match = sum(strcmp(area_vec_r, areaLabels{ar}) & strcmp(cond_vec, 'Matched'));
    n_cross = sum(strcmp(area_vec_r, areaLabels{ar}) & strcmp(cond_vec, 'Cross'));
    fprintf('  %-8s matched=%d  cross=%d\n', areaLabels{ar}, n_match, n_cross)
end

% ══════════════════════════════════════════════════════════════════════
% ANOVAN
% Factors:  Condition(1), Area(2), MonkeySession(3)
% Model:    Condition + Area + MonkeySession + Condition:Area
% MonkeySession = blocking factor
% ══════════════════════════════════════════════════════════════════════
fprintf('\nFitting ANOVAN model...\n')

modelMatrix = [...
    1 0 0;   % Condition
    0 1 0;   % Area
    0 0 1;   % MonkeySession (blocking)
    1 1 0];  % Condition x Area interaction

[p_anovan, tbl_anovan, stats_anovan] = anovan(dist_vec', ...
    {cond_vec', area_vec_r', mSess_vec'}, ...
    'model',    modelMatrix, ...
    'varnames', {'Condition','Area','MonkeySession'}, ...
    'display',  'off');

fprintf('\nFull ANOVAN table:\n')
disp(tbl_anovan)

% ── Parse table robustly ──────────────────────────────────────────────
p_cond   = NaN; F_cond   = NaN; df1_cond = NaN;
p_area   = NaN; F_area   = NaN; df1_area = NaN;
p_int    = NaN; F_int    = NaN; df1_int  = NaN;

% Error df from second to last row
df_error = tbl_anovan{end-1, 3};

for row = 2:size(tbl_anovan,1)-1
    tname = strtrim(tbl_anovan{row,1});

    if strcmpi(tname, 'Condition')
        F_cond   = tbl_anovan{row,6};
        p_cond   = tbl_anovan{row,7};
        df1_cond = tbl_anovan{row,3};

    elseif strcmpi(tname, 'Area')
        F_area   = tbl_anovan{row,6};
        p_area   = tbl_anovan{row,7};
        df1_area = tbl_anovan{row,3};

    elseif ~isempty(strfind(tname, 'Condition')) && ...
           ~isempty(strfind(tname, 'Area'))
        F_int   = tbl_anovan{row,6};
        p_int   = tbl_anovan{row,7};
        df1_int = tbl_anovan{row,3};
    end
end

fprintf('\n=== ANOVAN results ===\n')
if ~isnan(F_cond)
    fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', ...
        'Condition', df1_cond, df_error, F_cond, p_cond)
end
if ~isnan(F_area)
    fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', ...
        'Area', df1_area, df_error, F_area, p_area)
end
if ~isnan(F_int)
    fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', ...
        'Condition x Area', df1_int, df_error, F_int, p_int)
end

% ══════════════════════════════════════════════════════════════════════
% POST-HOC
% If Condition x Area significant: paired t-test per area Bonferroni
% If Condition significant only:   no post-hoc, effect consistent
% If neither significant:          no post-hoc
% ══════════════════════════════════════════════════════════════════════
pvals_r     = nan(1, nAreas);
tstats_r    = nan(1, nAreas);
match_means = nan(1, nAreas);
cross_means = nan(1, nAreas);
df_r        = nan(1, nAreas);

% Always compute per-area paired t-tests for descriptive purposes
for ar = 1:nAreas
    d1    = Dist_LowHigh_Arm_1_boot(:, ar);
    d2    = Dist_LowHigh_Arm_2_boot(:, ar);
    valid = ~isnan(d1) & ~isnan(d2);

    if sum(valid) < 2; continue; end

    [~, p, ~, stats] = ttest(d1(valid), d2(valid));
    pvals_r(ar)      = p;
    tstats_r(ar)     = stats.tstat;
    match_means(ar)  = mean(d1(valid));
    cross_means(ar)  = mean(d2(valid));
    df_r(ar)         = stats.df;
end

pvals_bonf_r = min(pvals_r * nAreas, 1);

if ~isnan(p_int) && p_int < 0.05

    fprintf('\n--- Post-hoc: Condition per area (Bonferroni) ---\n')
    fprintf('Interaction significant — testing matched vs cross per area\n\n')
    fprintf('%-8s %12s %12s %10s %8s %10s %10s %8s\n', ...
        'Area','Match mean','Cross mean','t','df','p (raw)','p (Bonf)','sig')

    for ar = 1:nAreas
        if isnan(pvals_r(ar)); continue; end
        if pvals_bonf_r(ar) < 0.001;     sig = '***';
        elseif pvals_bonf_r(ar) < 0.01;  sig = '**';
        elseif pvals_bonf_r(ar) < 0.05;  sig = '*';
        else;                              sig = 'ns';
        end
        fprintf('%-8s %12.4f %12.4f %10.3f %8.0f %10.4f %10.4f %8s\n', ...
            areaLabels{ar}, match_means(ar), cross_means(ar), ...
            tstats_r(ar), df_r(ar), ...
            pvals_r(ar), pvals_bonf_r(ar), sig)
    end

elseif ~isnan(p_cond) && p_cond < 0.05

    fprintf('\nCondition significant (p=%.4f), interaction not significant (p=%.4f)\n', ...
        p_cond, p_int)
    fprintf('Effect consistent across areas — no post-hoc needed.\n')
    fprintf('\nPer-area paired t-tests (uncorrected, descriptive only):\n')
    fprintf('%-8s %12s %12s %10s %8s %10s\n', ...
        'Area','Match mean','Cross mean','t','df','p (raw)')

    for ar = 1:nAreas
        if isnan(pvals_r(ar)); continue; end
        fprintf('%-8s %12.4f %12.4f %10.3f %8.0f %10.4f\n', ...
            areaLabels{ar}, match_means(ar), cross_means(ar), ...
            tstats_r(ar), df_r(ar), pvals_r(ar))
    end

else
    fprintf('\nCondition not significant (p=%.4f) — no post-hoc conducted.\n', ...
        p_cond)
    fprintf('\nPer-area paired t-tests (uncorrected, descriptive only):\n')
    fprintf('%-8s %12s %12s %10s %8s %10s\n', ...
        'Area','Match mean','Cross mean','t','df','p (raw)')

    for ar = 1:nAreas
        if isnan(pvals_r(ar)); continue; end
        fprintf('%-8s %12.4f %12.4f %10.3f %8.0f %10.4f\n', ...
            areaLabels{ar}, match_means(ar), cross_means(ar), ...
            tstats_r(ar), df_r(ar), pvals_r(ar))
    end
end

% ══════════════════════════════════════════════════════════════════════
% DESCRIPTIVE SUMMARY
% ══════════════════════════════════════════════════════════════════════
fprintf('\n=== Descriptive summary per area ===\n')
fprintf('Mean +- SEM across sessions\n\n')
fprintf('%-8s %22s %22s %12s\n', ...
    'Area','Matched','Cross','Reduction')
fprintf('%-8s %22s %22s %12s\n', ...
    '----','--------------------','--------------------','----------')

match_desc = nan(1, nAreas);
cross_desc = nan(1, nAreas);

for ar = 1:nAreas
    d1    = Dist_LowHigh_Arm_1_boot(:, ar);
    d2    = Dist_LowHigh_Arm_2_boot(:, ar);
    valid = ~isnan(d1) & ~isnan(d2);

    if sum(valid) < 2; continue; end

    m1        = mean(d1(valid));
    sem1      = std(d1(valid))  / sqrt(sum(valid));
    m2        = mean(d2(valid));
    sem2      = std(d2(valid))  / sqrt(sum(valid));
    reduction = (m1 - m2) / m1 * 100;

    match_desc(ar) = m1;
    cross_desc(ar) = m2;

    fprintf('%-8s %10.4f +- %6.4f %10.4f +- %6.4f %10.1f%%\n', ...
        areaLabels{ar}, m1, sem1, m2, sem2, reduction)
end

fprintf('\nOverall:\n')
fprintf('  Matched:   %.4f +- %.4f (mean +- SEM across areas)\n', ...
    mean(match_desc,'omitnan'), ...
    std(match_desc,'omitnan')/sqrt(sum(~isnan(match_desc))))
fprintf('  Cross:     %.4f +- %.4f (mean +- SEM across areas)\n', ...
    mean(cross_desc,'omitnan'), ...
    std(cross_desc,'omitnan')/sqrt(sum(~isnan(cross_desc))))
fprintf('  Reduction: %.1f%%\n', ...
    mean((match_desc-cross_desc)./match_desc*100,'omitnan'))

fprintf('\nCross-system readout statistics done.\n')




mean1 = mean(Dist_LowHigh_Arm_1_boot, 1, 'omitnan');   % SAME
mean2 = mean(Dist_LowHigh_Arm_2_boot, 1, 'omitnan');   % OTHER

std_1  = std(Dist_LowHigh_Arm_1_boot, [], 1, 'omitnan')./sqrt(nsess_areas);
std_2  = std(Dist_LowHigh_Arm_2_boot, [], 1, 'omitnan')./sqrt(nsess_areas);
%% For sessions with similar behavior between saccade and reach
Sim_behavSess = [ 11  15  34 35 37 45  49  50  ];

Dist_SimBehav_1 = Dist_LowHigh_Arm_1_boot (Sim_behavSess,:) ; 
Dist_SimBehav_2 = Dist_LowHigh_Arm_2_boot (Sim_behavSess,:) ; 


for ar= 1:8
nsess_areas(ar) = numel(find(~isnan(Dist_SimBehav_1(:,ar))==1));
end

mean1SimBehav = mean(Dist_SimBehav_1, 1, 'omitnan');   % SAME
mean2SimBehav = mean(Dist_SimBehav_2, 1, 'omitnan');   % OTHER

std_1SimBehav  = std(Dist_SimBehav_1, [], 1, 'omitnan')./sqrt(nsess_areas);
std_2SimBehav  = std(Dist_SimBehav_2, [], 1, 'omitnan')./sqrt(nsess_areas);



Colors = [ [54 140 66]/255;     
           [210 212 113]/255;
           [59 127 137]/255;
           [175 149 132]/255;
           [67 170 175]/255;
           [232 174 135]/255;
           [140 140 140]/255;
           [243 168 168]/255 ];

figure('Color','w','Position',[300 300 400 400]); hold on;

% Colors
col_vert = [0 0 0];   % vertical error (std_1)
col_horz = [0 0 0];   % horizontal error (std_2)

% Determine axis limits
% maxVal = max([mean1 + std_1, mean2 + std_2], [], 'all');
maxVal =2.5;
% Diagonal reference (y = x)
plot([0 maxVal], [0 maxVal], 'k--', 'LineWidth', 1);

% Plot points with orthogonal error bars
for ar = 1:nAreas

    % Horizontal error bar: std of mean2 (X)
    plot([mean2SimBehav(ar)-std_2SimBehav(ar), mean2SimBehav(ar)+std_2SimBehav(ar)], ...
         [mean1SimBehav(ar), mean1SimBehav(ar)], ...
         'Color', Colors(ar,:), 'LineWidth', 1);

    % Vertical error bar: std of mean1 (Y)
    plot([mean2SimBehav(ar), mean2SimBehav(ar)], ...
         [mean1SimBehav(ar)-std_1SimBehav(ar), mean1SimBehav(ar)+std_1SimBehav(ar)], ...
         'Color', Colors(ar,:), 'LineWidth', 1);

    % Central point
    plot(mean2SimBehav(ar), mean1SimBehav(ar), 'o', ...
         'MarkerFaceColor', Colors(ar,:), ...
         'MarkerEdgeColor', 'none', ...
         'MarkerSize', 5);
   
end

% Axes formatting
axis square;

 xticks = [0:.2:2.2];
        yticks = [0:.2:2.2];

                set(gca, ...
                    'XTick', xticks, ...
                    'YTick', yticks, ...
                    'TickDir','out', ...
                      'LineWidth', .5,  ...
                    'FontSize',5);

xlim([0 2.2]);
ylim([0 2.2]);

xlabel('other');
ylabel('same');

title('Arm - Stim value same behav');


box off;
f = gcf; 
%             filename = strcat('Arm - Stim value','.pdf');
%             exportgraphics(f, filename, 'Resolution', 500);

% ══════════════════════════════════════════════════════════════════════
% STATISTICS — Cross-system readout (similar behavior sessions only)
% ══════════════════════════════════════════════════════════════════════

Sim_behavSess_labels = Sim_behavSess;
nSessions_sub = length(Sim_behavSess);

% ── Build long format vectors ─────────────────────────────────────────
dist_vec_sub   = [];
cond_vec_sub   = {};
area_vec_sub   = {};
mSess_vec_sub  = {};

for ar = 1:nAreas
    for si = 1:nSessions_sub
        s = Sim_behavSess(si);

        if s <= 32
            monk = 'M1';
        else
            monk = 'M2';
        end
        sessLabel = sprintf('%s_S%02d', monk, s);

        d1 = Dist_SimBehav_1(si, ar);
        if ~isnan(d1)
            dist_vec_sub(end+1)   = d1;
            cond_vec_sub{end+1}   = 'Matched';
            area_vec_sub{end+1}   = areaLabels{ar};
            mSess_vec_sub{end+1}  = sessLabel;
        end

        d2 = Dist_SimBehav_2(si, ar);
        if ~isnan(d2)
            dist_vec_sub(end+1)   = d2;
            cond_vec_sub{end+1}   = 'Cross';
            area_vec_sub{end+1}   = areaLabels{ar};
            mSess_vec_sub{end+1}  = sessLabel;
        end
    end
end

% ── Data summary ──────────────────────────────────────────────────────
fprintf('\n=== Cross-system readout — Similar behavior sessions Arm ===\n')
fprintf('Sessions: %s\n', mat2str(Sim_behavSess))
fprintf('Total observations:    %d\n', length(dist_vec_sub))
fprintf('Matched observations:  %d\n', sum(strcmp(cond_vec_sub, 'Matched')))
fprintf('Cross observations:    %d\n', sum(strcmp(cond_vec_sub, 'Cross')))
fprintf('\nObservations per area:\n')
for ar = 1:nAreas
    n_match = sum(strcmp(area_vec_sub, areaLabels{ar}) & strcmp(cond_vec_sub, 'Matched'));
    n_cross = sum(strcmp(area_vec_sub, areaLabels{ar}) & strcmp(cond_vec_sub, 'Cross'));
    fprintf('  %-8s matched=%d  cross=%d\n', areaLabels{ar}, n_match, n_cross)
end

% ── ANOVAN ────────────────────────────────────────────────────────────
modelMatrix = [...
    1 0 0;   % Condition
    0 1 0;   % Area
    0 0 1;   % MonkeySession (blocking)
    1 1 0];  % Condition x Area

[p_anovan_sub, tbl_anovan_sub, stats_anovan_sub] = anovan(dist_vec_sub', ...
    {cond_vec_sub', area_vec_sub', mSess_vec_sub'}, ...
    'model',    modelMatrix, ...
    'varnames', {'Condition','Area','MonkeySession'}, ...
    'display',  'off');

% ── Parse table ───────────────────────────────────────────────────────
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

fprintf('\n--- ANOVAN results (similar behavior sessions) ---\n')
if ~isnan(F_cond_s)
    fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', 'Condition', df1_cond_s, df_error_s, F_cond_s, p_cond_s)
end
if ~isnan(F_area_s)
    fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', 'Area', df1_area_s, df_error_s, F_area_s, p_area_s)
end
if ~isnan(F_int_s)
    fprintf('%-25s F(%d,%d) = %.3f, p = %.4f\n', 'Condition x Area', df1_int_s, df_error_s, F_int_s, p_int_s)
end

% ── Post-hoc: per-area paired t-tests ─────────────────────────────────
pvals_sub      = nan(1, nAreas);
tstats_sub     = nan(1, nAreas);
match_means_s  = nan(1, nAreas);
cross_means_s  = nan(1, nAreas);
df_sub         = nan(1, nAreas);

for ar = 1:nAreas
    d1    = Dist_SimBehav_1(:, ar);
    d2    = Dist_SimBehav_2(:, ar);
    valid = ~isnan(d1) & ~isnan(d2);
    if sum(valid) < 2; continue; end

    [~, p, ~, stats] = ttest(d1(valid), d2(valid));
    pvals_sub(ar)     = p;
    tstats_sub(ar)    = stats.tstat;
    match_means_s(ar) = mean(d1(valid));
    cross_means_s(ar) = mean(d2(valid));
    df_sub(ar)        = stats.df;
end

pvals_bonf_sub = min(pvals_sub * nAreas, 1);

if ~isnan(p_int_s) && p_int_s < 0.05

    fprintf('\n--- Post-hoc: Condition per area (Bonferroni) ---\n')
    fprintf('Interaction significant — testing matched vs cross per area\n\n')
    fprintf('%-8s %12s %12s %10s %8s %10s %10s %8s\n', ...
        'Area','Match mean','Cross mean','t','df','p (raw)','p (Bonf)','sig')
    for ar = 1:nAreas
        if isnan(pvals_sub(ar)); continue; end
        if pvals_bonf_sub(ar) < 0.001;      sig = '***';
        elseif pvals_bonf_sub(ar) < 0.01;   sig = '**';
        elseif pvals_bonf_sub(ar) < 0.05;   sig = '*';
        else;                                 sig = 'ns';
        end
        fprintf('%-8s %12.4f %12.4f %10.3f %8.0f %10.4f %10.4f %8s\n', ...
            areaLabels{ar}, match_means_s(ar), cross_means_s(ar), ...
            tstats_sub(ar), df_sub(ar), pvals_sub(ar), pvals_bonf_sub(ar), sig)
    end

elseif ~isnan(p_cond_s) && p_cond_s < 0.05

    fprintf('\nCondition significant (p=%.4f), interaction not significant (p=%.4f)\n', ...
        p_cond_s, p_int_s)
    fprintf('Effect consistent across areas — no post-hoc needed.\n')
    fprintf('\nPer-area paired t-tests (uncorrected, descriptive only):\n')
    fprintf('%-8s %12s %12s %10s %8s %10s\n', ...
        'Area','Match mean','Cross mean','t','df','p (raw)')
    for ar = 1:nAreas
        if isnan(pvals_sub(ar)); continue; end
        fprintf('%-8s %12.4f %12.4f %10.3f %8.0f %10.4f\n', ...
            areaLabels{ar}, match_means_s(ar), cross_means_s(ar), ...
            tstats_sub(ar), df_sub(ar), pvals_sub(ar))
    end

else
    fprintf('\nCondition not significant (p=%.4f) — no post-hoc conducted.\n', p_cond_s)
    fprintf('\nPer-area paired t-tests (uncorrected, descriptive only):\n')
    fprintf('%-8s %12s %12s %10s %8s %10s\n', ...
        'Area','Match mean','Cross mean','t','df','p (raw)')
    for ar = 1:nAreas
        if isnan(pvals_sub(ar)); continue; end
        fprintf('%-8s %12.4f %12.4f %10.3f %8.0f %10.4f\n', ...
            areaLabels{ar}, match_means_s(ar), cross_means_s(ar), ...
            tstats_sub(ar), df_sub(ar), pvals_sub(ar))
    end
end

% ── Descriptive summary ──────────────────────────────────────────────
fprintf('\n=== Descriptive summary (similar behavior sessions) ===\n')
fprintf('%-8s %22s %22s %12s\n', 'Area','Matched','Cross','Reduction')

match_desc_s = nan(1, nAreas);
cross_desc_s = nan(1, nAreas);

for ar = 1:nAreas
    d1 = Dist_SimBehav_1(:,ar); d2 = Dist_SimBehav_2(:,ar);
    valid = ~isnan(d1) & ~isnan(d2);
    if sum(valid) < 1; continue; end
    m1 = mean(d1(valid)); sem1 = std(d1(valid))/sqrt(sum(valid));
    m2 = mean(d2(valid)); sem2 = std(d2(valid))/sqrt(sum(valid));
    red = (m1 - m2)/m1 * 100;
    match_desc_s(ar) = m1;
    cross_desc_s(ar) = m2;
    fprintf('%-8s %10.4f +- %6.4f %10.4f +- %6.4f %10.1f%%\n', ...
        areaLabels{ar}, m1, sem1, m2, sem2, red)
end

fprintf('\nOverall:\n')
fprintf('  Matched:   %.4f +- %.4f\n', ...
    mean(match_desc_s,'omitnan'), std(match_desc_s,'omitnan')/sqrt(sum(~isnan(match_desc_s))))
fprintf('  Cross:     %.4f +- %.4f\n', ...
    mean(cross_desc_s,'omitnan'), std(cross_desc_s,'omitnan')/sqrt(sum(~isnan(cross_desc_s))))
fprintf('  Reduction: %.1f%%\n', ...
    mean((match_desc_s-cross_desc_s)./match_desc_s*100,'omitnan'))

fprintf('\nSimilar behavior sessions statistics Arm done.\n')

% ══════════════════════════════════════════════════════════════════════
% ANOVAN — Cross-system readout with Behavioral Similarity factor
% Factors: Condition (matched vs cross), BehavSimilarity, Area, Monkey
% ══════════════════════════════════════════════════════════════════════


dist_vec_bs   = [];
cond_vec_bs   = {};
area_vec_bs2  = {};
behav_vec_bs2 = {};
monk_vec_bs2  = {};

for ar = 1:nAreas
    for s = 1:size(Dist_LowHigh_Arm_1_boot, 1)

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

        d1 = Dist_LowHigh_Arm_1_boot(s, ar);
        if ~isnan(d1)
            dist_vec_bs(end+1)    = d1;
            cond_vec_bs{end+1}    = 'Matched';
            area_vec_bs2{end+1}   = areaLabels{ar};
            behav_vec_bs2{end+1}  = behavLabel;
            monk_vec_bs2{end+1}   = monkLabel;
        end

        d2 = Dist_LowHigh_Arm_2_boot(s, ar);
        if ~isnan(d2)
            dist_vec_bs(end+1)    = d2;
            cond_vec_bs{end+1}    = 'Cross';
            area_vec_bs2{end+1}   = areaLabels{ar};
            behav_vec_bs2{end+1}  = behavLabel;
            monk_vec_bs2{end+1}   = monkLabel;
        end
    end
end

% ── Data summary ──────────────────────────────────────────────────────
fprintf('\n=== Cross-system readout with Behavioral Similarity Arm===\n')
fprintf('Total observations:   %d\n', length(dist_vec_bs))
fprintf('Matched observations: %d\n', sum(strcmp(cond_vec_bs, 'Matched')))
fprintf('Cross observations:   %d\n', sum(strcmp(cond_vec_bs, 'Cross')))
fprintf('Similar sessions:     %d\n', sum(strcmp(behav_vec_bs2, 'Similar')))
fprintf('Different sessions:   %d\n', sum(strcmp(behav_vec_bs2, 'Different')))

% ── ANOVAN ────────────────────────────────────────────────────────────
% Condition, BehavSimilarity, Area, Monkey(blocking)
% Interactions: Condition×BehavSimilarity, Condition×Area
modelMatrix_bs2 = [...
    1 0 0 0;   % Condition
    0 1 0 0;   % BehavSimilarity
    0 0 1 0;   % Area
    0 0 0 1;   % Monkey (blocking)
    1 1 0 0;   % Condition × BehavSimilarity
    1 0 1 0];  % Condition × Area

[p_bs2, tbl_bs2, stats_bs2] = anovan(dist_vec_bs', ...
    {cond_vec_bs', behav_vec_bs2', area_vec_bs2', monk_vec_bs2'}, ...
    'model',    modelMatrix_bs2, ...
    'varnames', {'Condition','BehavSimilarity','Area','Monkey'}, ...
    'display',  'off');

% ── Parse table ───────────────────────────────────────────────────────
df_err_bs2 = tbl_bs2{end-1, 3};

fprintf('\n--- ANOVAN results ---\n')
for row = 2:size(tbl_bs2,1)-1
    tname = strtrim(tbl_bs2{row,1});
    F_val = tbl_bs2{row,6};
    p_val = tbl_bs2{row,7};
    df1   = tbl_bs2{row,3};
    if ~isnan(F_val)
        fprintf('%-30s F(%d,%d) = %.3f, p = %.4f\n', ...
            tname, df1, df_err_bs2, F_val, p_val)
    end
end

% ── Descriptive: readout reduction by behavioral similarity ───────────
fprintf('\nPer-area descriptive by behavioral similarity:\n')
for bv = {'Similar', 'Different'}
    fprintf('\n  %s sessions:\n', bv{1})
    fprintf('  %-8s %12s %12s %12s\n', 'Area', 'Matched', 'Cross', 'Reduction')
    
    if strcmp(bv{1}, 'Similar')
        sessSet = Sim_behavSess;
    else
        sessSet = setdiff(1:size(Dist_LowHigh_Arm_1_boot,1), Sim_behavSess);
    end
    
    match_means_bv = nan(1, nAreas);
    cross_means_bv = nan(1, nAreas);
    
    for ar = 1:nAreas
        d1 = Dist_LowHigh_Arm_1_boot(sessSet, ar);
        d2 = Dist_LowHigh_Arm_2_boot(sessSet, ar);
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
    fprintf('    Matched: %.4f +- %.4f\n', ...
        mean(match_means_bv, 'omitnan'), std(match_means_bv, 'omitnan')/sqrt(sum(~isnan(match_means_bv))))
    fprintf('    Cross:   %.4f +- %.4f\n', ...
        mean(cross_means_bv, 'omitnan'), std(cross_means_bv, 'omitnan')/sqrt(sum(~isnan(cross_means_bv))))
end

fprintf('\nCross-system readout all sessions behavioral similarity analysis Arm done.\n')