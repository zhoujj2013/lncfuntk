import numpy as np
from scipy import interp
import matplotlib.pyplot as plt
import sys
import os

from sklearn import svm, datasets
from sklearn.metrics import roc_curve, auc
from sklearn.cross_validation import StratifiedKFold

###############################################################################
# prepare dataset
###############################################################################

kfold = int(sys.argv[3])
prefix = sys.argv[4]

dat_fh = open(sys.argv[1], 'rb')
tar_fh = open(sys.argv[2], 'rb')
dat = []
while True:
    l = dat_fh.readline()
    if len(l) == 0:
        break
    lc = l.strip("\n").split("\t")
    dat.append([float(i) for i in lc])

X = np.array(dat)

tar = []
while True:
    l = tar_fh.readline()
    if len(l) == 0:
        break
    lc = l.strip("\n").split("\t")
    tar.append(float(lc[0]))

y = np.array(tar)

###############################################################################
# Classification and ROC analysis
# 
# Run classifier with cross-validation and plot ROC curves
print "Training data count: " + str(len(y))
cv = StratifiedKFold(y, n_folds=kfold)

#for train, test in cv:
#    print("%s %s" % (train, test))


####################
# your classifier
####################

if prefix == "LR":
	from sklearn.linear_model import LogisticRegression
	classifier = LogisticRegression(penalty='l2', C=1)
elif prefix == "GBDT":
	from sklearn.ensemble import GradientBoostingClassifier
	classifier = GradientBoostingClassifier(n_estimators=200)
elif prefix == "RF":
	from sklearn.ensemble import RandomForestClassifier
	classifier = RandomForestClassifier(n_estimators=10)
elif prefix == "SVM":
	from sklearn.svm import SVC
	classifier = SVC(kernel='linear', probability=True)
elif prefix == "NB":
	from sklearn.naive_bayes import MultinomialNB
	classifier = MultinomialNB(alpha=0.01)
elif prefix == "KNN":
	from sklearn.neighbors import KNeighborsClassifier
	classifier = KNeighborsClassifier()
elif prefix == "DT":
	from sklearn import tree
	classifier = tree.DecisionTreeClassifier()
else:
	print >>sys.stderr, "Wrong prefix: " % (prefix)

mean_tpr = 0.0
mean_fpr = np.linspace(0, 1, 100)
all_tpr = []
model_save = {}
best_model_auc = 0
best_model_index = 0
from sklearn import metrics
for i, (train, test) in enumerate(cv):
    classifier.fit(X[train], y[train])
    a = classifier.fit(X[train], y[train])
    #print a.coef_
    probas_ = classifier.fit(X[train], y[train]).predict_proba(X[test])
    # Compute ROC curve and area the curve
    fpr, tpr, thresholds = roc_curve(y[test], probas_[:, 1], pos_label=1)
    predict = classifier.fit(X[train], y[train]).predict(X[test])
    precision = metrics.precision_score(y[test], predict)
    recall = metrics.recall_score(y[test], predict)
    print str(precision) + "\t" + str(recall)
    mean_tpr += interp(mean_fpr, fpr, tpr)
    mean_tpr[0] = 0.0
    roc_auc = auc(fpr, tpr)
    model_save[i] = classifier
    if roc_auc > best_model_auc:
        best_model_auc = roc_auc
        best_model_index = i
    plt.plot(fpr, tpr, lw=1, label='ROC fold %d (area = %0.2f)' % (i, roc_auc))

from sklearn.externals import joblib
print best_model_index


print "################\nCoef_\n";
print model_save[best_model_index].coef_[0]
print "###############\n";

coef_normalized_arr = []
coef_sum = sum(model_save[best_model_index].coef_[0])
for coef in model_save[best_model_index].coef_[0]:
	coef_normalized = coef/float(coef_sum)
	coef_normalized_arr.append(coef_normalized)

out = open("./" + prefix + ".weight.value.lst", 'wb')
print >>out,"miRNA_weight\t%.2f\nTF_weight\t%.2f\nPCG_weight\t%.2f" % (coef_normalized_arr[0], coef_normalized_arr[1], coef_normalized_arr[2]) 
out.close()

try: 
	os.makedirs("./" + prefix)
except OSError:
	if not os.path.isdir("./" + prefix):
		raise

joblib.dump(model_save[best_model_index], "./" + prefix + "/" + prefix + ".pkl")

if prefix == "LR" or prefix == "SVM" or prefix == "KNN":
	print model_save[best_model_index].coef_
	print model_save[best_model_index].intercept_
else:
	print model_save[best_model_index].feature_importances_

#plt.plot([0, 1], [0, 1], '--', color=(0.6, 0.6, 0.6), label='Luck')

plt.plot([0, 1], [0, 1], '--', color=(0.6, 0.6, 0.6))
mean_tpr /= len(cv)
mean_tpr[-1] = 1.0
mean_auc = auc(mean_fpr, mean_tpr)

out = open("./" + prefix + ".tpr.fpr.txt", 'wb')
for i in range(0,len(mean_fpr), 1):
         print >>out, "%.4f\t%.4f" % (mean_tpr[i], mean_fpr[i])
out.close()

plt.plot(mean_fpr, mean_tpr, 'k--',
         label='Mean ROC (area = %0.2f)' % mean_auc, lw=2)

plt.xlim([-0.05, 1.05])
plt.ylim([-0.05, 1.05])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('Receiver operating characteristic by ' + prefix)
plt.legend(loc="lower right")
plt.savefig("./" + prefix + ".png")
