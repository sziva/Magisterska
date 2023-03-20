function annModel = annotateGEM(model,annPath,annType,addMiriams,addFields,overwrite)
% Add reaction, metabolite, and/or gene annotation to a model.
%
% Input:
%
%   model        Model structure.
%
%   annPath      Path to the annotation files, which suppose to be named as
%                'reactions.tsv', 'metabolites.tsv', and 'genes.tsv'。
%
%   annType      String or cell array of strings specifying the type(s) of 
%                annotation data to add: 'rxn', 'met', and/or 'gene'. To
%                add all annotation types, use 'all'.
%                For example, annType={'rxn','gene'} will add reaction and
%                gene annotation information, but not metabolite.
%                (Opt, default 'all')
%
%   addMiriams   If TRUE, annotation information will be added to the 
%                metMiriams field. If the metMiriams field does not exist,
%                it will be created.
%                (Opt, default TRUE)   
%
%   addFields    If TRUE, separate model fields will be added for each 
%                added ID type, e.g., reaction KEGG IDs will be added to a
%                rxnKEGGID field.
%                (Opt, default TRUE)
%
%   overwrite    If TRUE, any existing metMiriam or model ID field entries
%                will be overwritten. If FALSE, they will be appended with
%                the new data.
%                (Opt, default TRUE)
%
%
% Output:
%
%   annModel     Model structure with added annotation information.
%
%
% Usage:
%
%   annModel = annotateGEM(model,annPath,annType,addMiriams,addFields,overwrite);
%


%% Inputs and setup

if nargin < 2
    [ST, I] = dbstack('-completenames');
    annPath = strcat(fileparts(ST(I).file),'/../model');
end

if nargin < 3 || isempty(annType) || isequal(annType,'all')
    annType = {'rxn','met','gene'};
elseif ~all(ismember(annType,{'rxn','met','gene','reaction','metabolite'}))
    error('annType input(s) not recognized. Valid options are "rxn", "met", and/or "gene", or "all"');
end

if nargin < 4 || isempty(addMiriams)
    addMiriams = true;
end

if nargin < 5 || isempty(addFields)
    addFields = true;
end

if nargin < 6
    overwrite = true;
end

if (~addMiriams) && (~addFields)
    error('addMiriams and addFields are both FALSE - no annotation will be added.')
end

% map field names to those on identifiers.org (used for building Miriams)
id2miriam = {%reactions
             'rxnKEGGID'        'kegg.reaction'
             'rxnBiGGID'        'bigg.reaction'
             'rxnREACTOMEID'    'reactome'
             'rxnRecon3DID'     'vmhreaction'
             'rxnMetaNetXID'    'metanetx.reaction'
             'rxnTCDBID'        'tcdb'
             'rxnRheaID'        'rhea'
             'rxnRheaMasterID'  'rhea'
             % metabolites
             'metBiGGID'        'bigg.metabolite'
             'metKEGGID'        'kegg.compound'
             'metHMDBID'        'hmdb'
             'metChEBIID'       'chebi'
             'metPubChemID'     'pubchem.compound'
             'metLipidMapsID'   'lipidmaps'
             'metRecon3DID'     'vmhmetabolite'
             'metMetaNetXID'    'metanetx.chemical'
             % genes
             'genes'            'ensembl'
             'geneENSTID'       'ensembl'
             'geneENSPID'       'ensembl'
             'geneUniProtID'    'uniprot'
             'geneSymbols'      'hgnc.symbol'
             'geneEntrezID'     'ncbigene'
             };


%% Load and organize annotation data

% load reaction annotation data
if any(ismember({'rxn','reaction'},lower(annType)))
    tmpfile = fullfile(annPath,'reactions.tsv');
    rxnAssoc = importTsvFile(tmpfile);
    
    % strip "RHEA:" prefix from Rhea IDs since it should not be included in
    % the identifiers.org URL
    rxnAssoc.rxnRheaID = regexprep(rxnAssoc.rxnRheaID, 'RHEA:', '');
    rxnAssoc.rxnRheaMasterID = regexprep(rxnAssoc.rxnRheaMasterID, 'RHEA:', '');
    
    rxnAssocArray = struct2cell(rxnAssoc);
    numericFields = find(cellfun(@isnumeric, rxnAssocArray));
    for i = 1:numel(numericFields)
        % numeric fields must be converted to text for miriams
        rxnAssocArray{numericFields(i)} = arrayfun(@num2str, rxnAssocArray{numericFields(i)}, 'UniformOutput', false);
    end
    rxnAssocArray = horzcat(rxnAssocArray{:});
else
    rxnAssoc = [];
end

% load metabolite annotation data
if any(ismember({'met','metabolite'},lower(annType)))
    tmpfile = fullfile(annPath,'metabolites.tsv');
    metAssoc = importTsvFile(tmpfile);
    
    % ChEBI IDs should be of the form "CHEBI:#####"
    metAssoc.metChEBIID = regexprep(metAssoc.metChEBIID,'(^)(\d+)|(;\s*)(\d+)','$1CHEBI:$2');
    
    metAssocArray = struct2cell(metAssoc);
    numericFields = find(cellfun(@isnumeric, metAssocArray));
    for i = 1:numel(numericFields)
        % numeric fields need to be converted to text for miriams
        metAssocArray{numericFields(i)} = arrayfun(@num2str, metAssocArray{numericFields(i)}, 'UniformOutput', false);
    end
    metAssocArray = horzcat(metAssocArray{:});
else
    metAssoc = [];
end

% load and organize gene annotation data
if ismember('gene',lower(annType))
    tmpfile = fullfile(annPath,'genes.tsv');
    geneAssoc = importTsvFile(tmpfile);
    
    % add geneEnsemblID field if missing
    if ~isfield(geneAssoc, 'geneEnsemblID')
        geneAssoc.geneEnsemblID = geneAssoc.genes;
    end
    
    geneAssocArray = struct2cell(geneAssoc);
    geneAssocArray = horzcat(geneAssocArray{:});
else
    geneAssoc = [];
end


%% Add annotation data to model MIRIAM fields

if ( addMiriams )
    
    % Reactions
    if ~isempty(rxnAssoc)
        % map model rxns to those in the association structures
        [hasRxn,rxnInd] = ismember(model.rxns,rxnAssoc.rxns);
        
        % add rxnMiriams field if it does not exist or if overwrite is TRUE
        if ~isfield(model,'rxnMiriams') || overwrite
            model.rxnMiriams = repmat({''},size(model.rxns));
        end
        
        % map rxn ID fields to the proper identifiers.org terms
        [hasRxnField,rxnFieldInd] = ismember(fieldnames(rxnAssoc),id2miriam(:,1));
        miriamNames = id2miriam(rxnFieldInd(hasRxnField),2);
        miriamValues = rxnAssocArray(:,hasRxnField);
        
        
        % assign SBO terms to model reactions
        rxnSBO = repmat({'SBO:0000176'},size(model.rxns));  % default is "biochemical reaction"
        
        biomass_rxn = contains(lower(model.rxns),'biomass');
        biomass_met = ismember(lower(model.metNames),'biomass') & ismember(model.comps(model.metComps),'c');
        biomass_rxn = biomass_rxn | (model.S(biomass_met,:) > 0)';
        rxnSBO(biomass_rxn) = {'SBO:0000629'};  % "biomass production"
        
        transport_rxn = getTransportRxns(model);
        rxnSBO(transport_rxn) = {'SBO:0000185'};  % "translocation reaction"
        
        [~,exchange_rxn] = getExchangeRxns(model);
        rxnSBO(exchange_rxn) = {'SBO:0000627'};  % "exchange reaction"
        
        
        % add new data to the rxnMiriams field
        for i = 1:numel(model.rxns)
            if hasRxn(i)
                % add annotation
                model.rxnMiriams{i} = appendMiriamData(model.rxnMiriams{i}, miriamNames, miriamValues(rxnInd(i),:)');
            end
            % add SBO terms
            model.rxnMiriams{i} = appendMiriamData(model.rxnMiriams{i}, {'sbo'}, rxnSBO(i));
        end
    end
    
    % Metabolites
    if ~isempty(metAssoc)
        % map model mets to those in the association structures
        [hasMet,metInd] = ismember(model.mets,metAssoc.mets);
        
        % add metMiriams field if it does not exist or if overwrite is TRUE
        if ~isfield(model,'metMiriams') || overwrite
            model.metMiriams = repmat({''},size(model.mets));
        end
        
        % map met ID fields to the proper identifiers.org terms
        [hasMetField,metFieldInd] = ismember(fieldnames(metAssoc),id2miriam(:,1));
        miriamNames = id2miriam(metFieldInd(hasMetField),2);
        miriamValues = metAssocArray(:,hasMetField);
        
        % add new data to the metMiriams field
        for i = 1:numel(model.mets)
            if hasMet(i)
                % add annotation
                model.metMiriams{i} = appendMiriamData(model.metMiriams{i}, miriamNames, miriamValues(metInd(i),:)');
            end
            % add SBO term (SBO:0000247, "simple chemical" for all mets)
            model.metMiriams{i} = appendMiriamData(model.metMiriams{i}, {'sbo'}, {'SBO:0000247'});
        end
    end
    
    % Genes
    if ~isempty(geneAssoc)
        % Note: because geneAssoc was built using geneIDs directly from the
        %       model, we do not need to map model.genes to the geneAssoc
        %       structure - the indexing should be identical.
        
        % map model genes to those in the association structures
        [hasGene,geneInd] = ismember(model.genes,geneAssoc.genes);
        
        % add geneMiriams field if it does not exist or if overwrite is TRUE
        if ~isfield(model,'geneMiriams') || overwrite
            model.geneMiriams = repmat({''},size(model.genes));
        end
        
        % map gene ID fields to the proper identifiers.org terms
        [hasGeneField,geneFieldInd] = ismember(fieldnames(geneAssoc),id2miriam(:,1));
        miriamNames = id2miriam(geneFieldInd(hasGeneField),2);
        miriamValues = geneAssocArray(:,hasGeneField);
        
        % add new data to the geneMiriams field
        for i = 1:numel(model.genes)
            if hasGene(i)
                % add annotation
                model.geneMiriams{i} = appendMiriamData(model.geneMiriams{i}, miriamNames, miriamValues(geneInd(i),:)');
            end
            % add SBO term (SBO:0000243, "gene" for all genes)
            model.geneMiriams{i} = appendMiriamData(model.geneMiriams{i}, {'sbo'}, {'SBO:0000243'});
        end
    end
    
end


%% Add annotation data to individual model fields

if ( addFields )
    
    % merge association structures
    allAssoc = mergeStructures({rxnAssoc,metAssoc,geneAssoc});
    
    % some fields should not be added to the model
    remFields = {'rxns','mets','metsNoComp','genes'};
    allAssoc = rmfield(allAssoc, intersect(fieldnames(allAssoc),remFields));
    
    % get fields and their types
    f = fieldnames(allAssoc);
    
    if ~isempty(rxnAssoc)
        fieldType = repmat({'rxn'}, numel(f), 1);
    end
    
    if ~isempty(metAssoc)
        fieldType(ismember(f, fieldnames(metAssoc))) = {'met'};
    end
    
    if ~isempty(geneAssoc)
        fieldType(ismember(f, fieldnames(geneAssoc))) = {'gene'};
    end
    
    % add individual ID fields to the model
    for i = 1:numel(f)
        
        switch fieldType{i}
            case 'rxn'
                [hasRxn,rxnInd] = ismember(model.rxns,rxnAssoc.rxns);
                if isnumeric(allAssoc.(f{i}))
                    ids = NaN(size(model.rxns));
                else
                    ids = repmat({''},size(model.rxns));
                end
                ids(hasRxn) = allAssoc.(f{i})(rxnInd(hasRxn));
            case 'met'
                [hasMet,metInd] = ismember(model.mets,metAssoc.mets);
                if isnumeric(allAssoc.(f{i}))
                    ids = NaN(size(model.mets));
                else
                    ids = repmat({''},size(model.mets));
                end
                ids(hasMet) = allAssoc.(f{i})(metInd(hasMet));
            case 'gene'
                [hasGene,geneInd] = ismember(model.genes,geneAssoc.genes);
                if isnumeric(allAssoc.(f{i}))
                    ids = NaN(size(model.genes));
                else
                    ids = repmat({''},size(model.genes));
                end
                ids(hasGene) = allAssoc.(f{i})(geneInd(hasGene));
            otherwise
                continue
        end
        
        if ~isfield(model,f{i}) || overwrite
            model.(f{i}) = ids;
        else
            % merge new IDs with existing IDs
            merged_ids = join([model.(f{i}), ids],';');
            merged_ids = arrayfun(@(id) strjoin(unique(split(id,';')),';'), merged_ids, 'UniformOutput', false);
            model.(f{i}) = regexprep(merged_ids,'^;\s*','');  % remove any preceding semicolons
        end
        
    end
    
end

%%

% assign output
annModel = model;

end



%% Additional functions

function miriam_new = appendMiriamData(miriam,names,values)
% Append new entries to an existing miriam structure.

% ignore empty entries
remove = cellfun(@isempty,values);
names(remove) = [];
values(remove) = [];
if isempty(names)
    miriam_new = miriam;
    return
end

% convert existing miriam entry to cell array
if ~isempty(miriam)
    miriam = [miriam.name(:), miriam.value(:)];
end

% append miriam entry with new data
for i = 1:numel(names)
    if contains(values{i},';')
        % handle multiple values separated by semicolon (;)
        val = strtrim(split(values{i},';'));
        name = repmat(names(i),numel(val),1);
        miriam = [miriam; [name, val]];
    else
        miriam = [miriam; [names(i), values(i)]];
    end
end

% remove any repeated entries
[~,miriam_num] = ismember(miriam,miriam);
[~,uniq_ind] = unique(miriam_num,'rows');
miriam = miriam(uniq_ind,:);

% convert back to structure
miriam_new.name = miriam(:,1);
miriam_new.value = miriam(:,2);

end


function mergedStruct = mergeStructures(structs)
% Merge multiple structures into a single structure.

mergedStruct = {};
for i = 1:numel(structs)
    
    s = structs{i};
    
    if isempty(s)
        continue
    end
    
    f = fieldnames(s);
    for j = 1:numel(f)
        mergedStruct.(f{j}) = s.(f{j});
    end
    
end

end



