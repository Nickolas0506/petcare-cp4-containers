package br.com.fiap.petcare.repository;

import br.com.fiap.petcare.entity.Tutor;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface TutorRepository extends JpaRepository<Tutor, Long> {

    Optional<Tutor> findByDocumento(String documento);

    boolean existsByDocumento(String documento);
}
