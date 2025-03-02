package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Controller class that handles HTTP requests.
 */
@RestController
public class HelloController {

    /**
     * Handles GET requests to the root ("/") endpoint.
     *
     * @return A greeting message.
     */
    @GetMapping("/")
    public String hello() {
        return "Hello, From Mohamed Osama";
    }
    @GetMapping("/live")
    public String hello_from_live() {
        return "Hello, From Live Endpoint";
    }
}
