package br.com.fiap.petcare.service;

import br.com.fiap.petcare.dto.PetRequest;
import br.com.fiap.petcare.dto.PetResponse;
import br.com.fiap.petcare.entity.Pet;
import br.com.fiap.petcare.entity.Tutor;
import br.com.fiap.petcare.exception.NotFoundException;
import br.com.fiap.petcare.repository.PetRepository;
import br.com.fiap.petcare.repository.TutorRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/** Regras de negocio dos pets atendidos pela clinica. */
@Service
public class PetService {

    private final PetRepository petRepository;
    private final TutorRepository tutorRepository;

    public PetService(PetRepository petRepository, TutorRepository tutorRepository) {
        this.petRepository = petRepository;
        this.tutorRepository = tutorRepository;
    }

    @Transactional(readOnly = true)
    public List<PetResponse> listar() {
        return petRepository.findAll().stream().map(PetResponse::de).toList();
    }

    @Transactional(readOnly = true)
    public List<PetResponse> listarPorTutor(Long tutorId) {
        if (!tutorRepository.existsById(tutorId)) {
            throw new NotFoundException("Nao existe tutor com o id " + tutorId + ".");
        }
        return petRepository.findByTutorId(tutorId).stream().map(PetResponse::de).toList();
    }

    @Transactional(readOnly = true)
    public PetResponse buscarPorId(Long id) {
        return PetResponse.de(carregar(id));
    }

    @Transactional
    public PetResponse cadastrar(PetRequest dados) {
        Pet pet = new Pet();
        aplicar(dados, pet);
        return PetResponse.de(petRepository.save(pet));
    }

    @Transactional
    public PetResponse atualizar(Long id, PetRequest dados) {
        Pet pet = carregar(id);
        aplicar(dados, pet);
        return PetResponse.de(petRepository.save(pet));
    }

    @Transactional
    public void remover(Long id) {
        petRepository.delete(carregar(id));
    }

    private Pet carregar(Long id) {
        return petRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Nao existe pet com o id " + id + "."));
    }

    private void aplicar(PetRequest dados, Pet pet) {
        Tutor tutor = tutorRepository.findById(dados.tutorId())
                .orElseThrow(() -> new NotFoundException(
                        "Nao existe tutor com o id " + dados.tutorId() + " para vincular ao pet."));

        pet.setNome(dados.nome());
        pet.setEspecie(dados.especie());
        pet.setRaca(dados.raca());
        pet.setPesoKg(dados.pesoKg());
        pet.setDataNascimento(dados.dataNascimento());
        pet.setCastrado(dados.castrado() != null ? dados.castrado() : Boolean.FALSE);
        pet.setTutor(tutor);
    }
}
