package br.com.fiap.petcare.controller;

import br.com.fiap.petcare.dto.PetResponse;
import br.com.fiap.petcare.dto.TutorRequest;
import br.com.fiap.petcare.dto.TutorResponse;
import br.com.fiap.petcare.service.PetService;
import br.com.fiap.petcare.service.TutorService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/tutores")
public class TutorController {

    private final TutorService tutorService;
    private final PetService petService;

    public TutorController(TutorService tutorService, PetService petService) {
        this.tutorService = tutorService;
        this.petService = petService;
    }

    @GetMapping
    public List<TutorResponse> listar() {
        return tutorService.listar();
    }

    @GetMapping("/{id}")
    public TutorResponse buscar(@PathVariable Long id) {
        return tutorService.buscarPorId(id);
    }

    /** Pets de um tutor especifico - evidencia do relacionamento 1:N. */
    @GetMapping("/{id}/pets")
    public List<PetResponse> petsDoTutor(@PathVariable Long id) {
        return petService.listarPorTutor(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public TutorResponse cadastrar(@Valid @RequestBody TutorRequest dados) {
        return tutorService.cadastrar(dados);
    }

    @PutMapping("/{id}")
    public TutorResponse atualizar(@PathVariable Long id, @Valid @RequestBody TutorRequest dados) {
        return tutorService.atualizar(id, dados);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> remover(@PathVariable Long id) {
        tutorService.remover(id);
        return ResponseEntity.noContent().build();
    }
}
