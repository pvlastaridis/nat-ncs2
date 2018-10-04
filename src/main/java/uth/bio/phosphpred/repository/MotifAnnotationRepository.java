package uth.bio.phosphpred.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import uth.bio.phosphpred.domain.MotifAnnotation;

import java.util.Optional;

/**
 * Spring Data JPA repository for the Motif Annotation entity.
 */
@Repository
public interface MotifAnnotationRepository extends JpaRepository<MotifAnnotation, Long> {

    Optional<MotifAnnotation> findOneByName(String name);

}
