%initialise Cobra toolbox
%initCobraToolbox(false)
%changeCobraSolver('gurobi','all');
%setRavenSolver('gurobi');

gtex_data = readtable("dataGSE39791_H.xlsx");
%gtex_data(1:5,1:5)

% extract the tissue and gene names
data_struct.tissues = gtex_data.Properties.VariableNames(2)'  % sample (tissue) names
data_struct.genes = gtex_data.Symbol;  % gene names
data_struct.levels = table2array(gtex_data(:, 2:end));  % gene TPM values

data_struct.threshold = 1;

data_struct;

%Load model and convert model
load('/Users/zivaskof/Documents/MATLAB/mag/Human-GEM-1.14.0/model/Human-GEM.mat');
ihuman = addBoundaryMets(ihuman);
essentialTasks_H=parseTaskList('/Users/zivaskof/Documents/MATLAB/mag/Human-GEM-1.14.0/data/metabolicTasks/metabolicTasks_Essential.txt');
%essentialTasks_I=parseTaskList('metabolicTasks_Essential_infected.xlsx');
%model_Healthy=ravenCobraWrapper(ihuman)


% see what the other inputs mean by typing "help checkTasks"
checkTasks(ihuman, [], true, false, false, essentialTasks_H);

refModel = ihuman;          % the reference model from which the GEM will be extracted
tissue = 'KM_001N';           % must match the tissue name in data_struct.tissues
celltype = [];              % used if tissues are subdivided into cell type, which is not the case here
hpaData = [];               % data structure containing protein abundance information (not used here)
arrayData = data_struct;    % data structure with gene (RNA) abundance information
metabolomicsData = [];      % list of metabolite names if metabolomic data is available
removeGenes = true;         % (default) remove lowly/non-expressed genes from the extracted GEM
taskFile = [];              % we already loaded the task file, so this input is not required
useScoresForTasks = true;   % (default) use expression data to decide which reactions to keep
printReport = true;         % (default) print status/completion report to screen
taskStructure = essentialTasks_H;  % metabolic task structure (used instead "taskFile")
params = [];                % additional optimization parameters for the INIT algorithm
paramsFT = [];              % additional optimization parameters for the fit-tasks algorithm

liverGEM = getINITModel2(refModel, tissue, celltype, hpaData, arrayData, metabolomicsData, removeGenes, taskFile, useScoresForTasks, printReport, taskStructure, params, paramsFT);
liverGEM