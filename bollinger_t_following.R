maxRows <- 3100

getOrders <- function(store, newRowList, currentPos, info, params) { 
  allzero <- rep(0,length(newRowList))
  positions <- allzero
  limitOrders1=allzero
  limitPrices1=allzero
  limitOrders2=allzero
  limitPrices2=allzero
  
  if (is.null(store)) {
    store <- initStore(newRowList,params$series)
    store$highestSinceEntry <- matrix(0,nrow=maxRows,ncol=length(params$series))
  } 
  store <- updateStore(store, newRowList, params$series)
  marketOrders <- -currentPos
  latestPrices <- sapply(1:length(newRowList), function(i) as.numeric(newRowList[[i]]$Close))
  
  # Calculate volatility-adjusted position sizes inversely proportional to price and volatility
  largestPrice <- max(latestPrices)
  params$posSizes <- round(largestPrice / latestPrices)  # Inversely proportional to price
  
  # Calculate recent volatility (e.g., standard deviation over 20 days)
  volatilities <- sapply(1:length(newRowList), function(i) {
    if (store$iter > 20) {
      sd(store$cl[(store$iter - 19):store$iter, i])
    } else {
      1  # equal 1 if data is insufficient
    }
  })
  
  # Adjust position sizes by inverse volatility
  params$posSizes <- round(params$posSizes / volatilities)

  
  # Position size multiplier to increase return potential
  estCostToBuy <- sum(params$posSizes * latestPrices)
  target <- info$balance  # Try to spend this much
  
  multiplier <- target / estCostToBuy
  params$posSizes <- round(multiplier * params$posSizes)
  

  if(params$lookback < store$iter) {
    firstInd <- store$iter - params$lookback
    for (i in 1:length(params$series)) {
      close <- newRowList[[params$series[i]]]$Close
      
      BolBands <- last(BBands(store$cl[firstInd:store$iter,i],n=params$lookback,sd=params$sdParam))
      
      if(close < BolBands[,"dn"] || BolBands[,"pctB"] < 0.05) {
        positions[params$series[i]] <- -round(params$posSizes[params$series[i]]*0.5)
        limitOrders1[params$series[i]] <- round(params$posSizes[params$series[i]]*0.25)
        limitOrders2[params$series[i]] <- -(round(params$posSizes[params$series[i]]*0.25))
        limitPrices1[params$series[i]] <- BolBands[,"dn"]-(BolBands[,"mavg"]-BolBands[,"dn"])*4
        limitPrices2[params$series[i]] <- close+(BolBands[,"up"]-BolBands[,"mavg"])
        store$highestSinceEntry[store$iter, i] <- close
      } else if (close > BolBands[,"up"] || BolBands[,"pctB"] > 0.95) {
        positions[params$series[i]] <- round(params$posSizes[params$series[i]]*0.5)
        limitOrders1[params$series[i]] <- round(params$posSizes[params$series[i]]*0.25)
        limitOrders2[params$series[i]] <- -round(params$posSizes[params$series[i]]*0.25)
        limitPrices1[params$series[i]] <- BolBands[,"dn"]-(BolBands[,"mavg"]-BolBands[,"dn"])*3
        limitPrices2[params$series[i]] <- close+(BolBands[,"up"]-BolBands[,"mavg"])*2
        store$highestSinceEntry[store$iter, i] <- close
      }
      
      if (currentPos[i] != 0) {  # If there is an open position
        if (currentPos[i] > 0) {  # Long position
          if (close < 0.90 * store$highestSinceEntry[store$iter, i]) {  # Exit if price drops below 90% of highest price
            positions[i] <- -currentPos[i]  # Close the position
            limitOrders1[params$series[i]] <- 0
            limitOrders2[params$series[i]] <- 0
            }
        } else if (currentPos[i] < 0) {  # Short position
          if (close > 1.10 * store$highestSinceEntry[store$iter, i]) {  # Exit if price rises above 110% of lowest price
            positions[i] <- -currentPos[i]  # Close the position
            limitOrders1[params$series[i]] <- 0
            limitOrders2[params$series[i]] <- 0
          }
        }
      }
    }
      maxDrawdown <- 0.26  # Stop trading if drawdown exceeds 20%
      if (sum(abs(positions)) > 0 && sum(abs(currentPos)) / sum(abs(positions)) > maxDrawdown) {
        marketOrders <- allzero  # Close all positions
        limitOrders1 <- allzero
        limitOrders2 <- allzero
      } else {
        marketOrders <- marketOrders + positions
      }
    }

  
  

      return(list(store=store,marketOrders=marketOrders,
                  limitOrders1=limitOrders1,limitPrices1=limitPrices1,
                  limitOrders2=limitOrders2,limitPrices2=limitPrices2))
}

  

