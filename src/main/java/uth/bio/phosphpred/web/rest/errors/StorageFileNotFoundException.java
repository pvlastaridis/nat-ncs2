package uth.bio.phosphpred.web.rest.errors;

/**
 * Created by panos on 1/8/2017.
 */
public class StorageFileNotFoundException extends RuntimeException {

    public StorageFileNotFoundException(String message) {
        super(message);
    }

    public StorageFileNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }
}
