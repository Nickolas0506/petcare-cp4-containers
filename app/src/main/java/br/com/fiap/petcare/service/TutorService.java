package br.com.fiap.petcare.service;

import br.com.fiap.petcare.dto.TutorRequest;
import br.com.fiap.petcare.dto.TutorResponse;
import br.com.fiap.petcare.entity.Tutor;
import br.com.fiap.petcare.exception.BusinessException;
import br.com.fiap.petcare.exception.NotFoundException;
import br.com.fiap.petcare.repository.PetRepository;
import br.com.fiap.petcare.repository.TutorRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Concentra as regras de negocio de tutor. Os controllers ficam so com o HTTP.
 */
@Service
public class TutorService {

    private final TutorRepository tutorRepository;
    private final PetRepository petRepository;

    public TutorService(TutorRepository tutorRepository, PetRepository petRepository) {
        this.tutorRepository = tutorRepository;
        this.petRepository = petRepository;
    }

    @Transactional(readOnly = true)
    public List<TutorResponse> listar() {
        return tutorRepository.findAll().stream().map(TutorResponse::de).toList();
    }

    @Transactional(readOnly = true)
    public TutorResponse buscarPorId(Long id) {
        return TutorResponse.de(carregar(id));
    }

    @Transactional
    public TutorResponse cadastrar(TutorRequest dados) {
        if (tutorRepository.existsByDocumento(dados.documento())) {
            throw new BusinessException(
                    "O documento " + dados.documento() + " ja esta cadastrado para outro tutor.");
        }

        Tutor tutor = new Tutor();
        aplicar(dados, tutor);
        return TutorResponse.de(tutorRepository.save(tutor));
    }

    @Transactional
    public TutorResponse atualizar(Long id, TutorRequest dados) {
        Tutor tutor = carregar(id);

        tutorRepository.findByDocumento(dados.documento())
                .filter(outro -> !outro.getId().equals(id))
                .ifPresent(outro -> {
                    throw new BusinessException(
                            "O documento " + dados.documento() + " pertence ao tutor " + outro.getId() + ".");
                });

        aplicar(dados, tutor);
        return TutorResponse.de(tutorRepository.save(tutor));
    }

    @Transactional
    public void remover(Long id) {
        Tutor tutor = carregar(id);

        long pets = petRepository.countByTutorId(id);
        if (pets > 0) {
            throw new BusinessException(
                    "O tutor " + id + " possui " + pets + " pet(s) cadastrado(s). "
                    + "Remova os pets antes de excluir o tutor.");
        }

        tutorRepository.delete(tutor);
    }

    private Tutor carregar(Long id) {
        return tutorRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Nao existe tutor com o id " + id + "."));
    }

    private void aplicar(TutorRequest dados, Tutor tutor) {
        tutor.setNomeCompleto(dados.nomeCompleto());
        tutor.setDocumento(dados.documento());
        tutor.setEmail(dados.email());
        tutor.setCelular(dados.celular());
        tutor.setCidade(dados.cidade());
    }
}
