import responses.StockResponse;
import spark.ModelAndView;
import spark.template.freemarker.FreeMarkerEngine;
import utils.cache.JedisConnectionHandler;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import static spark.Spark.*;

public class Main {

  public static void main(String[] args) {

    port(Integer.valueOf(System.getenv("PORT")));
    staticFileLocation("/public");
    JedisConnectionHandler connectionHandler = new JedisConnectionHandler();
    FinanceDao financeDao = new FinanceDao(connectionHandler);
    financeDao.readMap();
    Set<String> companyStockNames = financeDao.getStockNameList();

    get("/", (request, response) -> {
      Map<String, Object> attributes = new HashMap<>();
      String symbol = request.queryParams("symbol");
      try {
        StockResponse information = financeDao.getStockDetails(symbol);
        attributes.put("stock", information);
        attributes.put("symbol", symbol);
        attributes.put("companyList", companyStockNames);
      } catch (Exception e) {
      }

      return new ModelAndView(attributes, "index.ftl");
    }, new FreeMarkerEngine());

  }

}
