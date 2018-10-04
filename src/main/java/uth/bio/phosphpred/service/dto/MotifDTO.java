package uth.bio.phosphpred.service.dto;

/**
 * Created by panos on 26/7/2017.
 */
public class MotifDTO {
    String name;
    Integer locationFrom;
    Integer locationTo;
    Integer motifNo;
    String eValue;
    String annotation;


    public MotifDTO(String name, Integer locationFrom, Integer locationTo, Integer motifNo, String eValue, String annotation) {
        this.name = name;
        this.locationFrom = locationFrom;
        this.locationTo = locationTo;
        this.motifNo = motifNo;
        this.eValue = eValue;
        this.annotation = annotation;

    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getLocationFrom() {
        return locationFrom;
    }

    public void setLocationFrom(Integer locationFrom) {
        this.locationFrom = locationFrom;
    }

    public Integer getLocationTo() {
        return locationTo;
    }

    public void setLocationTo(Integer locationTo) {
        this.locationTo = locationTo;
    }

    public Integer getMotifNo() {
        return motifNo;
    }

    public void setMotifNo(Integer motifNo) {
        this.motifNo = motifNo;
    }

    public String geteValue() {
        return eValue;
    }

    public void seteValue(String eValue) {
        this.eValue = eValue;
    }

    public String getAnnotation() {
        return annotation;
    }

    public void setAnnotation(String annotation) {
        this.annotation = annotation;
    }

}
