% Initialize COBRA Toolbox and set the solver
initCobraToolbox(false);
changeCobraSolver('gurobi','all');
setRavenSolver('gurobi');

% Read gene expression data
gtex_data = readtable('dataGSE39791_I_C.xlsx');

% Load the global metabolic model
load('Human-GEM.mat');
ihuman = addBoundaryMets(ihuman);
model_Healthy=ravenCobraWrapper(ihuman);

% Parse essential metabolic tasks
essentialTasks_H = parseTaskList('metabolicTasks_Essential.txt');

% Iterate over tissue columns in the gene expression data
num_columns = size(gtex_data, 2);
for col = 3:num_columns
    
    col

    nameAr = gtex_data.Properties.VariableNames(col);
    name = "Gimme_model_I_" + char(nameAr)

    exprData.gene = gtex_data.Gene_ID;  % Gene names
    exprData.value = table2array(gtex_data(:, col));  % Gene expression values
   
    % Map gene expression to reactions
    rxn_expression = mapExpressionToReactions(model_Healthy, exprData);
    th_lb=prctile(rxn_expression,75);

    for k=1:length(rxn_expression)
        if isnan(rxn_expression(k))==1
            rxn_expression(k)=-1;
        end
    end

    % Generate tissue-specific model using GIMME
    options.solver = 'GIMME';
    options.expressionRxns = rxn_expression;
    options.threshold = th_lb;
    Gimme_model_I = createTissueSpecificModel(model_Healthy, options);

    Gimme_model_I=ravenCobraWrapper(Gimme_model_I)%put in Raven format
    refModel=ihuman;

    refModelNoExc = removeReactions(refModel,union(Gimme_model_I.rxns,getExchangeRxns(refModel)),true,true);
    paramsFT = [];  
    [outModel,addedRxnMat] = fitTasks(Gimme_model_I,refModelNoExc,[],true,[],essentialTasks_H,paramsFT);
    addedRxnsForTasks = refModelNoExc.rxns(any(addedRxnMat,2));

    Gimme_model_I = outModel;


    % Save the tissue-specific model
    save(sprintf('%s.mat', name), 'Gimme_model_I');

    name = "Gimme_modelC_I_" + char(nameAr)

    Gimme_model_I=ravenCobraWrapper(Gimme_model_I);

    save(sprintf('%s.mat', name), 'Gimme_model_I');
end
