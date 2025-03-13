maxRows <- 3100 # Initializes matrix to store closing prices

getOrders <- function(store, newRowList, currentPos, info, params) {

  allzero <- rep(0, length(newRowList))  # used for initializing vectors
  marketOrders <- -currentPos  # Reset current positions to neutral
  limitOrders1=allzero
  limitPrices1=allzero
  limitOrders2=allzero
  limitPrices2=allzero

  # Initialize store if first run
  if (is.null(store)) {
    store <- initStore(newRowList, params$series)
    store$highestSinceEntry <- matrix(0, nrow=maxRows, ncol=length(params$series))  # Track highest price since entry
  }
  store <- updateStore(store, newRowList, params$series)

  # Get the latest closing prices
  latestPrices <- sapply(1:length(newRowList), function(i) as.numeric(newRowList[[i]]$Close))

  # Calculate volatility-adjusted position sizes inversely proportional to price and volatility
  largestPrice <- max(latestPrices)
  positionSizes <- round(largestPrice / latestPrices)  # Inversely proportional to price

  # Calculate recent volatility (e.g., standard deviation over 20 days)
  volatilities <- sapply(1:length(newRowList), function(i) {
    if (store$iter > 20) {
      sd(store$cl[(store$iter - 19):store$iter, i])
    } else {
      1  # equal 1 if data is insufficient
    }
  })

  # Adjust position sizes by inverse volatility
  positionSizes <- round(positionSizes / volatilities)

  # Position size multiplier to increase return potential
  estCostToBuy <- sum(positionSizes * latestPrices)
  target <- 900000  # Try to spend this much
  multiplier <- target / estCostToBuy
  positionSizes <- round(multiplier * positionSizes)

  # Main trading logic
  if (store$iter > max(params$lookback, params$williamsLookback)) {
    startIndexMA <- store$iter - params$lookback
    startIndexWilliams <- store$iter - params$williamsLookback
    pos <- allzero  # Initialize positions

    for (i in seq_along(params$series)) {
      cl <- newRowList[[params$series[i]]]$Close
      highs <- max(store$cl[startIndexWilliams:store$iter, i])  # Highs for Williams %R
      lows <- min(store$cl[startIndexWilliams:store$iter, i])   # Lows for Williams %R

      # Avoid division by zero in Williams %R calculation
      if (highs != lows) {
        williamsR <- -100 * (highs - cl) / (highs - lows)
      } else {
        williamsR <- 0
      }

      # Calculate moving average
      movingAvg <- mean(store$cl[startIndexMA:store$iter, i])

      # Main strategy logic
      if (cl > movingAvg) {
        if (williamsR < -80) {  # Oversold threshold (-80)
          # Increase position size at the same proportion as the oversold level
          signalStrength <- abs(williamsR + 80) / 20  # Scale based on signal strength
          pos[i] <- round(round(signalStrength * positionSizes[i])* 0.6) # Long position
          limitOrders1[i] <- round(round(signalStrength * positionSizes[i])* 0.2)
          limitOrders2[i] <- -round(round(signalStrength * positionSizes[i])* 0.2)
          limitPrices1[i] <- movingAvg * 0.5
          limitPrices2[i] <- movingAvg * 1.4
          store$highestSinceEntry[store$iter, i] <- cl   # Update highest price since entry
        }
      } else if (cl < movingAvg) {
        if (williamsR > -20) {  # Overbought threshold (-20)
          # Increase position size at the same proportion as the overbought level
          signalStrength <- abs(williamsR - 20) / 20
          pos[i] <- -round(round(signalStrength * positionSizes[i])* 0.6)  # Short position
          limitOrders1[i] <- round(round(signalStrength * positionSizes[i])* 0.2)
          limitOrders2[i] <- -round(round(signalStrength * positionSizes[i])* 0.2)
          limitPrices1[i] <- movingAvg * 0.7
          limitPrices2[i] <- movingAvg * 1.2
          store$highestSinceEntry[store$iter, i] <- cl  # Update highest price since entry
        }
      }

      # Trailing stop-loss logic (updated)
      if (currentPos[i] != 0) {  # If there is an open position
        if (currentPos[i] > 0) {  # Long position
          if (cl < 0.90 * store$highestSinceEntry[store$iter, i]) {  # Exit if price drops below 90% of highest price
            pos[i] <- -currentPos[i]  # Close the position
          }
        } else if (currentPos[i] < 0) {  # Short position
          if (cl > 1.10 * store$highestSinceEntry[store$iter, i]) {  # Exit if price rises above 110% of lowest price
            pos[i] <- -currentPos[i]  # Close the position
          }
        }
      }
    }

    # Drawdown monitoring
    maxDrawdown <- 0.20  # Stop trading if drawdown exceeds 20%
    if (sum(abs(pos)) > 0 && sum(abs(currentPos)) / sum(abs(pos)) > maxDrawdown) {
      pos <- allzero  # Close all positions
    }

    # Update only if there is a significant change from current positions
    if (sum(abs(pos - currentPos)) > 0.05 * sum(abs(currentPos))) {
      marketOrders <- marketOrders + pos  # Adjust market orders
    }
  }

  # Replace any N/A values in marketOrders with zeroes to avoid errors
  marketOrders[is.na(marketOrders)] <- 0

  return(list(store=store, marketOrders=marketOrders,
              limitOrders1=limitOrders1,
              limitPrices1=limitPrices1,
              limitOrders2=limitOrders2,
              limitPrices2=limitPrices2))
}
