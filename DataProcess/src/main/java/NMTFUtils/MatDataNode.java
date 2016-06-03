package NMTFUtils;

/**
 * 用于表示添加词或者删减词，保持matlab代码的对齐 Created by zwj on 2016/5/11.
 */
public class MatDataNode {

    int wordId;
    int docId;
    double tfidf;

    public MatDataNode(int wordId, int docId, double tfidf) {
        this.wordId = wordId;
        this.docId = docId;
        this.tfidf = tfidf;
    }
}
