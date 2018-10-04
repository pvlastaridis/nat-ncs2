package uth.bio.phosphpred.service.dto;

/**
 * Created by Panos on 13-Jun-17.
 */

import java.io.Serializable;

/**
 * Created by Panos on 07-Dec-15.
 */
public class SeqrDTO implements Serializable {

    String protein;
    int position;
    String motif;
    float score1;
    float score2;
    float threshold;

    public String getProtein() {
        return protein;
    }

    public void setProtein(String protein) {
        this.protein = protein;
    }

    public int getPosition() {
        return position;
    }

    public void setPosition(int position) {
        this.position = position;
    }

    public String getMotif() {
        return motif;
    }

    public void setMotif(String motif) {
        this.motif = motif;
    }

    public float getScore1() {
        return score1;
    }

    public void setScore1(float score1) {
        this.score1 = score1;
    }

    public float getScore2() {
        return score2;
    }

    public void setScore2(float score2) {
        this.score2 = score2;
    }

    public float getThreshold() {
        return threshold;
    }

    public void setThreshold(float threshold) {
        this.threshold = threshold;
    }
}
