cocktail<-function(x,y,d,
nlambda=100,lambda.min=ifelse(nobs<nvars,1e-2,1e-4),lambda=NULL, 
alpha=1,pf=rep(1,nvars),exclude,dfmax=nvars+1,pmax=min(dfmax*1.2,nvars),
standardize=TRUE,eps=1e-6,maxit=1e4)
{
	#################################################################################	
	#data setup
	this.call=match.call()
	y=drop(y)
	np=dim(x)
	nobs=as.integer(np[1])
	nvars=as.integer(np[2])
	vnames=colnames(x)
  	if(is.null(vnames))vnames=paste("V",seq(nvars),sep="")
    if(length(y)!=nobs) stop("x and y have different number of observations")
	#################################################################################	
	#parameter setup
	if(length(pf)!=nvars) stop("The size of penalty factor must be same as the number of input variables")
	if(alpha<=0) stop("alpha must be positive")
	maxit=as.integer(maxit)
	alpha=as.double(alpha)
	pf=as.double(pf)
	isd=as.integer(standardize)
	eps=as.double(eps)
	dfmax=as.integer(dfmax)
	pmax=as.integer(pmax)
	if(!missing(exclude)){
		jd=match(exclude,seq(nvars),0)
		if(!all(jd>0)) stop("Some excluded variables out of range")
		jd=as.integer(c(length(jd),jd))
	}
	else jd=as.integer(0)
	#################################################################################	
	#lambda setup
	nlam=as.integer(nlambda)
	if(is.null(lambda)){
		if(lambda.min>=1) stop("lambda.min should be less than 1")
		flmin=as.double(lambda.min)
		ulam=double(1) #ulam=0 if lambda is missing
	}
	else{
		#flmin=1 if user define lambda
		flmin=as.double(1)    
		if(any(lambda<0)) stop("lambdas should be non-negative")
		ulam=as.double(rev(sort(lambda))) #lambda is declining
		nlam=as.integer(length(lambda))
	}
	#################################################################################	
    fit=survpath(x,y,d,nlam,flmin,ulam,isd,eps,dfmax,pmax,jd,pf,maxit,alpha,penalty.type,nobs,nvars,vnames)
	if(is.null(lambda)) fit$lambda=lamfix(fit$lambda)##first lambda is infinity; changed to entry point
	fit$call=this.call
	class(fit)=c("cocktail",class(fit))
  	fit
}