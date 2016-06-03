package bean;

import java.util.HashMap;
import java.util.Map;

public class tfidfDocument {

    public Integer realSize;
    public Double polarity;
    public Map<String, tfidfWord> keyMap;

    public tfidfDocument(Integer realSize, Double polarity,
                         Map<String, tfidfWord> keyMap) {
        super();
        this.realSize = realSize;
        this.polarity = polarity;
        this.keyMap = keyMap;
    }

    public tfidfDocument() {
        this.realSize = 0;
        this.polarity = 0.0;
        this.keyMap = new HashMap<String, tfidfWord>();
    }

    /**
     * 解析文档Text时，使用此putKey函数
     * <br/>此函数会自动统计关键字出现的次数并将其保存为关键字的TF值
     *
     * @param key 关键字
     */
    public void putKey(String key) {
        tfidfWord wordInfo = null;
        if (keyMap.containsKey(key)) {
            wordInfo = keyMap.remove(key);
        } else {
            wordInfo = new tfidfWord();
        }
        wordInfo.TF++;
        keyMap.put(key, wordInfo);
    }

    /**
     * 放入一个关键字
     *
     * @param key
     * @param wordInfo
     */
    public void putKey(String key, tfidfWord wordInfo) {
        keyMap.put(key, wordInfo);
    }

    /**
     * 获取某个关键字
     *
     * @param key
     * @return
     */
    public tfidfWord getKey(String key) {
        return keyMap.get(key);
    }

    /**
     * 移除某个关键字
     *
     * @param key
     */
    public void removeKey(String key) {
        keyMap.remove(key);
    }

    /**
     * 是否包含关键字
     *
     * @param key
     * @return
     */
    public boolean containsKey(String key) {
        return keyMap.containsKey(key);
    }

    public int getMapSize() {
        return keyMap.size();
    }

    public void setRealSize(int realSize) {
        this.realSize = realSize;
    }

    public void setKeyMap(Map<String, tfidfWord> keyMap) {
        this.keyMap = keyMap;
    }

    public void setPolarity(Double polarity) {
        this.polarity = polarity;
    }
}
