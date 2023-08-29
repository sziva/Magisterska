load('/Users/zivaskof/Documents/MATLAB/mag/Human-GEM-1.14.0/model/Human-GEM.mat');
baseModel = addBoundaryMets(ihuman);

folder = '/Users/zivaskof/Documents/MATLAB/mag/tmp'
fileList = dir(fullfile(folder, '*.mat'));
% Preallocate cell array for filenames
fileNames = cell(length(fileList), 1);

% now build a matrix saying which reactions are on
compMat = false(length(baseModel.rxns), length(fileList));

for i = 1:length(fileList)

    name = fileList(i).name
    modelFilePath = fullfile(folder, fileList(i).name);
    loadedModel = load(modelFilePath);
    modelRxns = loadedModel.liver_tINIT_H.rxns;
    compMat(:,i) = ismember(baseModel.rxns,modelRxns);

    % Store the filename without extension
    [~, fileNameWithoutExtension, ~] = fileparts(fileList(i).name);
    fileNames{i} = fileNameWithoutExtension;
end

% run t-sne
rng(1);  %set random seed to make reproducible
proj_coords = tsne(double(compMat.'), 'Distance', 'hamming', 'NumDimensions', 2, 'Exaggeration', 6, 'Perplexity', 10);

% Plot the t-SNE results
scatter(proj_coords(:, 1), proj_coords(:, 2));
title('t-SNE Visualization of tINIT metabolic models');
xlabel('t-SNE Dimension 1');
ylabel('t-SNE Dimension 2');

% Add text labels to each point
text(proj_coords(:, 1), proj_coords(:, 2), fileNames, 'FontSize', 8);