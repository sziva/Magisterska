# Human-GEM code

A handy installer script is provided via _HumanGEMInstaller.m_, which can add and remove, via _HumanGEMInstaller.install_ and 
_HumanGEMInstaller.uninstall_, all necessary subfolders of Human-GEM to the Matlab path.

This directory contains functions and scripts that facilitate work with the Human-GEM model and other content in the repository. 
This directory is organized as follows:

```
code
├── GPRs
├── io
├── misc
├── modelCuration
├── qc
├── tINIT
└── test
```

### GPRs
Functions related to gene-transcript-protein-reaction (GTPR) associations in the model. The functions primarily involve the Human-GEM `grRules` field, facilitating processes such as cleaning or simpliyfing the rules, or converting between gene, transcript, and protein IDs.

### io
Functions associated with input/output of files into and out of MATLAB, such as the yaml-formatted Human-GEM, or documentation of model changes.

### misc
Code used for technical purposes, typically to augment missing or inconvenient functionalities of MATLAB.

### modelCuration
Contains curation-related scripts and functions used to make changes to the Human-GEM model. These model curation scripts help to improve transparency of changes made to the model when the number of changes is too large to view practically. Their only remaining purpose is for transparency and re-tracing the steps of the curation process.

Note that code in this directory is often one-time use and will not be updated with later versions of Human-GEM. Deprecated code is moved to the `.deprecated` folder in the root directory of this repository.

### qc
Functions to help with quality control (QC) of Human-GEM, such as checking for duplicate reactions or mass imbalances.

### tINIT
Functions associated with the **t**ask‐driven **I**ntegrative **N**etwork **I**nference for **T**issues (tINIT) algorithm. These functions include updates to the [original algorithm](https://www.ncbi.nlm.nih.gov/pubmed/24646661), as described in the [Human-GEM publication](https://stke.sciencemag.org/lookup/doi/10.1126/scisignal.aaz1482). Note that the updated tINIT implementation included here still requires many functions from the [RAVEN Toolbox 2](https://github.com/SysBioChalmers/RAVEN).

### test
Functions for testing purposes


