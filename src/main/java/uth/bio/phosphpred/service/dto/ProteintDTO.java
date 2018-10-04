package uth.bio.phosphpred.service.dto;

import java.util.ArrayList;

/**
 * Created by panos on 26/7/2017.
 */
public class ProteintDTO {

    String name;
    String domain;
    String domainScore;
    String seq;
    String substrates;
    ArrayList<MotifDTO> motifs = new ArrayList<>();

    public ProteintDTO(String name, String domain, String domainScore, String seq, ArrayList<MotifDTO> motifs) {
        this.name = name;
        this.domain = domain;
        this.domainScore = domainScore;
        this.substrates = "-";
        if (domain.contains("NCS2_SF1_C2-Uracil")) this.substrates = "The well characterized homologs of this cluster are bacterial proton-pyrimidine symporters specific for uracil (UraA, AvDDG3, AcS572) or uracil/thymine (RutG).";
        if (domain.contains("NCS2_SF1_C1-Xanthine-UricAcid")) this.substrates = "The well characterized homologs of this cluster are bacterial proton-purine symporters specific for xanthine (XanQ, XanP) or uric acid (UacT) and fungal proton-purine symporters specific for both xanthine and uric acid (UapA, UapC, AfUapC, Xut1).";
        if (domain.contains("NCS2_SF1_C4-Arc-Bac-Euk")) this.substrates = "The well characterized homologs of this cluster are mammalian sodium-solute symporters specific for uracil/thymine/hypoxanthine/guanine (rSNBT1) or for L-ascorbic acid (hSVCT1, hSVCT2) and plant transporters specific for uracil/adenine/guanine (AtNAT3, AtNAT12) or xanthine/uric acid (Lpe1).";
        if (domain.contains("NCS2_SF2")) this.substrates = "The well characterized homologs of this subfamily are bacterial proton-purine symporters specific for adenine (AdeP, AdeQ) or guanine/hypoxanthine (GhxP, GhxQ) or both adenine and guanine/hypoxanthine (BB_B22, BB_B23) and eukaryotic proton-purine symporters specific for adenine/guanine (AtAzg1, AtAzg2) or adenine/guanine/hypoxanthine (AzgA, AfAzgA).";
        this.seq = seq;
        if (motifs!=null) this.motifs = motifs;

    }

    public String getName() {
        return name;
    }

    public String getDomain() {
        return domain;
    }

    public String getDomainScore() {
        return domainScore;
    }

    public String getSeq() {
        return seq;
    }

    public ArrayList<MotifDTO> getMotifs() {
        return motifs;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setDomain(String domain) {
        this.domain = domain;
    }

    public void setDomainScore(String domainScore) {
        this.domainScore = domainScore;
    }

    public void setSeq(String seq) {
        this.seq = seq;
    }

    public void setMotifs(ArrayList<MotifDTO> motifs) {
        this.motifs = motifs;
    }

    public String getSubstrates() {
        return substrates;
    }

    public void setSubstrates(String substrates) {
        this.substrates = substrates;
    }
}
