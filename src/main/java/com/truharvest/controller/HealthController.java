package com.truharvest.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthController {

    /**
     * Returns basic info from the validated JWT.
     * If the token is missing or invalid, Spring Security returns 401 before this is reached.
     */
    @GetMapping("/me")
    public Map<String, Object> me(@AuthenticationPrincipal Jwt jwt) {
        return Map.of(
            "subject",  jwt.getSubject(),
            "username", jwt.getClaimAsString("preferred_username"),
            "email",    jwt.getClaimAsString("email")
        );
    }
}
