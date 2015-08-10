
import os

import numpy as np
import csv as csv
from sklearn import datasets, linear_model, preprocessing
from sklearn.metrics import mean_squared_error
from sklearn.metrics import r2_score
from sklearn.linear_model import ElasticNet
from sklearn.svm import SVR
from sklearn import tree
from sklearn.ensemble import RandomForestRegressor
class RandomForestRegressorWithCoef(RandomForestRegressor):
    def fit(self, *args, **kwargs):
        super(RandomForestRegressorWithCoef, self).fit(*args, **kwargs)
        self.coef_ = self.feature_importances_


from sklearn.cross_validation import train_test_split

from sklearn.feature_selection import RFE
from sklearn.feature_selection import RFECV

import pandas as pd

import numpy.ma as ma

from sklearn.metrics import r2_score



################################
###  Load Practicum Dataset  ###
################################

# Set WD
os.chdir('/Users/nectaryyo/Desktop/GW/Practicum/Regression_Pipeline')


#### Targets

# Loading Data Set
targets_train = csv.reader(open('targets_train.csv', 'rb')) #open file
targets_holdout = csv.reader(open('targets_holdout.csv', 'rb')) #open file

# Create an empty list to append each of the train file's lines
targets_train_full = []
targets_holdout_full = []

# Loop through the lines of the file to extract their contents
for row in targets_train:
    targets_train_full.append(row)

for row in targets_holdout:
    targets_holdout_full.append(row)

# Convert the data into a numpy array
targets_train_full = np.array(targets_train_full)
targets_holdout_full = np.array(targets_holdout_full)


# perc_65_and_over
y_65o = targets_train_full[1:, -1]
y_65o = np.array(y_65o, dtype = float)

y_65o_holdout = targets_train_full[1:, -1]
y_65o_holdout = np.array(y_65o_holdout, dtype = float)


# perc_55_to_64
y_55_64 = targets_train_full[1:, -2]
y_55_64 = np.array(y_55_64, dtype = float)

y_55_64_holdout = targets_train_full[1:, -2]
y_55_64_holdout = np.array(y_55_64_holdout, dtype = float)


# perc_45_to_54
y_45_54 = targets_train_full[1:, -3]
y_45_54 = np.array(y_45_54, dtype = float)

y_45_54_holdout = targets_train_full[1:, -3]
y_45_54_holdout = np.array(y_45_54_holdout, dtype = float)


# perc_35_to_44
y_35_44 = targets_train_full[1:, -4]
y_35_44 = np.array(y_35_44, dtype = float)

y_35_44_holdout = targets_train_full[1:, -4]
y_35_44_holdout = np.array(y_35_44_holdout, dtype = float)


# perc_25_to_34
y_25_34 = targets_train_full[1:, -5]
y_25_34 = np.array(y_25_34, dtype = float)

y_25_34_holdout = targets_train_full[1:, -5]
y_25_34_holdout = np.array(y_25_34_holdout, dtype = float)


# perc_18_to_24
y_18_24 = targets_train_full[1:, -6]
y_18_24 = np.array(y_18_24, dtype = float)

y_18_24_holdout = targets_train_full[1:, -6]
y_18_24_holdout = np.array(y_18_24_holdout, dtype = float)


# perc_under18
y_u18 = targets_train_full[1:, -7]
y_u18 = np.array(y_u18, dtype = float)

y_u18_holdout = targets_train_full[1:, -7]
y_u18_holdout = np.array(y_u18_holdout, dtype = float)





#### Predictors

# Loading Data Set
predictors_train = csv.reader(open('predictors_train.csv', 'rb')) #open file
predictors_holdout = csv.reader(open('predictors_holdout.csv', 'rb')) #open file

# Create an empty list to append each of the train file's lines
predictors_train_full = []
predictors_holdout_full = []

# Loop through the lines of the file to extract their contents
for row in predictors_train:
    predictors_train_full.append(row)

for row in predictors_holdout:
    predictors_holdout_full.append(row)

# Convert the data into a numpy array
predictors_train_full = np.array(predictors_train_full)
predictors_holdout_full = np.array(predictors_holdout_full)

X = predictors_train_full[1:, 2:]
X = np.array(X, dtype = float)

X_holdout = predictors_holdout_full[1:, 2:]
X_holdout = np.array(X_holdout, dtype = float)


########
########
predictor_names = predictors_train_full[0, 2:]
########
########





################################
###          Pipeline        ###
################################

####### Declare regressors ######

# The shorts are for testing purposes
# The commented-out ones are not working and need to be fixed

regressors = [linear_model.LinearRegression(),
              linear_model.Ridge(alpha = .5),
              linear_model.Lasso(alpha = 0.1),
              #ElasticNet(alpha = 0.1, l1_ratio = 0.7),
              #linear_model.MultiTaskLasso(alpha = 0.1),
              #linear_model.Lars(n_nonzero_coefs = 1),
              #linear_model.LassoLars(alpha = .1),
              #linear_model.OrthogonalMatchingPursuit((n_nonzero_coefs = 17)),
              #linear_model.BayesianRidge(),
              #linear_model.ARDRegression(),
              linear_model.SGDRegressor(),
              linear_model.PassiveAggressiveRegressor(),
              SVR(kernel = 'linear'),
              #KernelRidge(alpha=1.0)
              RandomForestRegressorWithCoef()
              ]

#regressors = [linear_model.PassiveAggressiveRegressor()]

regressor_names = ['Ordinary Least Squares',
                   'Ridge Regression',
                   'Lasso Regression',
                   #'Elastic Net',
                   #'Multitask Lasso',
                   #'Least Angle Regression (LARS)',
                   #'Lasso LARS',
                   #'Orthogonal Matching Pursuit',
                   #'Bayesian Ridge Regression',
                   #'Automatic Relevance Determination (ARD) Regression',
                   'Stochastic Gradient Descent (SGD) Regression',
                   'Passive Aggressive Regression',
                   'Support Vector Machines for Regression',
                   #'Kernel Ridge Regression'
                   'Random Forrest Regressor'
                   ]

#regressor_names = ['xxxx']

###### Run Pipeline ######


### Method 1
# Builds a list of lists with 3 columns, current regressor name, current feature reduction number (10 through 1), MSE
# Convert list of lists into a pandas df (sortable)
# This allows to easily sort and see which the best models are
def pipeline(target_variable):

    X_train, X_test, y_train, y_test = train_test_split(X,
                                                    target_variable,
                                                    test_size = 0.2,
                                                    random_state = 1)

    output = []

    for i in range(0, len(regressors)):

        # This loop selects features for all possible number of feature selections
        for j in range(X_train.shape[1], 0, -1):

            # Declare temporary regressor
            temp_regressor = regressors[i]

            # Create the feature selector with the temporary regressor and the j number of features to select
            #selector = RFE(temp_regressor, j, step = 1)
            selector = RFECV(temp_regressor, step = j, cv = 5)

            # Fit the selector
            selector_fit = selector.fit(X_train, y_train)
            feature_bool = selector_fit._get_support_mask()
            features = predictor_names[feature_bool]

            # Create an boolean index filter to then trim unselected features
            slimmer = selector_fit.support_
            # Trim unselected features from x variables (trained data)
            X_train_slim = X_train[:, slimmer]

            # Fit the temporary regressor onto the slimmed x trained data
            temp_regressor.fit(X_train_slim, y_train)

            # Trim the test data by removing unselected features
            X_test_slim = X_test[:, slimmer]

            # Predict the y test data
            y_pred = temp_regressor.predict(X_test_slim)

            # Append the regressor name, the number of selected features and the MSE
            output.append([regressor_names[i], j, r2_score(y_test, y_pred), features])

    output_df = pd.DataFrame(output, columns = ['Regressor', 'Selected Features', 'R2', 'Features']).sort(['R2'],
                                                                                                          ascending =
                                                                                                          False)

    return output_df


output_df_u18 = pipeline(y_u18)
output_df_18_24 = pipeline(y_18_24)
output_df_25_34 = pipeline(y_25_34)
output_df_35_44 = pipeline(y_35_44)
output_df_45_54 = pipeline(y_45_54)
output_df_55_64 = pipeline(y_55_64)
output_df_65o = pipeline(y_65o)

output_df_u18.to_csv('output_df_u18.csv', encoding='utf-8', index = False)
output_df_18_24.to_csv('output_df_18_24.csv', encoding='utf-8', index = False)
output_df_25_34.to_csv('output_df_25_34.csv', encoding='utf-8', index = False)
output_df_35_44.to_csv('output_df_35_44.csv', encoding='utf-8', index = False)
output_df_45_54.to_csv('output_df_45_54.csv', encoding='utf-8', index = False)
output_df_45_54.to_csv('output_df_55_64.csv', encoding='utf-8', index = False)
output_df_65o.to_csv('output_df_65o.csv', encoding='utf-8', index = False)
