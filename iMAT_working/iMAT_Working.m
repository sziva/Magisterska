% Initialize COBRA Toolbox and set the solver
initCobraToolbox(false);
changeCobraSolver('gurobi','all');
setRavenSolver('gurobi');

load('Human-GEM.mat');
ihuman = addBoundaryMets(ihuman);

model_Healthy=ravenCobraWrapper(ihuman);


gtex_data = readtable('dataGSE39791_H_C.xlsx');
essentialTasks_H = parseTaskList('metabolicTasks_Essential.txt');

num_columns = size(gtex_data, 2);
for col = 3:num_columns
    
    nameAr = gtex_data.Properties.VariableNames(col);
    name = char(nameAr)

    exprData.gene = model_Healthy.genes;  % Gene names
    exprData.value = table2array(gtex_data(:, col));  % Gene expression values
   
    rxn_expression= mapExpressionToReactions(model_Healthy,exprData);
    th_lb=prctile(rxn_expression,75);
    for k=1:length(rxn_expression)
        if isnan(rxn_expression(k))==1
            rxn_expression(k)=-1;
        end
    end

    iMAT_model_I = iMAT(model_Healthy, rxn_expression, th_lb, th_lb)
        
    save(sprintf('%s.mat', name), 'iMAT_model_I');
end
