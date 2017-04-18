package responses;

import yahoofinance.Stock;

import java.io.Serializable;
import java.math.BigDecimal;
import lombok.Getter;
/**
 * Created by quikr on 16/4/17.
 */

@Getter
public class StockResponse implements Serializable {
  private String name = "NA";
  private BigDecimal price;
  private BigDecimal priceDiff;
  private double priceDiffPercentage;
  private String symbol = "NA";
  private String currency = "NA";
  private String stockExchange = "NA";

  public StockResponse(Stock stock) {
    this.name = stock.getName();
    this.currency = stock.getCurrency();
    this.symbol = stock.getSymbol();
    this.price = stock.getQuote().getPrice();
    this.priceDiff = this.price.subtract(stock.getQuote().getOpen());
    this.stockExchange = stock.getStockExchange();
    this.priceDiffPercentage = this.priceDiff.doubleValue()/(this.price.doubleValue());
  }
}
