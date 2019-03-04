Who, amongst existing loan customers, are more likely to be default (bad)?


Modelingdata set has
–
more than 50 independent variables, and
–
one dependent binary variable: bad=1, non-bad=0.

Preliminary variable transformations through Rank & Plot.

Logistic Regression
logit(P / (1-P))= α+ β1x1+ β2x2+ ... + βNxN, using stepwise
selection technique

Correlation between variables, model concordance and goodness-of-fit are used to select the best-fit model

Importing data HMEQ into SAS Environment

Feature Engineering: creating new variables with new labels from old variables

Grouping (10 groups)

Data Cleaning: running macros to find, replace and clean missing values

Models improving: running several models with different Independent variables to compare and select the best performance.
