package br.com.fiap.petcare.dto;

import br.com.fiap.petcare.entity.Especie;
import br.com.fiap.petcare.entity.Pet;
import java.math.BigDecimal;
import java.time.LocalDate;

/** Representacao de um pet devolvida pela API. */
public record PetResponse(
        Long id,
        String nome,
        Especie especie,
        String raca,
        BigDecimal pesoKg,
        LocalDate dataNascimento,
        Boolean castrado,
        Long tutorId,
        String tutorNome
) {
    public static PetResponse de(Pet pet) {
        return new PetResponse(
                pet.getId(),
                pet.getNome(),
                pet.getEspecie(),
                pet.getRaca(),
                pet.getPesoKg(),
                pet.getDataNascimento(),
                pet.getCastrado(),
                pet.getTutor().getId(),
                pet.getTutor().getNomeCompleto()
        );
    }
}
