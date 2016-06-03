package bean;

/**
 * 文档中关键字信息单元 包含TF值和IDF值
 *
 * @author wxg
 */
public class tfidfWord {

    public double TF;
    public double DF;
    public double TFIDF;
    public int ID;

    public tfidfWord() {
        TF = 0.0;
        DF = 0.0;
        TFIDF = 0.0;
        ID = -1;
    }

    public tfidfWord(int iD, double tF, double dF, double tFIDF) {
        TF = tF;
        DF = dF;
        TFIDF = tFIDF;
        ID = iD;
    }
}
