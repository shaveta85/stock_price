import responses.StockResponse;
import utils.cache.JedisConnectionHandler;
import yahoofinance.YahooFinance;
import com.google.inject.Inject;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.util.HashMap;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * Created by shaveta on 16/4/17.
 */


public class FinanceDao {

  private final JedisConnectionHandler cacheConnectionHandler;
  private Map<String, String> nameToSymbolMap;

  @Inject
  public FinanceDao(JedisConnectionHandler connectionHandler) {
    this.cacheConnectionHandler = connectionHandler;

  }

  public StockResponse getStockDetails(String stockName) throws Exception {
    StockResponse response = null;
    String stockSymbol = getSymbolFromName(stockName);
    stockSymbol = (null == stockSymbol)?stockName:stockSymbol;
    Object cacheObj = cacheConnectionHandler.get(stockSymbol);
    if(null != stockSymbol && null != cacheObj) {
      response = (StockResponse) cacheObj;
    } else {
      response = getStockDetailsFromApi(stockSymbol);
      cacheConnectionHandler.set(stockSymbol, response, JedisConnectionHandler.DEFAULT_REDIS_TTL);
    }
    return response;
  }

  public void readMap() {
    try {
      ObjectInputStream ois = new ObjectInputStream(new FileInputStream("./src/main/java/serialized_hashmap"));
      Object result = ois.readObject();
      nameToSymbolMap = (HashMap<String,String>)result;
    } catch(IOException | ClassNotFoundException e) {
      System.out.println("Exception occurred while reading file ");
      e.printStackTrace();
    }
  }

  private StockResponse getStockDetailsFromApi(String stockName) throws Exception {
    return new StockResponse(YahooFinance.get(stockName));
  }

  public Set<String> getStockNameList() {
    return nameToSymbolMap.keySet();
  }


  private String getSymbolFromName(String name) {
    String symbol = null;
    Set<String> keyset = nameToSymbolMap.keySet();
    String formattedName = name.trim().toLowerCase();
    for (String key : keyset) {
      String formattedKey = key.trim().toLowerCase();
      if (formattedKey.contains(formattedName)) {
        symbol = nameToSymbolMap.get(key);
      }
    }
    return symbol;
  }
}

