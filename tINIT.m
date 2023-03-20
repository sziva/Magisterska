%initialise Cobra toolbox
initCobraToolbox(false)
changeCobraSolver('gurobi','all');
setRavenSolver('gurobi');

gtex_data = readtable("dataGSE39791_H.xlsx");
%gtex_data(1:5,1:5)

% extract the tissue and gene names
data_struct.tissues = gtex_data.Properties.VariableNames(2)'  
data_struct.genes = gtex_data.Symbol;  
data_struct.levels = table2array(gtex_data(:, 2:end));

data_struct.threshold = 1;
%data_struct;

%Load model and convert model
load('/Users/zivaskof/Documents/MATLAB/mag/Human-GEM-1.14.0/model/Human-GEM.mat');
ihuman = addBoundaryMets(ihuman);
essentialTasks_H=parseTaskList('/Users/zivaskof/Documents/MATLAB/mag/Human-GEM-1.14.0/data/metabolicTasks/metabolicTasks_Essential.txt');



% see what the other inputs mean by typing "help checkTasks"
%checkTasks(ihuman, [], true, false, false, essentialTasks_H);

refModel = ihuman;          
tissue = 'KM_001N';           
arrayData = data_struct;   
taskStructure = essentialTasks_H; 

liverGEM = getINITModel2(refModel, tissue, [], [], arrayData, [], true, [], true, true, taskStructure, [], []);
