package br.com.fiap.petcare.controller;

import br.com.fiap.petcare.dto.PetRequest;
import br.com.fiap.petcare.dto.PetResponse;
import br.com.fiap.petcare.service.PetService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/pets")
public class PetController {

    private final PetService petService;

    public PetController(PetService petService) {
        this.petService = petService;
    }

    @GetMapping
    public List<PetResponse> listar() {
        return petService.listar();
    }

    @GetMapping("/{id}")
    public PetResponse buscar(@PathVariable Long id) {
        return petService.buscarPorId(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PetResponse cadastrar(@Valid @RequestBody PetRequest dados) {
        return petService.cadastrar(dados);
    }

    @PutMapping("/{id}")
    public PetResponse atualizar(@PathVariable Long id, @Valid @RequestBody PetRequest dados) {
        return petService.atualizar(id, dados);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> remover(@PathVariable Long id) {
        petService.remover(id);
        return ResponseEntity.noContent().build();
    }
}
