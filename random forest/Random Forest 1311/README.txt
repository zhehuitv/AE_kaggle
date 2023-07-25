FILES

I use rf1_trialsubmit as my submission code.

I have been using rf1trial4 to do my trial and error. Can continue by changing variable

Trainedit and Testedit -> Original dataset with some columns  removed

Logloss is the file used to calc logloss. Can directly use the rf1_unprocessed to calculate





rftrial 4 -> 45.58% accuracy

rf_model <- randomForest(target~.-No -CC4 -GN4 -NS4 -BU4 -FA4 -LD4 -BZ4 -FC4 -FP4 -RP4 -PP4 -KA4 -SC4 -TS4 -NV4 -MA4 -LB4 -AF4 -HU4 -Price4 -gendind, data=trainingData, ntree=1000, importance=TRUE)

Change to seed(12) 45.88% Accuracy
