package utils.cache;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.exceptions.JedisConnectionException;
import redis.embedded.RedisServer;

import java.io.IOException;

/**
 * Created by shaveta on 16/4/17.
 */
public class JedisConnectionHandler {
  //address of your redis server
  private static final String REDIS_HOST = "localhost";
  private static final Integer REDIS_PORT = 6379;

  //adding default caching of 1 day
  public static final Integer DEFAULT_REDIS_TTL = 60*60*24;

  //the jedis connection pool..
  private static JedisPool pool = null;
  private static Jedis jedis = null;
  private static RedisServer redisServer;

  public JedisConnectionHandler() {
    startRedisServer();
    pool = new JedisPool(REDIS_HOST, REDIS_PORT);
    this.jedis = getConnection();
  }

  protected void startRedisServer() {
    try {
      if(null == redisServer || !redisServer.isActive()) {
        redisServer = new RedisServer(6379);
        redisServer.start();
      }
    } catch(IOException e){
      System.out.print("error starting redis server");
    }
  }

  protected Jedis getConnection() {
    Jedis jedis = null;
    try {
      jedis = this.pool.getResource();
    } catch(JedisConnectionException e) {
      System.out.println("[JedisConnectionHandler] exception caught " + e.toString());
    }
    return jedis;
  }

  public void set(String key, Object value, Integer TTL) throws IOException {
    try {
      byte[] rawData;
      rawData = Serializer.serialize(value);
      jedis.setex(key.getBytes(), TTL, rawData);
    } catch(Exception e) {
      System.out.print("[JedisConnectionHandler] exception caught " + e);
    } finally {
      if(null != jedis) {
        jedis.close();
      }
    }
  }

  public Object get(String key) throws IOException {
    Object obj = null;
    try {
      byte[] value = jedis.get(key.getBytes());
      if (null != value) {
        obj = Serializer.deserialize(value);
      }
    }
    finally {
      if (null != jedis) {

        jedis.close();
      }
    }
    return obj;
  }
}
