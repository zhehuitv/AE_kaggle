random forest files go here


ZH_1st_RF
- after running the model and trying to predict, we realised that there was an error
- the training data didnt have some factor values that were inside the test data
- we changed the factor values to the nearest one instead
- it did improve our score but we will be removing income in the next one

Random Forest 1311
-Random Forest model that was ran to give us the result of 1.31184 on public leaderboard
-Non-index columns of variables were removed in trainedit and testedit csv files
A few more variables were used below
model <- train(target~.-No -CC4 -GN4 -NS4 -BU4 -FA4 -LD4 -BZ4 -FC4 -FP4 -RP4 -PP4 -KA4 -SC4 -TS4 -NV4 -MA4 -LB4 -AF4 -HU4 -Price4 -genderind, data=trainingData, method=\rf\, metric=\Accuracy\, tuneGrid=grid, trControl=control, ntree=1000)

-We continued experimenting with removal of variables giving us scores of 1.30305 and 1.30502. 
