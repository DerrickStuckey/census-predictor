
import os

import numpy as np
import csv as csv
from sklearn import datasets, linear_model, preprocessing
from sklearn.metrics import mean_squared_error
from sklearn.metrics import r2_score
from sklearn.linear_model import ElasticNet
from sklearn.svm import SVR

from sklearn.cross_validation import train_test_split

from sklearn.feature_selection import RFE

import pandas as pd

import numpy.ma as ma


################################
###  Load Practice Dataset   ###
################################

diabetes = datasets.load_diabetes()

# Split the data into training and testing sets
X_train = diabetes.data[:-20, ]
X_test = diabetes.data[-20:, ]

# Split the targets into training and testing sets
y_train = diabetes.target[:-20]
y_test = diabetes.target[-20:]



################################
###  Load Practicum Dataset  ###
################################

# Set WD
# os.chdir('/Users/nectaryyo/Desktop/GW/Practicum/Regression_Pipeline')
os.chdir('/Users/dstuckey/Desktop/GW/Practicum/census-predictor')

# Loading Train Data Set
# test = csv.reader(open('prepared_data/PracticumDataDum.csv', 'rb')) #open file
target_csv = csv.reader(open('prepared_data/Practicum_Targets.csv', 'rb')) #open file
predictor_csv = csv.reader(open('prepared_data/Practicum_Predictors_Normalized.csv', 'rb')) #open file

# Create an empty list to append each of the train file's lines
# test_full = []

# Loop through the lines of the file to extract their contents
# for row in test:
#     test_full.append(row)
target_data = []
for row in target_csv:
    target_data.append(row)

predictor_data = []
for row in predictor_csv:
    predictor_data.append(row)

# Convert the data into a numpy array
# test_full = np.array(test_full)
target_data = np.array(target_data)
predictor_data = np.array(predictor_data)

X = predictor_data[1:, :-1]
X = np.array(X, dtype = float)
Xm = ma.masked_values(X, -99999)
X = Xm.filled(np.nan)

imp = preprocessing.Imputer(missing_values = 'NaN', strategy = 'mean', axis = 0)
imp.fit(X)
X = imp.transform(X)


# y = test_full[1:, 2]
y = target_data[1:, 4]
y = np.array(y, dtype = float)



X_train, X_test, y_train, y_test = train_test_split(X,
                                                    y,
                                                    test_size = 0.2,
                                                    random_state = 1)




################################
###          Pipeline        ###
################################

####### Declare regressors ######

# The shorts are for testing purposes
# The commented-out ones are not working and need to be fixed

regressors = [linear_model.LinearRegression(),
              linear_model.Ridge(alpha = .5),
              linear_model.Lasso(alpha = 0.1),
              ElasticNet(alpha = 0.1, l1_ratio = 0.7),
              #linear_model.MultiTaskLasso(alpha = 0.1),
              linear_model.Lars(n_nonzero_coefs = 1),
              linear_model.LassoLars(alpha = .1),
              #linear_model.OrthogonalMatchingPursuit((n_nonzero_coefs = 17)),
              linear_model.BayesianRidge(),
              linear_model.ARDRegression(),
              linear_model.SGDRegressor(),
              linear_model.PassiveAggressiveRegressor(),
              SVR(kernel = 'linear'),
              #KernelRidge(alpha=1.0)
              ]

regressors_short = [linear_model.LinearRegression()]

regressor_names = ['Ordinary Least Squares',
                   'Ridge Regression',
                   'Lasso Regression',
                   'Elastic Net',
                   #'Multitask Lasso',
                   'Least Angle Regression (LARS)',
                   'Lasso LARS',
                   #'Orthogonal Matching Pursuit',
                   'Bayesian Ridge Regression',
                   'Automatic Relevance Determination (ARD) Regression',
                   'Stochastic Gradient Descent (SGD) Regression',
                   'Passive Aggressive Regression',
                   'Support Vector Machines for Regression',
                   #'Kernel Ridge Regression'
                   ]

regressor_names_short = ['Ordinary Least Squares']

###### Run Pipeline ######


### Method 1
# Builds a list of lists with 3 columns, current regressor name, current feature reduction number (10 through 1), MSE
# Convert list of lists into a pandas df (sortable)
# This allows to easily sort and see which the best models are

output = []

for i in range(0, len(regressors_short)):

    # This loop selects features for all possible number of feature selections
    for j in range(X_train.shape[1], 0, -1):

        # Declare temporary regressor
        temp_regressor = regressors_short[i]

        # Create the feature selector with the temporary regressor and the j number of features to select
        selector = RFE(temp_regressor, j, step = 1)

        # Fit the selector
        selector_fit = selector.fit(X_train, y_train)
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
        output.append([regressor_names_short[i], j, mean_squared_error(y_test, y_pred)])


# Convert list of lists to pandas data frame and the sort it by MSE (ascending - best result first)
output_df = pd.DataFrame(output, columns = ['Regressor', 'Selected Features', 'MSE'])
output_df = output_df.sort(['MSE'])





### Method 2
# Builds a data frame with a Regressor column and a column for each of the feature reductions (10 through 1)
# This creates a single row of data per regressor

# Create a list with all different possibilities of number of featrues (10 through 1 in the case of the diabetes test
#  set)
variable_range = range(X_train.shape[1], 0, -1)

# Create a list that will contain the column names
col_names = ['Regressor']

# Append the variable range to column name list
for i in variable_range:
    col_names.append(i)

# Create list of lists with col_names as first list
output = [col_names]


for i in range(0, len(regressors)):

    # Create a temporary list where the regressor name and all of the results for that regressor are appended
    temp_list = [regressor_names[i]]

    # This loop selects features for all possible number of feature selections (10 through 1)
    for j in range(X_train.shape[1], 0, -1):
        # Declare temporary regressor
        temp_regressor = regressors[i]

        # Create the feature selector with the temporary regressor and the j number of features to select
        selector = RFE(temp_regressor, j, step = 1)

        # Fit the selector
        selector_fit = selector.fit(X_train, y_train)
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

        # Append the Mean Square Error to the temporary list (whose first value is the regressor name
        temp_list.append(mean_squared_error(y_test, y_pred))

    output.append(temp_list)
