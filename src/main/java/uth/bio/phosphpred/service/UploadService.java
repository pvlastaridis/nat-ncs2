package uth.bio.phosphpred.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import uth.bio.phosphpred.service.dto.UploadDTO;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Map;

/**
 * Service Implementation for managing UploadDTO.
 */
@Service
@Transactional
public class UploadService {

    private final Logger log = LoggerFactory.getLogger(UploadService.class);

    private final Environment env;

    public UploadService(Environment env) {
        this.env = env;
    }

    /**
     * Save a upload.
     *
     * @param uploadDTO the entity to save
     * @return the persisted entity
     */
    public boolean save(UploadDTO uploadDTO) {
        log.debug("Request to save UploadDTO : {}", uploadDTO);
        try {
            FileOutputStream fos;

            if (uploadDTO.getFasta_file()!=null) {
                fos = new FileOutputStream(env.getProperty("files-directory") + "/hmmrUploads/" + uploadDTO.getId()
                    + ".fasta");
                fos.write(uploadDTO.getFasta_file());
            } else {
                fos = new FileOutputStream(env.getProperty("files-directory") + "/hmmrUploads/" + uploadDTO.getId()
                    + "_p.fasta");
                fos.write(uploadDTO.getFasta_text().getBytes(StandardCharsets.UTF_8));
            }
            fos.close();
        } catch (IOException e){
            log.error(e.getMessage());
            return false;
        }

        return true;
    }

    /**
     *  Get one upload by id.
     *
     *  @param id the id of the entity
     *  @return the entity
     */
    @Transactional(readOnly = true)
    public UploadDTO findOne(Long id) {
        log.debug("Request to get UploadDTO : {}", id);
        UploadDTO uploadDTO = new UploadDTO();
        return uploadDTO;
    }

    @Scheduled(fixedRate = 5000)
    public void checkForUploads() {

        File uploadFolder = new File(env.getProperty("files-directory") + "/hmmrUploads/");

        String resultsFolder = env.getProperty("files-directory") + "/hmmrResults/";

        if (uploadFolder.isDirectory()) {

            ArrayList<File> fileList = new ArrayList<File>(Arrays.asList(uploadFolder.listFiles()));
            if (!fileList.isEmpty() && fileList.get(0).isFile()) {

                File file = getLastModified(uploadFolder);
                boolean p = false;
                String ext = ".fasta";
                if (file.getName().contains("_p")) p = true;
                String folderName = resultsFolder + "/" + file.getName().replace("_p","")
                    .substring(0,file.getName().replace("_p","").length() - ext.length());
                new File(folderName).mkdir();
                String filename = file.getName().replace("_p", "");
                file.renameTo(new File(folderName + "/" + filename));

                try {
                    copyFileUsingFileStreams(new File(env.getProperty("files-directory") + "/SERVER_NCS2.pl"), new File(folderName+"/SERVER_NCS2.pl"));
                    ProcessBuilder pb = new ProcessBuilder("perl", "SERVER_NCS2.pl", "-f", filename);
                    Map<String, String> env = pb.environment();
                    env.put("hmmscan", "/usr/bin/hmmscan");
                    if (p) {
                        pb = new ProcessBuilder("perl", "SERVER_NCS2.pl", "-p", filename);
                    }
                    pb.directory(new File(folderName));
                    File loggy = new File(folderName + "/pblog");
                    pb.redirectErrorStream(true);
                    pb.redirectOutput(ProcessBuilder.Redirect.appendTo(loggy));
                    Process pr = pb.start();
                    assert pr.getInputStream().read() == -1;
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public static File getLastModified(File directory) {
        File[] files = directory.listFiles();
        if (files.length == 0) return null;
        Arrays.sort(files, new Comparator<File>() {
            public int compare(File o1, File o2) {
                return new Long(o2.lastModified()).compareTo(o1.lastModified()); //latest 1st
            }});
        return files[0];
    }

    public static void copyFileUsingFileStreams(File source, File dest)
        throws IOException {
        InputStream input = null;
        OutputStream output = null;
        try {
            input = new FileInputStream(source);
            output = new FileOutputStream(dest);
            byte[] buf = new byte[1024];
            int bytesRead;
            while ((bytesRead = input.read(buf)) > 0) {
                output.write(buf, 0, bytesRead);
            }
        } finally {
            input.close();
            output.close();
        }
    }
}
