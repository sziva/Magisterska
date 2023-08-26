% Define the folder path you want to iterate through
folderPath = '/Users/zivaskof/Documents/MATLAB/mag/GimmeModels';  % Replace with the actual folder path

% Use the dir function to obtain a list of files and subfolders in the folder
dirInfo = dir(folderPath);

% Iterate through the contents of the folder
for i = 1:length(dirInfo)
  
   

    model = dirInfo(i)

    if strcmp(model.name, '.') || strcmp(model.name, '..')
        continue;
    end

    loadedModel = load(model.name)

    iMAT_model_I=ravenCobraWrapper(loadedModel);

    name = item.name + "C"
    save(sprintf('%s.mat', name), 'iMAT_model_I');
     
end