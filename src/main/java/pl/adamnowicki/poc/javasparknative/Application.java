package pl.adamnowicki.poc.javasparknative;

import static spark.Spark.get;
import static spark.Spark.port;

public class Application {
    public static void main(String[] args) {
        port(8080);
        get("/healthcheck", (req, res) -> "OK");
    }
}
