package room;

import cartago.Artifact;
import cartago.OPERATION;

import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.io.IOException;
import java.net.URI;


/**
 * A CArtAgO artifact that provides an operation for sending messages to agents 
 * with KQML performatives using the dweet.io API
 */
public class DweetArtifact extends Artifact {
    
    void init() {
    }

    private static final String URI_DWEET = "https://dweet.io/dweet/for/atillas-dweet";

    @OPERATION
    void publish(String m) {

        final var dweet = """
                {"m": "%s"}
                """.formatted(m);

        System.out.println(dweet);
        final var client = HttpClient.newHttpClient();
        final var request = HttpRequest.newBuilder(URI.create(URI_DWEET))
                .POST(HttpRequest.BodyPublishers.ofString(dweet))
                .header("Content-Type", "application/json")
                .build();
        try {
            final var send = client.send(request, HttpResponse.BodyHandlers.discarding());
            if(send.statusCode() > 200) {
                System.out.println(send.statusCode());
                System.out.println("Something went wrong");
            }
        } catch (IOException | InterruptedException e) {
            throw new RuntimeException(e);
        }
    }
}

