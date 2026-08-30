package br.com.fiap.petcare.dto;

import br.com.fiap.petcare.entity.Especie;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;

/** Dados aceitos na criacao e atualizacao de um pet. */
public record PetRequest(

        @NotBlank(message = "o nome do pet e obrigatorio")
        @Size(max = 60)
        String nome,

        @NotNull(message = "a especie e obrigatoria (CACHORRO, GATO, AVE, ROEDOR ou REPTIL)")
        Especie especie,

        @Size(max = 60)
        String raca,

        @DecimalMin(value = "0.1", message = "o peso deve ser maior que zero")
        @Digits(integer = 3, fraction = 2, message = "peso invalido")
        BigDecimal pesoKg,

        @PastOrPresent(message = "a data de nascimento nao pode estar no futuro")
        LocalDate dataNascimento,

        Boolean castrado,

        @NotNull(message = "informe o tutorId do dono do pet")
        Long tutorId
) {}
