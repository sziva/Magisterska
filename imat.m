% Initialize COBRA Toolbox and set the solver
%initCobraToolbox(false);
%changeCobraSolver('gurobi','all');
%setRavenSolver('gurobi');

% Load the global metabolic model
load('Human-GEM.mat');
ihuman = addBoundaryMets(ihuman);

model_Healthy=ravenCobraWrapper(ihuman);


% Read gene expression data
gtex_data = readtable('dataGSE39791_I_C.xlsx');
% Parse essential metabolic tasks
essentialTasks_H = parseTaskList('metabolicTasks_Essential.txt');

%skip pri H 11 , 15
%skip pri I 6, 8

% Iterate over tissue columns in the gene expression data
num_columns = size(gtex_data, 2);
for col = 9:num_columns
    

    nameAr = gtex_data.Properties.VariableNames(col);
    name = "iMAT_model_I_" + char(nameAr)

    exprData.gene = model_Healthy.genes;  % Gene names
    exprData.value = table2array(gtex_data(:, col));  % Gene expression values
   
    % Map gene expression to reactions
    rxn_expression= mapExpressionToReactions(model_Healthy,exprData);
    th_lb=prctile(rxn_expression,75);
    for k=1:length(rxn_expression)
        if isnan(rxn_expression(k))==1
            rxn_expression(k)=-1;
        end
    end

    options.solver='iMAT';
    options.expressionRxns=rxn_expression;
    options.threshold_lb=th_lb;
    options.threshold_ub=th_lb;
    iMAT_model_I=createTissueSpecificModel(model_Healthy, options);
    
    iMAT_model_I=ravenCobraWrapper(iMAT_model_I)%put in Raven format
    
    checkTasks(iMAT_model_I, [], true, false, false, essentialTasks_H)
    refModel=ihuman;
    
    %Remove exchange reactions and reactions already included in the iMAT model
    refModelNoExc = removeReactions(refModel,union(iMAT_model_I.rxns,getExchangeRxns(refModel)),true,true)
    paramsFT = []  ;
    col
    [outModel,addedRxnMat] = fitTasks(iMAT_model_I,refModelNoExc,[],true,[],essentialTasks_H,paramsFT)
    
    addedRxnsForTasks = refModelNoExc.rxns(any(addedRxnMat,2))
    
    % The model can now perform all the tasks defined in the task list.
    iMAT_model_I = outModel;

        % Save the tissue-specific model
    save(sprintf('%s.mat', name), 'iMAT_model_I');

    name = "iMAT_modelC_I_" + char(nameAr);

    iMAT_model_I=ravenCobraWrapper(iMAT_model_I);

    save(sprintf('%s.mat', name), 'iMAT_model_I');

end
