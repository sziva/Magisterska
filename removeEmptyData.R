library(readxl)
library(openxlsx)

# Read Excel file
df <- read_excel("MATLAB/Projects/magisterska/dataGSE39791_H_copy.xlsx")

head(df)
# Filter rows where the second column is not empty
df_filtered <- df[!is.na(df$Gene_ID),]
head(df_filtered)


# Create a new workbook
wb <- createWorkbook()

# Add a worksheet to the workbook
addWorksheet(wb, "My Data")

# Write data to the worksheet
writeData(wb, "My Data", df_filtered)

# Write filtered data to a new Excel file
saveWorkbook(wb, "/Users/zivaskof/Documents/MATLAB/mag/dataGSE39791_H_C.xlsx")
