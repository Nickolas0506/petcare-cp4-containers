package br.com.fiap.petcare.repository;

import br.com.fiap.petcare.entity.Pet;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PetRepository extends JpaRepository<Pet, Long> {

    List<Pet> findByTutorId(Long tutorId);

    long countByTutorId(Long tutorId);
}
