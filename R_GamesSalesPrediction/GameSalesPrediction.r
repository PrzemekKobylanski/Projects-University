# Case Study - sprzedawca sprzętu elektronicznego z ??? chce dowiedzieć się na jaką platformę gry z kategorii ??? bedą sprzedawały się najlepiej w najbliższej przyszłości
# poszukiwany jest trend sprzedaży ze wzgledu na najlepszą platformę dla danego gatunku
#
# https://www.kaggle.com/code/caesarmario/global-sales-prediction-using-r
#
#

#####
##  Definicja bibliotek
#
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(corrplot)
library(broom)
library(mice)
library(DataExplorer)
library(gridExtra)
library(caret)
library(RColorBrewer)
library(missForest)
library(caTools)
library(jtools)
library(randomForest)
library(e1071)
library(ROCR)
library(klaR)
library(NbClust)
library(xgboost)
library(kernlab)

#####
##  Definicja analizy danych
#
fileName <- "Video_Games_Sales_as_at_22_Dec_2016.csv"
chosenRegion <- "EU_Sales"
chosenGenre <- "Shooter"

#####
## Wczytanie danych z pliku
#
rawData <- read.csv( file = fileName, sep = ",")
columnNames <- colnames(rawData)
print(columnNames)
glimpse(rawData)

#####
##  Odfiltorwanie z danych dotyczących jedynie wybranego gatunku
#
filteredData <- filter( rawData, Genre == chosenGenre, .preserve = TRUE )
print(filteredData)

#####
##  Usunięcie nieuwzględnianych / zbędnych / niekompletnych danych
#
profiledData <- filteredData[ 2 : 14 ]
profiledData <- profiledData[ -3 ]
profiledData <- na.omit( profiledData )
profiledData <- filter( profiledData, Year_of_Release != "N/A", .preserve = TRUE )

#####
##  Przygotowanie danych - usunięcie danych żadkich oraz definicja wartości liczbowych i wskaźnikowych
#
colnames( profiledData ) <- c( "Platform", "Year", "Publisher", "NA_Sales", "EU_Sales", "JP_Sales", "Other_Sales", 
                                "Global_Sales", "Critic_Score", "Critic_Count", "User_Score", "User_Count" )
prepreparedData <- data.frame( profiledData[ c("Platform", "Publisher") ], lapply( profiledData[ c( 2, 4:12 ) ], as.numeric ) )
prepreparedData <- data.frame( lapply(prepreparedData[ c("Platform", "Publisher") ], as.factor), prepreparedData[ 3:12 ] )

maxAge <- max( prepreparedData["Year"] )
prepreparedData["Age"] <- maxAge - prepreparedData["Year"]

p <- prepreparedData %>% 
      group_by( Platform ) %>% 
      mutate( Count_by_platform = n() )
p <- subset( p, Count_by_platform > 5 )
prepreparedData <- p

p <- prepreparedData %>% 
      group_by( Publisher ) %>% 
      mutate( Count_by_publisher = n() )
p <- subset( p, Count_by_publisher > 5 )
prepreparedData <- p

tempCounter <- prepreparedData %>% 
                group_by( Platform ) %>% 
                summarise( Count_by_platform = n() ) %>% 
                arrange( desc( Count_by_platform ) )
tempCounter2 <- prepreparedData %>% 
                group_by( Publisher ) %>% 
                summarise( Count_by_publisher = n() ) %>% 
                arrange( desc( Count_by_publisher ) )

#####
##  Test korelacji danych
#
corelationDataFrame <- data.frame( prepreparedData$Age, prepreparedData$Year, prepreparedData$NA_Sales, prepreparedData$JP_Sales, prepreparedData$EU_Sales, 
                                   prepreparedData$Other_Sales, prepreparedData$Global_Sales, prepreparedData$Critic_Score, prepreparedData$Critic_Count, 
                                   prepreparedData$User_Score, prepreparedData$User_Count, prepreparedData$Count_by_platform, prepreparedData$Count_by_publisher )
corelationMatrixData <- cor( corelationDataFrame )
corrplot( corelationMatrixData, diag = FALSE, order = "FPC", tl.pos = "td", tl.cex = 0.5, method = "circle", type="upper" )


#####
##  RFE
#
set.seed(1)
inputRFE <- dplyr::select( prepreparedData %>% ungroup(), -c("EU_Sales", "Publisher") )
outputRFE <- dplyr::select( prepreparedData %>% ungroup(), c("EU_Sales") )
results <- rfe( inputRFE, as.matrix(outputRFE), sizes = c(1:120), rfeControl = rfeControl( functions = rfFuncs, method="cv", number=10 ))
print(results)
plot(results, type=c("g", "o"))

#####
##  Wizualna analiza eksploracyjna danych oparta o wykresy box-plot
#
par(mfrow=c(1,1))
for(i in 1:11){
  j = i + 2
  boxplot( prepreparedData[[j]] ~ Platform, data = prepreparedData, main=names(prepreparedData)[j] )
}; rm(i)

##  Podstawowa analiza statystyczna zebranych danych w kontekscie wybranego regionu
#
simpleAnalyse <- prepreparedData %>% 
                  group_by( Platform ) %>% 
                  summarise( Count = n(), Percentage = round( n() / nrow(.) * 100, 1) ) %>% 
                  arrange( desc(Count) )
simpleAnalyse2 <- prepreparedData %>% 
                  group_by( Platform ) %>% 
                  summarise( Count = across( chosenRegion, sum), Percentage = round( Count / sum( prepreparedData[chosenRegion] ) * 100, 1) ) %>% 
                  arrange( desc(Count) )

#####
##  Definition of testing formulas for SR
#
formula1 <- EU_Sales ~ Count_by_publisher + Count_by_platform + Global_Sales + Age + NA_Sales + JP_Sales + Other_Sales + Critic_Score + Critic_Count + User_Score + User_Count # removed "Year"
formula2 <- EU_Sales ~ Count_by_publisher + Count_by_platform + Global_Sales + Age + Critic_Score + Critic_Count + User_Score + User_Count  # removed "Year + NA_Sales + JP_Sales + Other_Sales"
formula3 <- EU_Sales ~ Count_by_publisher + Count_by_platform + Global_Sales + Age + Critic_Score + User_Score + User_Count # removed "Year + NA_Sales + JP_Sales + Other_Sales + Critic_Count"
formula4 <- EU_Sales ~ Count_by_publisher + Count_by_platform + Global_Sales + Age + Critic_Score + User_Score  # removed "Year + NA_Sales + JP_Sales + Other_Sales + Critic_Count + User_Count"
formula5 <- EU_Sales ~ Count_by_publisher * Count_by_platform * Global_Sales * Age + Critic_Score + User_Score  # added interactions

formula <- c(formula1, formula2, formula3, formula4, formula5)

#####
## Simple regression - przygotowanie datasetów
#
salesDataset = subset( prepreparedData, select = -c( Platform, Publisher ) )

# Experiment 1 - train:test 70:30, seed 555

set.seed(555)
split = sample.split( salesDataset$EU_Sales, SplitRatio = 0.7 )
trainData1 = subset( salesDataset, split == TRUE )
testData1  = subset( salesDataset, split == FALSE )

# Experiment 2 - train:test 70:30, seed 555, data scaling

set.seed(555)
split = sample.split( salesDataset$EU_Sales, SplitRatio = 0.7 )
trainData2 = as.data.frame( scale( subset( salesDataset, split == TRUE  ), center = TRUE, scale = TRUE ) )
testData2  = as.data.frame( scale( subset( salesDataset, split == FALSE ), center = TRUE, scale = TRUE ) )

# Experiment 3 - train:test 70:30, seed 555, outliers removed, data scaling

Q <- quantile( salesDataset$EU_Sales, probs=c( 0.25, 0.75 ), na.rm = FALSE )
iqr <- IQR( salesDataset$EU_Sales )
salesDatasetCleaned <- subset( salesDataset, salesDataset$EU_Sales > (Q[1] - 1.5 * iqr) & salesDataset$EU_Sales < (Q[2] + 1.5 * iqr) )

set.seed(555)
split = sample.split(salesDatasetCleaned$EU_Sales, SplitRatio = 0.7)
trainData3 = as.data.frame( scale( subset(salesDatasetCleaned, split == TRUE  ), center = TRUE, scale = TRUE ) )
testData3  = as.data.frame( scale( subset(salesDatasetCleaned, split == FALSE ), center = TRUE, scale = TRUE ) )

# Expperiment 4 - train:test 80:20, seed 555, outlier removed, data scaling

set.seed(555)
split = sample.split(salesDatasetCleaned$EU_Sales, SplitRatio = 0.8)
trainData4 = as.data.frame( scale( subset(salesDatasetCleaned, split == TRUE  ), center = TRUE, scale = TRUE ) )
testData4  = as.data.frame( scale( subset(salesDatasetCleaned, split == FALSE ), center = TRUE, scale = TRUE ) )


trainData <- list(trainData1, trainData2, trainData3, trainData4)
testData <- list(testData1, testData2, testData3, testData4)

#####
##  Multiple Linear Regression - Backward Elimination depending on Correlation Model
#

rmsetrainMLR <- vector()
rmsetestMLR <- vector()
maetrainMLR <- vector()
maetestMLR <- vector()
n <- 0

for (i in 1:4)
{
  tempdata = as.data.frame( trainData[i] )
  for (j in 1:5)
  {
    regressionPackage = lm( formula = as.formula( formula[[j]]), data = tempdata )
    predictPackage = predict( regressionPackage, tempdata )
    predictPackageTest = predict( regressionPackage, tempdata )
    rmsetrainMLR[n] = RMSE( predictPackage, tempdata$EU_Sales )
    rmsetestMLR[n] = RMSE( predictPackageTest, tempdata$EU_Sales )
    maetrainMLR[n] = MAE( predictPackage, tempdata$EU_Sales )
    maetestMLR[n] = MAE( predictPackageTest, tempdata$EU_Sales )
    n <- n + 1 
  }
}


#####
##  Definition of testing formulas for RF
#

formula1 <- EU_Sales ~ Platform + Count_by_publisher + Global_Sales + Age + NA_Sales + JP_Sales + Other_Sales + Critic_Score + Critic_Count + User_Score + User_Count
formula2 <- EU_Sales ~ Platform + Count_by_publisher + Global_Sales + Age + Critic_Score + Critic_Count + User_Score + User_Count
formula3 <- EU_Sales ~ Platform + Count_by_publisher + Global_Sales + Age + Critic_Score + User_Score + User_Count
formula4 <- EU_Sales ~ Platform + Count_by_publisher + Global_Sales + Age + Critic_Score + User_Score
formula5 <- EU_Sales ~ Platform * Count_by_publisher * Global_Sales * Age + Critic_Score + User_Score

formula <- c(formula1, formula2, formula3, formula4, formula5)

#####
##  Data preparation for RF technique
#

salesDatasetRF = subset( prepreparedData, select = -c( Publisher ) )

# Experiment 1 - train:test 70:30, seed 555
set.seed(555)
split = sample.split( salesDatasetRF$EU_Sales, SplitRatio = 0.7 )
trainData1 = subset( salesDatasetRF, split == TRUE  )
testData1  = subset( salesDatasetRF, split == FALSE )

# Experiment 2 - train:test 70:30, seed 555, data scaling
set.seed(555)
split = sample.split( salesDatasetRF$EU_Sales, SplitRatio = 0.7 )
trainData2 = data.frame( subset( salesDatasetRF, split == TRUE,  select = c( Platform ) ), scale( subset( salesDatasetRF, split == TRUE,  select = -c( Platform ) ), center = TRUE, scale = TRUE ) )
testData2  = data.frame( subset( salesDatasetRF, split == FALSE, select = c( Platform ) ), scale( subset( salesDatasetRF, split == FALSE, select = -c( Platform ) ), center = TRUE, scale = TRUE ) )

# Experiment 3 - train:test 70:30, seed 555, outliers removed, data scaling
Q <- quantile( salesDatasetRF$EU_Sales, probs=c( 0.25, 0.75), na.rm = FALSE ) 
iqr <- IQR( salesDatasetRF$EU_Sales )
salesDatasetCleanedRF <- subset( salesDatasetRF, salesDatasetRF$EU_Sales > (Q[1] - 1.5 * iqr) & salesDatasetRF$EU_Sales < (Q[2] + 1.5 * iqr) )

set.seed(555)
split = sample.split( salesDatasetCleanedRF$EU_Sales, SplitRatio = 0.7 )
trainData3 = data.frame( subset( salesDatasetCleanedRF, split == TRUE,  select = c( Platform ) ), scale( subset( salesDatasetCleanedRF, split == TRUE,  select = -c( Platform ) ), center = TRUE, scale = TRUE ) )
testData3  = data.frame( subset( salesDatasetCleanedRF, split == FALSE, select = c( Platform ) ), scale( subset( salesDatasetCleanedRF, split == FALSE, select = -c( Platform ) ), center = TRUE, scale = TRUE ) )

# Expperiment 4 - train:test 80:20, seed 555, outlier removed, data scaling
set.seed(555)
split = sample.split( salesDatasetCleanedRF$EU_Sales, SplitRatio = 0.8 )
trainData4 = data.frame( subset( salesDatasetCleanedRF, split == TRUE,  select = c( Platform ) ), scale( subset( salesDatasetCleanedRF, split == TRUE,  select = -c( Platform ) ), center = TRUE, scale = TRUE ) )
testData4  = data.frame( subset( salesDatasetCleanedRF, split == FALSE, select = c( Platform ) ), scale( subset( salesDatasetCleanedRF, split == FALSE, select = -c( Platform ) ), center = TRUE, scale = TRUE ) )

trainData <- list(trainData1, trainData2, trainData3, trainData4)
testData <- list(testData1, testData2, testData3, testData4)


#####
##  Random Forest
#

rmsetrainRF <- vector()
rmsetestRF <- vector()
maetrainRF <- vector()
maetestRF <- vector()
n <- 0

for (i in 1:4)
{
  tempdata = as.data.frame( trainData[i] )
  for (j in 1:5)
  {
    regressionPackage = randomForest( as.formula(formula[[j]]), data = tempdata, ntreeTry = 500, mtry = 6, importance = TRUE, proximity = TRUE)
    predictPackage = predict( regressionPackage, tempdata )
    predictPackageTest = predict( regressionPackage, tempdata )
    rmsetrainRF[n] = RMSE( predictPackage, tempdata$EU_Sales )
    rmsetestRF[n] = RMSE( predictPackageTest, tempdata$EU_Sales )
    maetrainRF[n] = MAE( predictPackage, tempdata$EU_Sales )
    maetestRF[n] = MAE( predictPackageTest, tempdata$EU_Sales )
    n <- n + 1 
  }
}


#####
##  Definition of testing formulas for SVM technique and XT
#

formula1 <- EU_Sales ~ Platform + Publisher + Global_Sales + Age + NA_Sales + JP_Sales + Other_Sales + Critic_Score + Critic_Count + User_Score + User_Count
formula2 <- EU_Sales ~ Platform + Publisher + Global_Sales + Age + Critic_Score + Critic_Count + User_Score + User_Count
formula3 <- EU_Sales ~ Platform + Publisher + Global_Sales + Age + Critic_Score + User_Score + User_Count
formula4 <- EU_Sales ~ Platform + Publisher + Global_Sales + Age + Critic_Score + User_Score
formula5 <- EU_Sales ~ Platform * Publisher * Global_Sales * Age + Critic_Score + User_Score

formula <- c(formula1, formula2, formula3, formula4, formula5)

#####
##  Data preparation for SVM technique
#

salesDatasetSVM = prepreparedData

# Experiment 1 - train:test 70:30, seed 555
set.seed(555)
split = sample.split( salesDatasetSVM$EU_Sales, SplitRatio = 0.7 )
trainData1 = subset( salesDatasetSVM, split == TRUE  )
testData1  = subset( salesDatasetSVM, split == FALSE )

# Experiment 2 - train:test 70:30, seed 555, data scaling
set.seed(555)
split = sample.split( salesDatasetSVM$EU_Sales, SplitRatio = 0.7 )
trainData2 = data.frame( subset( salesDatasetSVM, split == TRUE,  select = c( Platform, Publisher ) ), scale( subset( salesDatasetSVM, split == TRUE,  select = -c( Platform, Publisher ) ), center = TRUE, scale = TRUE ) )
testData2  = data.frame( subset( salesDatasetSVM, split == FALSE, select = c( Platform, Publisher ) ), scale( subset( salesDatasetSVM, split == FALSE, select = -c( Platform, Publisher ) ), center = TRUE, scale = TRUE ) )

# Experiment 3 - train:test 70:30, seed 555, outliers removed, data scaling
Q <- quantile( salesDatasetSVM$EU_Sales, probs=c( 0.25, 0.75), na.rm = FALSE ) 
iqr <- IQR( salesDatasetSVM$EU_Sales )
salesDatasetCleanedSVM <- subset( salesDatasetSVM, salesDatasetSVM$EU_Sales > (Q[1] - 1.5 * iqr) & salesDatasetSVM$EU_Sales < (Q[2] + 1.5 * iqr) )

set.seed(555)
split = sample.split( salesDatasetCleanedSVM$EU_Sales, SplitRatio = 0.7 )
trainData3 = data.frame( subset( salesDatasetCleanedSVM, split == TRUE,  select = c( Platform, Publisher ) ), scale( subset( salesDatasetCleanedSVM, split == TRUE,  select = -c( Platform, Publisher ) ), center = TRUE, scale = TRUE ) )
testData3  = data.frame( subset( salesDatasetCleanedSVM, split == FALSE, select = c( Platform, Publisher ) ), scale( subset( salesDatasetCleanedSVM, split == FALSE, select = -c( Platform, Publisher ) ), center = TRUE, scale = TRUE ) )

# Expperiment 4 - train:test 80:20, seed 555, outlier removed, data scaling
set.seed(555)
split = sample.split( salesDatasetCleanedSVM$EU_Sales, SplitRatio = 0.8 )
trainData4 = data.frame( subset( salesDatasetCleanedSVM, split == TRUE,  select = c( Platform, Publisher ) ), scale( subset( salesDatasetCleanedSVM, split == TRUE,  select = -c( Platform, Publisher ) ), center = TRUE, scale = TRUE ) )
testData4  = data.frame( subset( salesDatasetCleanedSVM, split == FALSE, select = c( Platform, Publisher ) ), scale( subset( salesDatasetCleanedSVM, split == FALSE, select = -c( Platform, Publisher ) ), center = TRUE, scale = TRUE ) )

trainData <- list(trainData1, trainData2, trainData3, trainData4)
testData <- list(testData1, testData2, testData3, testData4)

#####
##  SVM
#

rmsetrainSVMR <- vector()
rmsetestSVMR <- vector()
maetrainSVMR <- vector()
maetestSVMR <- vector()
n <- 0

for (i in 1:4)
{
  tempdata = as.data.frame( trainData[i] )
  for (j in 1:5)
  {
    regressionPackage = caret::train( as.formula(formula[[j]]), method = 'svmRadial', data = tempdata )
    predictPackage = predict( regressionPackage, tempdata )
    predictPackageTest = predict( regressionPackage, tempdata )
    rmsetrainSVMR[n] = RMSE( predictPackage, tempdata$EU_Sales )
    rmsetestSVMR[n] = RMSE( predictPackageTest, tempdata$EU_Sales )
    maetrainSVMR[n] = MAE( predictPackage, tempdata$EU_Sales )
    maetestSVMR[n] = MAE( predictPackageTest, tempdata$EU_Sales )
    n <- n + 1 
  }
}


#####
##  Data preparation for XT
#

salesDatasetXT = prepreparedData

# Experiment 1 - train:test 70:30, seed 555
set.seed(555)
split = sample.split( salesDatasetXT$EU_Sales, SplitRatio = 0.7 )
trainData1 = subset( salesDatasetXT, split == TRUE  )
testData1  = subset( salesDatasetXT, split == FALSE )

# Experiment 2 - train:test 70:30, seed 555, data scaling
set.seed(555)
split = sample.split( salesDatasetXT$EU_Sales, SplitRatio = 0.7 )
trainData2 = data.frame( subset( salesDatasetXT, split == TRUE,  select = c( Platform, Publisher ) ), scale( subset( salesDatasetXT, split == TRUE,  select = -c( Platform, Publisher ) ), center = TRUE, scale = TRUE ) )
testData2  = data.frame( subset( salesDatasetXT, split == FALSE, select = c( Platform, Publisher ) ), scale( subset( salesDatasetXT, split == FALSE, select = -c( Platform, Publisher ) ), center = TRUE, scale = TRUE ) )

# Experiment 3 - train:test 70:30, seed 555, outliers removed, data scaling
Q <- quantile( salesDatasetXT$EU_Sales, probs=c( 0.25, 0.75), na.rm = FALSE ) 
iqr <- IQR( salesDatasetXT$EU_Sales )
salesDatasetCleanedXT <- subset( salesDatasetXT, salesDatasetXT$EU_Sales > (Q[1] - 1.5 * iqr) & salesDatasetXT$EU_Sales < (Q[2] + 1.5 * iqr) )

set.seed(555)
split = sample.split( salesDatasetCleanedXT$EU_Sales, SplitRatio = 0.7 )
trainData3 = data.frame( subset( salesDatasetCleanedXT, split == TRUE,  select = c( Platform, Publisher ) ), scale( subset( salesDatasetCleanedXT, split == TRUE,  select = -c( Platform, Publisher ) ), center = TRUE, scale = TRUE ) )
testData3  = data.frame( subset( salesDatasetCleanedXT, split == FALSE, select = c( Platform, Publisher ) ), scale( subset( salesDatasetCleanedXT, split == FALSE, select = -c( Platform, Publisher ) ), center = TRUE, scale = TRUE ) )

# Expperiment 4 - train:test 80:20, seed 555, outlier removed, data scaling
set.seed(555)
split = sample.split( salesDatasetCleanedXT$EU_Sales, SplitRatio = 0.8 )
trainData4 = data.frame( subset( salesDatasetCleanedXT, split == TRUE,  select = c( Platform, Publisher ) ), scale( subset( salesDatasetCleanedXT, split == TRUE,  select = -c( Platform, Publisher ) ), center = TRUE, scale = TRUE ) )
testData4  = data.frame( subset( salesDatasetCleanedXT, split == FALSE, select = c( Platform, Publisher ) ), scale( subset( salesDatasetCleanedXT, split == FALSE, select = -c( Platform, Publisher ) ), center = TRUE, scale = TRUE ) )

trainData <- list(trainData1, trainData2, trainData3, trainData4)
testData <- list(testData1, testData2, testData3, testData4)


#####
##  XGBTree - Trening modeli
#

rmsetrainXGBT <- vector()
rmsetestXGBT <- vector()
maetrainXGBT <- vector()
maetestXGBT <- vector()
n <- 0

for (i in 1:4)
{
  tempdata = as.data.frame( trainData[i] )
  for (j in 1:5)
  {
    regressionPackage = caret::train( as.formula(formula[[j]]), method = 'xgbTree', data = tempdata )
    predictPackage = predict( regressionPackage, tempdata )
    predictPackageTest = predict( regressionPackage, tempdata )
    rmsetrainXGBT[n] = RMSE( predictPackage, tempdata$EU_Sales )
    rmsetestXGBT[n] = RMSE( predictPackageTest, tempdata$EU_Sales )
    maetrainXGBT[n] = MAE( predictPackage, tempdata$EU_Sales )
    maetestXGBT[n] = MAE( predictPackageTest, tempdata$EU_Sales )
    n <- n + 1 
  }
}