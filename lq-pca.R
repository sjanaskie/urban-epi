library(ckanr)
ckanr_setup(url = 'https://datahub.io/', key = '3f3a56c4-4e29-4f18-851f-c607a1286f80')
lq=read.table("https://datahub.io/dataset/e82a4e76-ccf0-4d3a-b2c8-eda2b52ab32a/resource/b84778f4-2db4-4667-a329-9be97704e296/download/lq2.csv", 
              header = TRUE, sep = ",")
for (i in 1:length(lq$COUNTYFP) ) 
  if ( nchar(lq$COUNTYFP[i]) == 1 ) {
    lq$COUNTYFP[i] <- paste("00",lq$COUNTYFP[i], sep = "")
   } else if ( nchar(lq$COUNTYFP[i]) == 2) {
    lq$COUNTYFP[i] <- paste("0",lq$COUNTYFP[i], sep = "")
  } else {
     lq$COUNTYFP[i] <- lq$COUNTYFP[i]
  }
lq$COUNTYFP <- as.factor(lq$COUNTYFP)

str(lq)

#transform select variables and reassemble into a new dataset
lq <- lq[,4:ncol(lq)]

#Keep only complete cases
lq <- lq[complete.cases(lq),]
str(lq)

##########################################################
##  Perform Factor Analysis using Maximum Likelihood
##  with Varimax Rotation
##########################################################


fact1=factanal(lq[,c(1:11,13,14)],factors=5,rotation="varimax")
fact1

#get loading plot for first two factors
plot(fact1$loadings, pch=18, col='red')
abline(h=0)
abline(v=0)
text(fact1$loadings, labels=names(lq),cex=0.5)

#get loading plot for factors 1 and 3
plot(fact1$loadings[,c(1,3)], pch=18, col='red')
abline(h=0)
abline(v=0)
text(fact1$loadings[,c(1,3)], labels=names(lq),cex=0.5)

#get reproduced correlation matrix
repro1=fact1$loadings%*%t(fact1$loadings)
#residual correlation matrix
resid1=fact1$cor-repro1
round(resid1,2)

#get root-mean squared residuals
len=length(resid1[upper.tri(resid1)])
RMSR1=sqrt(sum(resid1[upper.tri(resid1)]^2)/len)
RMSR1

#get proportion of residuals greater than 0.05 in absolute value
sum(rep(1,len)[abs(resid1[upper.tri(resid1)])>0.05])/len




##########################################################
##  Perform Factor Analysis using PAF
##  with Varimax Rotation
##########################################################

library(psych)

fact2=fa(lq[,c(1:11,13)],nfactors=3,rotate="varimax",fm='pa')
fact2

#get loading plot for first two factors
plot(fact2$loadings, pch=18, col='red')
abline(h=0)
abline(v=0)
text(fact2$loadings, labels=names(lq),cex=0.5)

#get loading plot for factors 1 and 3
plot(fact2$loadings[,c(1,3)], pch=18, col='red')
abline(h=0)
abline(v=0)
text(fact2$loadings[,c(1,3)], labels=names(lq),cex=0.5)

#get reproduced correlation matrix
repro2=fact2$loadings%*%t(fact2$loadings)
#residual correlation matrix
resid2=cor(lq[,-1])-repro2
round(resid2,2)

#get root-mean squared residuals
len=length(resid2[upper.tri(resid2)])
RMSR2=sqrt(sum(resid2[upper.tri(resid2)]^2)/len)
RMSR2

#get proportion of residuals greater than 0.05 in absolute value
sum(rep(1,len)[abs(resid2[upper.tri(resid2)])>0.05])/len





##########################################################
##  Perform Factor Analysis using iterative PCA
##  with Varimax Rotation
##########################################################

library(psych)

fact3=factor.pa(lq[,c(1:11,13,14)],nfactors=3,rotate="varimax", SMC=FALSE)
fact3

#get loading plot for first two factors
plot(fact3$loadings, pch=18, col='red')
abline(h=0)
abline(v=0)
text(fact3$loadings, labels=names(lq),cex=0.5)

#get loading plot for factors 1 and 3
plot(fact3$loadings[,c(1,3)], pch=18, col='red')
abline(h=0)
abline(v=0)
text(fact3$loadings[,c(1,3)], labels=names(lq),cex=0.5)

#get reproduced correlation matrix
repro3=fact3$loadings%*%t(fact3$loadings)
#residual correlation matrix
resid3=cor(lq[,c(1:11,13,14)])-repro3
round(resid3,2)

#get root-mean squared residuals
len=length(resid3[upper.tri(resid3)])
RMSR3=sqrt(sum(resid2[upper.tri(resid3)]^2)/len)
RMSR3

#get proportion of residuals greater than 0.05 in absolute value
sum(rep(1,len)[abs(resid3[upper.tri(resid3)])>0.05])/len


##########################################################
##  Get KMO and other measurements (and also PAF again)
##########################################################

library(rela)
fact4=paf(as.matrix(lq[,c(1:11,13,14)]))
fact4  #LOTS of output here!
summary(fact4)

