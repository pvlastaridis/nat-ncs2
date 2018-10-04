package uth.bio.phosphpred.service.dto;

import java.io.Serializable;
import java.util.Objects;

/**
 * A DTO for the Upload entity.
 */
public class UploadDTO implements Serializable {

    private String id;
    private Boolean uploadType;
    private String fasta_text;
    private byte[] fasta_file;
    private String fasta_fileContentType;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getFasta_text() {
        return fasta_text;
    }

    public void setFasta_text(String fasta_text) {
        this.fasta_text = fasta_text;
    }

    public byte[] getFasta_file() {
        return fasta_file;
    }

    public void setFasta_file(byte[] fasta_file) {
        this.fasta_file = fasta_file;
    }

    public String getFasta_fileContentType() {
        return fasta_fileContentType;
    }

    public void setFasta_fileContentType(String fasta_fileContentType) {
        this.fasta_fileContentType = fasta_fileContentType;
    }

    public Boolean getUploadType() {
        return uploadType;
    }

    public void setUploadType(Boolean uploadType) {
        this.uploadType = uploadType;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        UploadDTO uploadDTO = (UploadDTO) o;
        if(uploadDTO.getId() == null || getId() == null) {
            return false;
        }
        return Objects.equals(getId(), uploadDTO.getId());
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(getId());
    }

    @Override
    public String toString() {
        return "UploadDTO{" +
            "id=" + getId() +
            "}";
    }
}
