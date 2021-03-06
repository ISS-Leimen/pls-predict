# PLSpredict

## Introduction
PLSpredict is a library of tools to perform Partial Least Squares Path Modelling and Prediction in R.   
This readme serves to explain the working of the PLSpredict package and to provide an example as to the intended use. To that end, we have provided a sample dataset, AnimData.csv, to which we will refer in the text.

## Theory
The popularity of PLS chiefly derives from the its non-parametric estimation of complex models - not requiring the onerous distributional and other constraints of traditional parametric methods.

## Installation and Use  
The simplePLS package can be downloaded directly from Github using the Devtools package developed by Hadley Wickham.  
First the devtools package must be installed and required in the R environment using the following R code:  
```
install.packages("devtools"), require(devtools)
```
After succesful installation of the devtools package, the install_github() function must be called to install PLSpredict directly from our Github repository:  
```
install_github("TBC") 
```  

## Features 
### simplePLS()  
simplePLS(trainData,smMatrix, mmMatrix, maxIt=300, stopCriterion=7)  
A function which takes as arguments the training dataset, the structural model in a matrix format and the measurement model in matrix format. This function takes the supplied data and generates the PLSPM object consisting of the: 
- normalized measures of exogenous factors
- measurement weights
- scores of exogenous factors
- path coefficients
- scores of endogenous factors
- error of endogenous factors
- factor loadings  
- normalized measures of endogenous factors  
- R^2 values for target factors

### PLSpredict()  
PLSpredict(trainData, testData = trainData, smMatrix, mmMatrix, maxIt=300, stopCriterion=7)  
A function which takes as arguments training dataset, the test dataset, the structural model in a matrix format and the measurement model in matrix format. This function returns the testdata, the predicted values for the test data, the residuals for the predictions and the predicted factor scores.  
  
### predictionInterval()
predictionInterval(trainData, smMatrix, mmMatrix, PIprobs = 0.9, maxIt=300, stopCriterion=7, noBoots=200, testData)  
A function which takes as arguments training dataset, the structural model in a matrix format, the measurement model in matrix format, an alpha for calculation of the prediction intervals, the number of bootstraps to perform and the test dataset to be used. The function return a list of 2 dataframes being the Average Case and Casewise Prediction Intervals for each point prediction.  

### validatePredict()
validatePredict(data, smMatrix, mmMatrix, maxIt=300, stopCriterion=7,noFolds=10)  
A function which takes as arguments the dataset, the structural model in a matrix format, the measurement model in matrix format and the number of folds to be used for the k-fold cross-validation. The function returns the RMSE, MAPE and MAD values for each target item predicted for both the PLS model and the Linear model. 
  
###### A note on the calculation of MAPE: As it is not unreasonable to expect Actual values of 0 - and this would lead to division by 0 - you will need to clean your data and apply a relevant measure to replace 0 values before using validatePredict.  
  

### AnimData.csv
A sample dataset with which to illustrate the use of the package.

## Walk Through
### Preparation of the data
We will be using the dataset AnimData provided in the simplePLS package to illustrate the usage of the function. The dataset is first sliced into a training set and testing set. You can refer to the example.R file for implementation("./examples/example.R").

``` 
Anime=read.csv("./data/AnimData.csv",header=T)
set.seed(123)
index=sample.int(dim(Anime)[1],83,replace=F)
trainData=Anime[-index,]
testData=Anime[index,]
```
### Creation of the simplePLS model:
Initially the PLS model consisting of a structural model and measurement model has to be defined.  

#### Structural model.
We have defined the structural model as consisting of 2 exogenous antecedent factors: Perceived Visual Complexity and Arousal and 1 endogenous outcome factor: Approach/Avoidance.  

In R our model is described by creating a 2 by 2 matrix and initializing this as matrix object smMatrix. The source column identifies the antecedent factor and the target column the outcome factor. This matrix is limited to 2 column width, but can have any number of antecedent and outcome factor combinations to accurately describe the proposed structural model. Indeed, one can even model interactions and moderations in this way.  
  
##### Please note that only alphanumeric characters to be used in column names. Ie. no "/" or "*" etc.
   
``` 
#Create the Matrix of the Structural Model
smMatrix <- matrix(c("Perceived Visual Complexity", "ApproachAvoidance",
                     "Arousal","ApproachAvoidance"),nrow=2,ncol=2,byrow =TRUE,
                   dimnames = list(1:2,c("source","target")))
```

#### Measurement Model
We have defined the measurement model as follows:

In R our model is described by creating a 13 by 3 matrix and initializing it as matrix object mmMatrix. This matrix is limited to 3 column width, but can have any number of measurement model combinations to accurately describe the proposed measurement model. The Latent column identifies the factor to which the variable from the dataset will be applied, the Measurement column identifies the variable applied to that factor and the Type column identifies whether the factor is (R)eflective (Endogenous) or (F)ormative (Exogenous). The Type of the variables must be consistent throughout for each factor (ie a factor cannot have some reflective and some formative variables), but any number of combinations of Formative and Reflective factors can be defined to fully and accurately describe the proposed model.

``` 
#Create the Matrix of the Measurement Model
mmMatrix <- matrix(c("Perceived Visual Complexity","VX.0","F",
                     "Perceived Visual Complexity","VX.1","F",
                     "Perceived Visual Complexity","VX.2","F",
                     "Perceived Visual Complexity","VX.3","F",
                     "Perceived Visual Complexity","VX.4","F",
                     "Arousal","Aro1","F",
                     "Arousal","Aro2","F",
                     "Arousal","Aro3","F",
                     "Arousal","Aro4","F",
                     "ApproachAvoidance","AA.0","R",
                     "ApproachAvoidance","AA.1","R",
                     "ApproachAvoidance","AA.2","R",
                     "ApproachAvoidance","AA.3","R"),nrow=13,ncol=3,byrow =TRUE,
                   dimnames = list(1:13,c("latent","measurement","type")))
```

With the data imported and both the structural and measurement models defined, the simplePLS function can be called:
``` 
plsModel<-simplePLS(trainData,smMatrix,mmMatrix,300,7)
```
This new plsModel object is now the model of the PLSPM that we have defined and contains:  
1. The original means of each variable (for predictive purposes)  
2. The original SD of each variable (for predictive purposes)  
3. The structural model (in matrix form as described above)  
4. The measurement model (in matrix form as described above)  
5. The latent variables   
6. The measurement variables  
7. Outer loadings for reflective or endogenous factors  
8. Outer weights for formative or exogenous factors  
9. Path coefficients between exogenous and endogenous factors  

### Prediction on the simplePLS model	 

After training the simplePLS object on the training dataset, we need use PLSpredict() using the simplePLS model and the test data set. This returns the testdata, the predicted values for the test data and the residuals for the predictions.
```
predTest <- PLSpredict(trainData, testData, smMatrix, mmMatrix, 300,7)  
```
The variable predTest is now a list object containing the following:  
1. A dataframe containing the original data  
2. A dataframe containing point predictions for each target item  
3. A dataframe containing the residuals for each point prediction  
4. A dataframe containing the predicted factor scores for each factor  

### Calculation of Prediction Intervals  
We can now calculate both average case and casewise prediction intervals for our point predictions. Please note that this function is computationally intense and yet to be optimized. It will take a few minutes to run depending on dataset size and number of bootstraps.   
```  
PIntervals <- predictionInterval(trainData, smMatrix, mmMatrix, PIprobs = 0.9, maxIt=300, stopCriterion=7,noBoots=20, testData)  
```  
PIntervals is now a list object containing 2 dataframes. The average case and casewise prediction intervals for each point prediction.

### Calculation of Prediction Metrics  
```  
ppredictionMetrics <- validatePredict(Anime, smMatrix, mmMatrix,noFolds=10)  
```  
The variable predictionMetrics is now a list of 6 dataframes, being RMSE, MAPE and MAD calculated using PLSpredict a Linear Model (benchmark ) for each target item.

## Citation  
Shmueli, G., Ray, S., Estrada, J. M., & Chatla, S. (n.d.). The Elephant in the Room: Evaluating the Predictive Performance of Partial Least Squares (PLS) Path Models (2015). SSRN Electronic Journal SSRN Journal.  