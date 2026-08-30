package br.com.fiap.petcare.dto;

import br.com.fiap.petcare.entity.Tutor;
import java.time.LocalDate;

/** Representacao de um tutor devolvida pela API. */
public record TutorResponse(
        Long id,
        String nomeCompleto,
        String documento,
        String email,
        String celular,
        String cidade,
        LocalDate dataCadastro,
        int quantidadePets
) {
    public static TutorResponse de(Tutor tutor) {
        return new TutorResponse(
                tutor.getId(),
                tutor.getNomeCompleto(),
                tutor.getDocumento(),
                tutor.getEmail(),
                tutor.getCelular(),
                tutor.getCidade(),
                tutor.getDataCadastro(),
                tutor.getPets() == null ? 0 : tutor.getPets().size()
        );
    }
}
