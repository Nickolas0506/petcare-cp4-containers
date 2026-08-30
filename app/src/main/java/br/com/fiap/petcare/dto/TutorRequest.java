package br.com.fiap.petcare.dto;

import jakarta.validation.constraints.*;

/** Dados aceitos na criacao e atualizacao de um tutor. */
public record TutorRequest(

        @NotBlank(message = "o nome do tutor e obrigatorio")
        @Size(max = 120, message = "o nome deve ter no maximo 120 caracteres")
        String nomeCompleto,

        @NotBlank(message = "o documento (CPF) e obrigatorio")
        @Pattern(regexp = "\\d{11}", message = "o documento deve ter exatamente 11 digitos")
        String documento,

        @NotBlank(message = "o e-mail e obrigatorio")
        @Email(message = "e-mail invalido")
        @Size(max = 150)
        String email,

        @Size(max = 15, message = "o celular deve ter no maximo 15 caracteres")
        String celular,

        @Size(max = 80)
        String cidade
) {}
