import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.ensemble import RandomForestClassifier
from sklearn.multioutput import MultiOutputClassifier
from sklearn import model_selection   # added
from sklearn.model_selection import cross_val_score   # added
from sklearn.tree import export_graphviz
from sklearn import tree 
from sklearn.metrics import cohen_kappa_score
import sklearn.metrics as sm
#import pydotplus 

#train = pd.read_csv("./train.csv")
#test = pd.read_csv("./test.csv")

#train1.head()

# primarily focus on those that are most relevent
cols = [ 'NUM_ADULTS', 'NUM_CHILD', 'EDUCATION', 'HOMEVAL', 
        'EST_INCOME', 'NUM_CARS', 'POP_SQMI', 'VEHICLE_PURCHASE_INTENT']
colsRes = ['EV_TOT']    # results to forecast

train = pd.read_excel('./train.xlsx')          
for i in range(len(cols)):                      # remove rows that are empty
    train = train[np.isfinite(train[cols[i]])]
train['NUM_CARS']= 1/train['NUM_CARS']

test = pd.read_excel('./test.xlsx')
for i in range(len(cols)):
    test = test[np.isfinite(test[cols[i]])]
test['NUM_CARS']= 1/test['NUM_CARS']

trainArr = train.as_matrix(cols)        # train.as_matrix will execute the array and 
trainRes = train.as_matrix(colsRes)

rf = RandomForestClassifier(n_estimators=500)
#multi_rf = MultiOutputClassifier(rf, n_jobs=-1)
#multi_rf.fit(trainArr, trainRes)
rf.fit(trainArr, trainRes)

testArr = test.as_matrix(cols)
results = rf.predict(testArr)
#results = multi_rf.predict(testArr)

# check the relative importance of the fields to result
scores = model_selection.cross_val_score(rf, testArr, results)
#scores = model_selection.cross_val_score(multi_rf, testArr, results)
print "Mean cross validation score: ", scores.mean()

cohen = cohen_kappa_score(test['EV_TOT'],results)
#cohen = cohen_kappa_score(a,b)
print "Cohen's kappa score: ", cohen

# performance accuracy score between actual vs. predicted
accuracy = sm.accuracy_score(results,test['EV_TOT'])
print "Accuracy Score: ", accuracy

test['predictions'] = results
    
# feature importance
importances = rf.feature_importances_
indices = np.argsort(importances)

#print importances[indices][::-1]      # testing 

plt.figure(1)
plt.title('Feature Importances')
plt.barh(range(len(indices)), importances[indices], color='b', align='center')
#plt.yticks(range(len(indices)), reversed(cols))
plt.yticks(range(len(indices)), (cols[i] for i in indices))
plt.xlabel('Relative Importance')

test.head()  # return the first n rows if .head(n=5)

# create a ranking for zipcodes 
zip_rank = test
ind = indices[::-1]

# column values * relative importance
col1 = test[cols[ind[0]]] * importances[ind[0]]
col2 = test[cols[ind[1]]] * importances[ind[1]]
col3 = test[cols[ind[2]]] * importances[ind[2]]
col4 = test[cols[ind[3]]] * importances[ind[3]]
col5 = test[cols[ind[4]]] * importances[ind[4]]

# EV actual number weight. This could be indicative of the control behavior weight.

ev_weight = 0.6

zip_rank['COST_FUNC'] = (col1+col2+col3+col4+col5) * (1-ev_weight)
zip_rank['Rank'] = (zip_rank['COST_FUNC'] + ev_weight*zip_rank['EV_TOT']).astype(int).rank(method='dense',ascending=False).astype(int)
zip_rank_sort = zip_rank.sort_values('Rank')

writer = pd.ExcelWriter('./Results/output.xlsx')
zip_rank_sort.to_excel(writer, 'UPNY')
writer.save()