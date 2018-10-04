package uth.bio.phosphpred.web.rest;

import com.codahale.metrics.annotation.Timed;
import io.swagger.annotations.ApiParam;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.actuate.audit.AuditEvent;
import org.springframework.core.env.Environment;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import uth.bio.phosphpred.config.AuditEventPublisher;
import uth.bio.phosphpred.domain.MotifAnnotation;
import uth.bio.phosphpred.repository.MotifAnnotationRepository;
import uth.bio.phosphpred.service.UploadService;
import uth.bio.phosphpred.service.dto.MotifDTO;
import uth.bio.phosphpred.service.dto.ProteintDTO;
import uth.bio.phosphpred.service.dto.SeqrDTO;
import uth.bio.phosphpred.service.dto.UploadDTO;
import uth.bio.phosphpred.web.rest.errors.StorageFileNotFoundException;
import uth.bio.phosphpred.web.rest.util.HeaderUtil;

import javax.validation.Valid;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Optional;
import java.util.Scanner;

/**
 * REST controller for managing UploadDTO.
 */
@RestController
@RequestMapping("/apins")
public class UploadResource {

    private final Logger log = LoggerFactory.getLogger(UploadResource.class);

    private static final String ENTITY_NAME = "upload";

    private final UploadService uploadService;

    private final MotifAnnotationRepository motifAnnotationRepository;

    private final Environment env;

    private final Path rootLocation;

    private final AuditEventPublisher auditEventPublisher;

    public UploadResource(UploadService uploadService, Environment env, AuditEventPublisher auditEventPublisher,
                          MotifAnnotationRepository motifAnnotationRepository) {
        this.uploadService = uploadService;
        this.env = env;
        this.rootLocation = Paths.get(env.getProperty("files-directory") + "/results/");
        this.auditEventPublisher = auditEventPublisher;
        this.motifAnnotationRepository  = motifAnnotationRepository;
    }

    /**
     * POST  /uploads : Receive a new upload.
     *
     * @param upload the upload to create
     * @return the ResponseEntity with status 201 (Created) and with body the new upload, or with status 400 (Bad Request) if the upload has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/uploads")
    @Timed
    public ResponseEntity<UploadDTO> createUpload(@Valid @RequestBody UploadDTO upload) throws URISyntaxException {
        log.debug("REST request to upload Fasta: {}", upload);
        if (!uploadService.save(upload)) {
            return ResponseEntity.badRequest().headers(HeaderUtil.createFailureAlert(ENTITY_NAME, "idexists", "File could not be written to the server, please try again later")).body(null);
        }
        HashMap<String, Object> map = new HashMap<>();
        map.put("Upload_id", upload.getId().toString());
        AuditEvent event = new AuditEvent("ANONYMOUS", "REQUEST_TO_UPLOAD", map);
        auditEventPublisher.publish(event);
        return ResponseEntity.created(new URI("/api/uploads/" + 1L))
            .headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, "1"))
            .body(upload);
    }


    /**
     * GET  /uploads/:id : get the "id" upload.
     *
     * @param id the id of the upload to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the upload, or with status 404 (Not Found)
     */
    @GetMapping("/uploads/{id}")
    @Timed
    public ResponseEntity<?> getUpload(@PathVariable String id) {

        log.debug("Request to get Hmmr Results for id : {}", id);

        File process = new File(env.getProperty("files-directory") + "/hmmrUploads/" + id + ".fasta");
        File process2 = new File(env.getProperty("files-directory") + "/hmmrUploads/" + id + "_p.fasta");
        File folder = new File(env.getProperty("files-directory") + "/hmmrResults/"  + id );
        File fasta = new File(env.getProperty("files-directory") + "/hmmrResults/"  + id + "/" + id + ".fasta");
        File pblog = new File(env.getProperty("files-directory") + "/hmmrResults/"  + id + "/pblog");
        File general_output = new File(env.getProperty("files-directory") + "/hmmrResults/" + id + "/1_GENERAL_REPORT.txt");
        File meme_report = new File(env.getProperty("files-directory") + "/hmmrResults/" + id + "/2_MEME_REPORT.txt");
        File report_finished = new File(env.getProperty("files-directory") + "/hmmrResults/" + id + "/REPORT FINISHED.txt");
        File tsv = new File(env.getProperty("files-directory") + "/results/" + id + ".tsv");

        if (process.exists() || process2.exists()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).headers(HeaderUtil.createFailureAlert(
                ENTITY_NAME, "inqueue", "The uploaded file is still in queue")).body(null);
        }

        if (fasta.exists() && !report_finished.exists() && pblog.exists() && pblog.length() == 0) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).headers(HeaderUtil.createFailureAlert(
                ENTITY_NAME, "processing", "The uploaded file is being processed")).body(null);
        }

        if (!process.exists() && !process2.exists() && !folder.exists()) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).headers(HeaderUtil.createFailureAlert(
                ENTITY_NAME, "no_results", "No Results Found")).body(null);
        }

        if (report_finished.exists()) {

            ArrayList<ProteintDTO> listSEQR = new ArrayList<>();
            try {
                Scanner report = new Scanner(report_finished);
                String rep = report.nextLine();
                String[] strarr = rep.split("\t");
                log.debug(strarr[0]);
                if (! strarr[0].equalsIgnoreCase("FINISHED OK")) {
                    if (strarr[0].equalsIgnoreCase("NO RESULTS FOUND")) {
                        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).headers(HeaderUtil.createFailureAlert(
                            ENTITY_NAME, "no_results", "No Results Found")).body(null);
                    } else {
                        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).headers(HeaderUtil.createFailureAlert(
                            ENTITY_NAME, "analysis_failed", "Unknown error")).body(null);
                    }
                }
                report.close();
                HashMap<String, ArrayList<MotifDTO>> motifMap = new HashMap<>();
                Scanner memes = new Scanner(meme_report);
                while (memes.hasNextLine()) {
                    String[] arr = memes.nextLine().split("\t");
                    String annot = "";
                    if (motifAnnotationRepository.findOneByName(arr[1]).isPresent()) annot = motifAnnotationRepository.findOneByName(arr[1]).get().getAnnotation();
                    MotifDTO mo = new MotifDTO(arr[1], Integer.parseInt(arr[4]), Integer.parseInt(arr[5]), Integer.parseInt(arr[2]), arr[3], annot);
                    if (motifMap.containsKey(arr[0])) {
                        motifMap.get(arr[0]).add(mo);
                    } else {
                        ArrayList<MotifDTO> ar = new ArrayList<>();
                        ar.add(mo);
                        motifMap.put(arr[0], ar);
                    }
                }
                memes.close();
                Scanner peps = new Scanner(general_output);
                while (peps.hasNextLine()) {
                    //A8I507	9E-10	NCS2_SF1_C5	MRKPQNLVYGVDDLPPAR
                    String[] strar = peps.nextLine().split("\t");
                    ProteintDTO pep = new ProteintDTO(strar[0], strar[2], strar[1], strar[3], motifMap.get(strar[0]));
                    listSEQR.add(pep);

                }
                peps.close();
                if (!tsv.exists()) {
                    PrintWriter wr = new PrintWriter(new File(env.getProperty("files-directory") + "/results/" + id + ".tsv"));
                    wr.write( "Protein Name\tDomain Name\tDomain score\tMotif Name\tMotifNo\tMotif E-Value\tMotif Location From\tMotif Location To\n");
                    for (ProteintDTO pep: listSEQR) {
                        if (!pep.getMotifs().isEmpty()) {
                        for (MotifDTO mot: pep.getMotifs()) wr.write( pep.getName() + "\t" + pep.getDomain() + "\t" + pep.getDomainScore()
                            + "\t" + mot.getName() + "\t" + mot.getMotifNo() + "\t" + mot.geteValue() + "\t" + mot.getLocationFrom()
                            + "\t" + mot.getLocationTo() + "\n");
                        }
                    }
                    wr.close();
                }
            } catch (FileNotFoundException e) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).headers(HeaderUtil.createFailureAlert(
                    ENTITY_NAME, "analysis_failed", "Some of the results files are missing")).body(null);
            }
            return new ResponseEntity<>(listSEQR, HttpStatus.OK);
        }
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).headers(HeaderUtil.createFailureAlert(
            ENTITY_NAME, "shit_happens", "Unknown error")).body(null);
    }

    @GetMapping("/files/{token:.+}")
    @ResponseBody
    public ResponseEntity<Resource> serveFile(@PathVariable String token) {
        Resource file = null;
        file = loadAsResource(token + ".tsv");
        return ResponseEntity
            .ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + token + ".tsv" + "\"")
            .body(file);
    }

    public Resource loadAsResource(String filename) {
        try {

            Path file = load(filename);
            Resource resource = new UrlResource(file.toUri());
            if(resource.exists() || resource.isReadable()) {
                return resource;
            }
            else {
                throw new StorageFileNotFoundException("Could not read file: " + filename);

            }
        } catch (MalformedURLException e) {
            throw new StorageFileNotFoundException("Could not read file: " + filename, e);
        }
    }

    public Path load(String filename) {
        return rootLocation.resolve(filename);
    }
}
