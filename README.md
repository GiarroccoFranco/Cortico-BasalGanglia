README


Embodied Reinforcement Learning Analysis Code

MATLAB requirements and installation

The analysis code was developed and tested in MATLAB R2023b. The following MATLAB toolboxes are required:
•	Statistics and Machine Learning Toolbox
•	Parallel Computing Toolbox
No additional installation is required beyond MATLAB and the listed toolboxes. Downloading the repository and preparing the files should take less than 5 minutes.

Overview
This repository contains the MATLAB code used for the analyses reported in the manuscript “Embodied reinforcement learning in the primate cortico-basal ganglia system.”
The scripts implement the main single-neuron and population-level analyses, including:
•	regression analyses of neuronal activity;
•	quantification of the fraction of neurons encoding task variables;
•	targeted dimensionality reduction;
•	computation of angles between value-coding dimensions;
•	within- and across-motor-system decoding analyses.
Most population-level scripts were developed to operate on the complete dataset and are therefore not expected to run using the single-session example dataset. The repository includes one example recording session that can be used to run the single-neuron regression analysis and demonstrate the expected data organization and analysis workflow.
The results generated from the example session are illustrative and are not intended to reproduce the population-level statistical results reported in the manuscript, which were obtained using the complete dataset.
Repository setup
Download all files and place them in the same directory.
Before running the example analysis, replace the directory placeholder at the beginning of the script with the local path to this folder:
cd('insert the directory of the folder here');
The analysis uses parfor loops. MATLAB may automatically start a parallel pool when the analysis begins.

Main scripts to run:
RegressionAndValueCoding.m
The single-neuron regression script can be run using the example recording session included in the repository. It should take no longer than 5 minutes. 
The script:
1.	loads the behavioral and neuronal data from the example session;
2.	identifies novel-learning trials performed using eye movements or arm reaches;
3.	organizes neurons according to their recorded brain area;
4.	fits a linear regression model separately for each neuron and time bin;
5.	extracts regression coefficients and statistical significance values for the task variables and their interactions;
6.	plots the fraction of neurons significantly encoding each task variable over time;
7.	compares the fractions of neurons showing sustained motor-system-independent and motor-system-specific value coding.
The regression model includes movement direction, stimulus value, motor system, reward outcome, reaction time, object identity, and the corresponding interaction terms.

The following custom functions must be located in the same directory as the main script:
FindDirection.m
DefineIDs.m
GetElectrodesLocation_BothMonkeys.m
CreateDataRegression_2.m

Running the script produces:
•	a figure showing the time-resolved fraction of neurons encoding each task variable across the recorded areas in the example session;
•	a bar plot comparing sustained value coding with sustained value-by-motor-system interaction coding;
•	summary statistics printed in the MATLAB Command Window.
Because the supplied dataset contains only one recording session, these outputs demonstrate the execution of the analysis pipeline but do not reproduce the full-dataset results presented in the manuscript.

TargetedDimensionalityReduction.m
This script performs the population-level feature-space analysis used to characterize the geometry of value representations across motor systems.
The script:
1.	loads neuronal data across recording sessions;
2.	fits separate regression models for saccade and reach trials;
3.	extracts population coding vectors for stimulus value;
4.	identifies the time bin at which each value-coding vector has maximal population magnitude;
5.	computes the angle between value-coding dimensions for saccades and reaches;
6.	concatenates neuronal coefficients across sessions to construct pseudo-populations;
7.	estimates angle distributions by bootstrap resampling;
8.	compares results obtained from all neurons, value-coding neurons, and neurons shared across motor systems;
9.	generates plots of the resulting angles across brain areas;
10.	performs the statistical comparisons reported for the feature-space analysis.
This script is designed to run on the complete dataset and is not expected to run using the single-session example dataset. The code is provided to document the targeted dimensionality reduction pipeline used in the manuscript.

WithinAndCrossSystemReadout.m
This script evaluates how well population activity can be read out within the same motor system and across motor systems.
The script:
1.	fits separate population regression models for saccade and reach trials; 
2.	extracts coding dimensions for stimulus value and choice direction; 
3.	projects population activity onto coding dimensions derived from the same motor system; 
4.	projects the same activity onto coding dimensions derived from the other motor system; 
5.	concatenates projections and trial labels across recording sessions; 
6.	compares within-system and cross-system representations across brain areas; 
7.	quantifies the separation of low- and high-value conditions in the projected population activity; 
8.	generates the projected population variables used for the subsequent within- and cross-system value-distance analyses. 
This script is designed to run on the complete dataset and is not expected to run using the single-session example dataset.

PlotValueDistanceWithinAndCrossSystem_Saccade.m
This script must be run after WithinAndCrossSystemReadout.m, because it uses the projected population activity and trial-label variables generated by that script.
The script:
1.	separates saccade trials according to stimulus value and choice direction; 
2.	identifies the time window showing the strongest separation between low- and high-value conditions; 
3.	computes the distance between low- and high-value population representations; 
4.	compares distances obtained when activity is projected onto the saccade value-coding dimension with distances obtained using the reach value-coding dimension; 
5.	summarizes the within-system and cross-system readout distances across sessions and brain areas; 
6.	generates the corresponding comparison plots; 
7.	performs the statistical analyses reported for the saccade readout results; 
8.	repeats the analysis for the subset of sessions with similar behavior across motor systems. 
The related script PlotValueDistanceWithinAndCrossSystem_Reach.m performs the same analysis for reach trials.
Both scripts are designed to run on the variables generated by WithinAndCrossSystemReadout.m using the complete dataset and are not expected to run independently or with the single-session example dataset.

SVM_WithinAndCrossSystemDecoding.m
This script performs within- and cross-motor-system decoding of stimulus value from population activity.
The script:
1.	loads neuronal data across recording sessions and brain areas; 
2.	divides saccade and reach trials into low- and high-value groups; 
3.	trains support vector machine classifiers to decode stimulus value separately within the saccade and reach conditions; 
4.	performs cross-system decoding by training the classifier on one motor system and testing it on the other; 
5.	computes shuffled-label decoding baselines; 
6.	generates time-resolved decoding curves for saccade and reach trials across brain areas; 
7.	compares within-system and cross-system decoding accuracy; 
8.	summarizes decoding accuracy over the analysis window; 
9.	generates scatter plots comparing within-system and cross-system performance; 
10.	performs the associated statistical analyses for the full dataset, for each monkey separately, and for sessions with similar behavior across motor systems.
This script is designed to run on the complete dataset and is not expected to run using the single-session example dataset.

