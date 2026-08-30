package br.com.fiap.petcare.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

/** Endpoint de apresentacao da API, util para mostrar no video. */
@RestController
public class InfoController {

    @Value("${spring.application.name:petcare}")
    private String aplicacao;

    @GetMapping("/info")
    public Map<String, Object> info() {
        Map<String, String> rotas = new LinkedHashMap<>();
        rotas.put("tutores", "/api/v1/tutores");
        rotas.put("pets", "/api/v1/pets");
        rotas.put("petsDoTutor", "/api/v1/tutores/{id}/pets");
        rotas.put("painel", "/");
        rotas.put("saude", "/actuator/health");

        Map<String, Object> corpo = new LinkedHashMap<>();
        corpo.put("aplicacao", aplicacao);
        corpo.put("descricao", "PetCare - clinica veterinaria | CP4 Imagem e Containers em Nuvem (ACR/ACI)");
        corpo.put("status", "online");
        corpo.put("rotas", rotas);
        return corpo;
    }
}
