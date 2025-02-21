maxRows <- 3100

getOrders <- function(store, newRowList, currentPos, info, params) { 
  allzero <- rep(0,length(newRowList))
  positions <- allzero
  
  if (is.null(store)) store <- initStore(newRowList,params$series)
  store <- updateStore(store, newRowList, params$series)
  marketOrders <- -currentPos

  if(params$lookback < store$iter) {
    firstInd <- store$iter - params$lookback
    for (i in 1:length(params$series)) {
      close <- newRowList[[params$series[i]]]$Close
      BolBands <- last(BBands(store$cl[firstInd:store$iter,i],n=params$lookback,sd=params$sdParam))
      
      if(close < BolBands[,"dn"] || BolBands[,"pctB"] < 0.05) {
        positions[params$series[i]] <- -(params$posSizes[params$series[i]])
      } else if (close > BolBands[,"up"] || BolBands[,"pctB"] > 0.95) {
        positions[params$series[i]] <- params$posSizes[params$series[i]]
      }
    }
  }
  
  marketOrders <- marketOrders + positions
      

      return(list(store=store,marketOrders=marketOrders,
                  limitOrders1=allzero,limitPrices1=allzero,
                  limitOrders2=allzero,limitPrices2=allzero))
}

posSizes_x4 <- function(rList,s) {
  #rList <- lapply(rList, function(x) x$Open)
  spreads <- lapply(rList, function(x) diff(x$High-x$Low))
  #simple_ret <- vector(mode = "list",length = 10)
  #simple_ret <- lapply
  opens <- sapply(rList, function(x) x$Open[1])
  absSpreads <- lapply(spreads, abs)
  meanAbsSpreads <- sapply(absSpreads, mean, na.rm = TRUE)
  largestSpread <- sapply(absSpreads,max,na.rm = TRUE)
  AccLargestSpread <- max(largestSpread)
  positionSizes <- round(AccLargestSpread/((meanAbsSpreads)))
  estCost <- sum(positionSizes * opens)
  budget <- 900000
  multiplier <- budget/estCost
  positionSizes <- round(positionSizes * multiplier)
  
  return(positionSizes)
  
}

posSizez <- function(rList) {
  rList <- lapply(rList, function(x) x$Open)
  first_opens <- sapply(rList, function(x) x$Open[1])
  simple_ret <- vector(mode = "list",length = length(rList))
  for (i in 1:length(rList)) {
    simple_ret[[i]] <- rep(0,nrow(rList[[i]]))
  }
  opens <- lapply(rList, function(x) as.numeric(x))
  for (i in 1:length(simple_ret)) {
    for (k in 2:length(opens[[i]])) {
      simple_ret[[i]][k] <- (opens[[i]][k]-opens[[i]][k-1])/opens[[i]][k-1]
      simple_ret[[i]][k] <- simple_ret[[i]][k] +1
    }
    simple_ret[[i]] <- simple_ret[[i]][2:length(simple_ret[[1]])]
    
  }
  cum_ret <- sapply(simple_ret,function(x) prod(x)-1)
  for (i in 1:length(cum_ret)) {
    if(cum_ret[i]<0) {
      cum_ret[i] <- 1
    } 
  }
  cum_ret <- cum_ret*100
  positionSizes <- round(cum_ret)
  estCost <- sum(positionSizes * first_opens)
  budget <- 900000
  multiplier <- budget/estCost
  positionSizes <- round(positionSizes * multiplier)
  
  
  return(positionSizes)
}

initClStore  <- function(newRowList,series) {
  clStore <- matrix(0,nrow=maxRows,ncol=length(series))
  return(clStore)
}
updateClStore <- function(clStore, newRowList, series, iter) {
  for (i in 1:length(series))
    clStore[iter,i] <- as.numeric(newRowList[[series[i]]]$Close)
  return(clStore)
}
initStore <- function(newRowList,series) {
  return(list(iter=0,cl=initClStore(newRowList,series)))
}
updateStore <- function(store, newRowList, series) {
  store$iter <- store$iter + 1
  store$cl <- updateClStore(store$cl,newRowList,series,store$iter) 
  return(store)
}

  

