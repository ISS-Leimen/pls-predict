#PLSpredict
#Description: This library contains the functions utilized to run the PLS-PM 
# algorithm and its predictions.

#Function that receives a model and predicts measurements
PLSpredict <- function(trainData, testData, smMatrix, mmMatrix, maxIt=300, stopCriterion=7){
  
  #Call simplePLS function
  plsModel <- simplePLS(trainData, smMatrix, mmMatrix, maxIt, stopCriterion)
  
  #Get results from model
  smMatrix <- plsModel$smMatrix
  mmMatrix <- plsModel$mmMatrix
  ltVariables <- plsModel$ltVariables
  mmVariables <- plsModel$mmVariables
  outer_weights <- plsModel$outer_weights
  outer_loadings <- plsModel$outer_loadings
  meanData<-plsModel$meanData
  sdData <- plsModel$sdData
  path_coef<-plsModel$path_coef
  
  #Create container for Exogenous Variables
  exVariables = NULL
  
  #Create container for Endogenous Variables
  enVariables = NULL
  
  #Identify Exogenous and Endogenous Variables
  for (i in 1:length(ltVariables)){
    if (is.element(ltVariables[i], smMatrix[,"target"])==FALSE)
      exVariables <- c(exVariables, ltVariables[i])
    else
      enVariables <- c(enVariables, ltVariables[i])
  }
  
  #Create container for prediction Measurements
  pMeasurements = NULL
  
  #Identify prediction measurements
  for (i in 1:length(exVariables)){
    pMeasurements <- c(pMeasurements,mmMatrix[mmMatrix[,"latent"]==exVariables[i],"measurement"])
  }
  
  #Extract Measurements needed for Predictions
  normData <- testData[,pMeasurements]
  
  #Normalize data
  for (i in pMeasurements)
  {
    normData[,i] <-(normData[,i] - meanData[i])/sdData[i]
  }  
  
  #Convert dataset to matrix
  normData<-data.matrix(normData)
  
  #Create container for estimated measurements
  eMeasurements = NULL
  
  #Identify estimated measurements
  for (i in 1:length(enVariables)){
    eMeasurements <- c(eMeasurements,mmMatrix[mmMatrix[,"latent"]==enVariables[i],"measurement"])
  }
  
  #Add empty columns to normData for the estimated measurements
  for (i in 1:length(eMeasurements))
  {
    normData = cbind(normData, seq(0,0,length.out =nrow(normData)))
    colnames(normData)[length(colnames(normData))]=eMeasurements[i]
  }
  
  #Estimate Factor Scores from Outter Path
  fscores <- normData%*%outer_weights
  
  #Estimate Factor Scores from Inner Path and complete Matrix
  fscores <- fscores + fscores%*%path_coef
  
  #Predict Measurements with loadings
  predictedMeasurements<-fscores%*% t(outer_loadings)
  
  #Denormalize data
  for (i in mmVariables)
  {
    predictedMeasurements[,i]<-(predictedMeasurements[,i] * sdData[i])+meanData[i]
  }  
  
  #Calculating the residuals
  residuals <- testData[,eMeasurements] - predictedMeasurements[,eMeasurements]
  
  #Prepare return Object
  predictResults <- list(testData = testData[,eMeasurements],
                         predictedMeasurements = predictedMeasurements[,eMeasurements],
                         residuals = residuals,
                         compositeScores = fscores)
  
  class(predictResults) <- "predictResults"
  return(predictResults)

}
