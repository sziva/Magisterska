BiocManager::install("org.Hs.eg.db")

library(dplyr)
library(readxl)
library(org.Hs.eg.db)
library(writexl)
library(org.Hs.eg.db)

# Read the Excel file and extract the "Symbol" column as a vector
symbol_column <- read_excel("MATLAB/Projects/magisterska/dataGSE39791_H.xlsx")$Symbol
head(symbol_column)

keytypes(org.Hs.eg.db)
# Convert the gene symbols to gene IDs using your method of choice
gene_id_column <- mapIds(org.Hs.eg.db, keys= symbol_column, keytype= "SYMBOL",column =  "ENSEMBL")
head(gene_id_column)

mapped_values <- unname(as.character(gene_id_column))
head(mapped_values)

library(openxlsx)
# Create a new workbook
new_wb <- createWorkbook()

# Add a new worksheet to the workbook
addWorksheet(new_wb, "MySheet")

# Write the "Symbol" column to the first column of the worksheet
writeData(new_wb, "MySheet", symbol_column, startRow = 1, startCol = 1)

# Write the gene ID column to the second column of the worksheet
writeData(new_wb, "MySheet", mapped_values, startRow = 1, startCol = 2)

# Save the workbook to a new Excel file
saveWorkbook(new_wb, "MATLAB/Projects/magisterska/new_file.xlsx")
