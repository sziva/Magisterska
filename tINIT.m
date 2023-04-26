%initialise Cobra toolbox
initCobraToolbox(false)
changeCobraSolver('gurobi','all');
setRavenSolver('gurobi');

gtex_data = readtable("dataGSE39791_H_C.xlsx");
%gtex_data(1:5,1:5)

%Load model and convert model
load('/Users/zivaskof/Documents/MATLAB/mag/Human-GEM-1.14.0/model/Human-GEM.mat');
ihuman = addBoundaryMets(ihuman);
essentialTasks_H=parseTaskList('/Users/zivaskof/Documents/MATLAB/mag/Human-GEM-1.14.0/data/metabolicTasks/metabolicTasks_Essential.txt');
model_Healthy=ravenCobraWrapper(ihuman);

num_columns = size(gtex_data, 2);

for col = 2:num_columns

    nameAr = gtex_data.Properties.VariableNames(col);
    name = char(nameAr)

    % extract the tissue and gene names
    data_struct.tissues = gtex_data.Properties.VariableNames(col)'; % sample (tissue) names
    data_struct.genes = gtex_data.Gene_ID;  % gene names
    data_struct.levels = table2array(gtex_data(:, col));  % gene TPM values
    a = table2array(gtex_data(:, col));
    data_struct.threshold = prctile(a, 75);

    data_struct
    
    % see what the other inputs mean by typing "help checkTasks"
    checkTasks(ihuman, [], true, false, false, essentialTasks_H);
    
    
    liver_tINIT_H = getINITModel2(ihuman, name, [], [], data_struct, [], true, [], true, true, essentialTasks_H, [], []);

    save(sprintf('%s.mat', name), 'liver_tINIT_H');
end
