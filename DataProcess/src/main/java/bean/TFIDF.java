package bean;

import java.io.*;
import java.util.*;
import java.util.Map.Entry;

public class TFIDF {

    /**
     * 读入文档词袋模型
     *
     * @param filePath
     * @return
     */
    public static Map<String, tfidfDocument> readFille(String filePath) {
        Map<String, tfidfDocument> docs = new HashMap<String, tfidfDocument>();
        try {
            BufferedReader reader = new BufferedReader(new FileReader(new File(
                    filePath)));

            String line = null;
            int id = 0;

            while ((line = reader.readLine()) != null) {
                tfidfDocument doc = new tfidfDocument();
                // id ++;
                String docID = line.substring(0, line.indexOf(' '));
                // String docID = Integer.toString(id);
                line = line.substring(line.indexOf(' ') + 1);
                docs.put(docID, doc);

                Integer wordSize = Integer.parseInt(line.substring(0,
                                                                   line.indexOf(' ')));
                line = line.substring(line.indexOf(' ') + 1);
                doc.setRealSize(wordSize);

                Double polar = Double.parseDouble(line.substring(0,
                                                                 line.indexOf(' ')));
                line = line.substring(line.indexOf(' ') + 1);
                doc.setPolarity(polar);

                String uint = null;
                String[] split = line.split(" ");
                for (String te : split) {
                    String[] split1 = te.split(":");
                    if (split1.length != 2) {
//                        System.out.println(te);
                        continue;
                    }
                    tfidfWord word = new tfidfWord();
                    word.TF = Double.parseDouble(split1[1]);
                    doc.putKey(split1[0], word);
                }
//                while (line.length() > 2) {
//                    uint = line.substring(0, line.indexOf(' '));
//
//                    tfidfWord word = new tfidfWord();
//                    word.TF = Double.parseDouble(uint.substring(uint
//                            .lastIndexOf(':') + 1));
//                    doc.putKey(uint.substring(0, uint.indexOf(':')), word);
//
//                    line = line.substring(line.indexOf(' ') + 1);
//                }
            }
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return docs;
    }

    /**
     * 多文档生成字典
     *
     * @param filePaths
     * @return
     */
    public static Map<String, Integer> initDic(String[] filePaths) {
        Map<String, Integer> dic = new HashMap<String, Integer>();
        try {
            for (String filePath : filePaths) {
                System.out.println(filePath);
                BufferedReader reader = new BufferedReader(new FileReader(
                        new File(filePath)));

                String line = null;
                int id = 0;

                while ((line = reader.readLine()) != null) {
                    id++;
                    line = line.substring(line.indexOf(' ') + 1);
                    line = line.substring(line.indexOf(' ') + 1);
                    line = line.substring(line.indexOf(' ') + 1);
                    String[] split = line.split(" ");
                    for (String te : split) {
                        String[] split1 = te.split(":");
                        dic.put(split1[0], -1);
                    }
//                    while (line.length() > 2) {
//                        String word = line.substring(0, line.indexOf(':'));
//                        dic.put(word, -1);
//                        line = line.substring(line.indexOf(' ') + 1);
//                    }
                }
            }
            // 排序,赋予ID
            List<Entry<String, Integer>> list = new ArrayList<Map.Entry<String, Integer>>(
                    dic.entrySet());
            Collections.sort(list, dicKeyCmp);
            dic.clear();
            int id = 1;
            for (Entry<String, Integer> e : list) {
                dic.put(e.getKey(), id++);
            }
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return dic;
    }

    public static Map<String, Integer> DicWithWordCount(String[] filePaths) {
        Map<String, Integer> dic = new HashMap<String, Integer>();
        try {
            for (String filePath : filePaths) {
                System.out.println(filePath);
                BufferedReader reader = new BufferedReader(new FileReader(
                        new File(filePath)));

                String line = null;
                int id = 0;

                while ((line = reader.readLine()) != null) {
                    id++;
                    line = line.substring(line.indexOf(' ') + 1);
                    line = line.substring(line.indexOf(' ') + 1);
                    line = line.substring(line.indexOf(' ') + 1);
                    String[] split = line.split(" ");
                    for (String te : split) {
                        String[] split1 = te.split(":");
                        String t = split1[0].trim();
                        if (dic.containsKey(t)) {
                            dic.put(t, dic.get(t) + 1);
                        } else {
                            dic.put(t, 1);
                        }

                    }
                }
            }

        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return dic;
    }

    /**
     * 多文档生成字典
     *
     * @param filePaths
     * @return
     */
    public static Map<String, Integer> initDicWithoutStopWord(String[] filePaths, Set<String> stopwords) {
        Map<String, Integer> dic = new HashMap<String, Integer>();
        try {
            for (String filePath : filePaths) {
                System.out.println(filePath);
                BufferedReader reader = new BufferedReader(new FileReader(
                        new File(filePath)));

                String line = null;
                int id = 0;

                while ((line = reader.readLine()) != null) {
                    id++;
                    line = line.substring(line.indexOf(' ') + 1);
                    line = line.substring(line.indexOf(' ') + 1);
                    line = line.substring(line.indexOf(' ') + 1);
                    String[] split = line.split(" ");
                    for (String te : split) {
                        String[] split1 = te.split(":");
                        String t = split1[0].trim();
                        if (stopwords == null || !stopwords.contains(t)) {
                            dic.put(t, -1);
                        }
                    }
//                    while (line.length() > 2) {
//                        String word = line.substring(0, line.indexOf(':'));
//                        dic.put(word, -1);
//                        line = line.substring(line.indexOf(' ') + 1);
//                    }
                }
            }
            // 排序,赋予ID
            List<Entry<String, Integer>> list = new ArrayList<Map.Entry<String, Integer>>(
                    dic.entrySet());
            Collections.sort(list, dicKeyCmp);
            dic.clear();
            int id = 1;
            for (Entry<String, Integer> e : list) {
                dic.put(e.getKey(), id++);
            }
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return dic;
    }

    /**
     * 统计文档关键字的DF值
     *
     * @param docs
     * @return
     */
    private static Map<String, Integer> initDf(Map<String, tfidfDocument> docs) {
        Map<String, Integer> keys = new HashMap<String, Integer>();
        Iterator<String> docit = docs.keySet().iterator();
        // 遍历全部文档
        while (docit.hasNext()) {
            tfidfDocument doc = docs.get(docit.next());
            Iterator<String> keyIt = doc.keyMap.keySet().iterator();
            // 遍历文档关键字列表
            while (keyIt.hasNext()) {
                String key = keyIt.next();
                int DF = 1;
                if (keys.containsKey(key)) {
                    DF += keys.get(key);
                }
                keys.put(key, DF);
            }
        }

        return keys;
    }

    /**
     * 计算tfidf
     *
     * @param docs 带计算文档 提供tf
     * @param df 关键字df
     * @param dic 字典，提供id
     * @return
     */
    private static Map<String, tfidfDocument> CalTfidf(
            Map<String, tfidfDocument> docs, Map<String, Integer> keyDf,
            Map<String, Integer> dic) {
        Iterator<String> docit = docs.keySet().iterator();

        // 遍历文档
        while (docit.hasNext()) {
            tfidfDocument doc = docs.get(docit.next());

            Iterator<String> keyIt = doc.keyMap.keySet().iterator();
            // double norm = 0.0;//term frequency --norm
            // 遍历文本关键字
            while (keyIt.hasNext()) {
                String key = keyIt.next();
                if (!dic.containsKey(key)) {
                    continue;
                }

                tfidfWord word = doc.getKey(key);

                double tf = word.TF;
                double df = keyDf.get(key);
                // double tfidf = tf+1;//term frequency --norm
                // norm += tfidf*tfidf;//term frequency --norm
                // double tfidf = Math.log(tf+1)*Math.log(docs.size()/df);
//                double tfidf = Math.log(tf + 1) * Math.log(docs.size() / df)
//                        * SvmSCL.N;
                double tfidf = (tf + 1) * Math.log(docs.size() / df);
                // double tfidf = (tf+0.001)*(docs.size()/df);
                // if(tfidf != 0) tfidf = 1;

                if (tfidf <= 0.0000001) {
                    tfidf = 0.07;
                }
                word.TFIDF = tfidf;

                // if(df<2)
                // word.TFIDF = 0;
                word.ID = dic.get(key);

                doc.putKey(key, word);
            }
            // term frequency --norm
            // keyIt = doc.keyMap.keySet().iterator();
            // norm = Math.sqrt(norm);
            // while(keyIt.hasNext()){
            // String key = keyIt.next();
            // if(!dic.containsKey(key)){
            // continue;
            // }
            //
            // tfidfWord word = doc.getKey(key);
            //
            // double tf = word.TF;
            // double df = keyDf.get(key);
            // double tfidf = (tf+1)/norm;
            // word.TFIDF = tfidf;
            // word.ID = dic.get(key);
            // doc.putKey(key, word);
            // }//term frequency --norm
        }
        return docs;
    }

    /**
     * 将文档保存为SVM的训练格式
     *
     * @param filePath
     * @param docMap
     * @throws Exception
     */
    public static void saveDocsAsSVM(String filePath,
                                     Map<String, tfidfDocument> docMap, Map<String, Integer> dic)
            throws Exception {
        System.out.println("|\t|\n" + filePath + "SVM模型开始写入...");
        FileWriter out = new FileWriter(filePath);
        docMap = CalTfidf(docMap, initDf(docMap), dic);
        // 按照文档的ID排序
        List<Entry<String, tfidfDocument>> doclist = new ArrayList<Map.Entry<String, tfidfDocument>>(
                docMap.entrySet());
        // 按照文档编号排序
        Collections.sort(doclist, docIDCmp);
        for (Entry<String, tfidfDocument> e : doclist) {
            String info = e.getValue().polarity + " ";
            // 文档关键字排序
            List<Entry<String, tfidfWord>> keyList = new ArrayList<Entry<String, tfidfWord>>(
                    e.getValue().keyMap.entrySet());
            Collections.sort(keyList, docKeyCmp);

            for (Entry<String, tfidfWord> e1 : keyList) {
                if (dic.containsKey(e1.getKey())) {
                    info += e1.getValue().ID + ":" + e1.getValue().TFIDF + " ";
                }
            }
            out.write(info + "\n");
        }
        out.flush();
        out.close();
        System.out.println("|\t|\n共输出文档 " + docMap.size() + " 条");
    }

    /**
     * 将文档保存为SVM的训练格式
     *
     * @param docMap
     * @throws Exception
     */
    public static int[] saveDocsAsTFIDFFOR_NMTF(String tfidfPath, String labelPath,
                                                Map<String, tfidfDocument> docMap, Map<String, Integer> dic)
            throws Exception {
        int maxWordId = 0;
        int maxDocId = 0;
        System.out.println("|\t|\n" + tfidfPath + "TFIDF模型开始写入...");
        FileWriter out = new FileWriter(tfidfPath);
        FileWriter lableout = new FileWriter(labelPath);
        docMap = CalTfidf(docMap, initDf(docMap), dic);
        // 按照文档的ID排序
        List<Entry<String, tfidfDocument>> doclist = new ArrayList<Map.Entry<String, tfidfDocument>>(
                docMap.entrySet());
        // 按照文档编号排序
        Collections.sort(doclist, docIDCmp);
        Integer docID = 1;
        for (Entry<String, tfidfDocument> e : doclist) {

            String info = "";
            if (e.getValue().polarity == -1.0) {
                info = "1";
            } else if (e.getValue().polarity == 1.0) {
                info = "2";
            } else {
                System.err.println("error " + e.getValue().polarity);
            }

            // 文档关键字排序
            List<Entry<String, tfidfWord>> keyList = new ArrayList<Entry<String, tfidfWord>>(
                    e.getValue().keyMap.entrySet());
            Collections.sort(keyList, docKeyCmp);
            String docContext = "";

            for (Entry<String, tfidfWord> e1 : keyList) {
                if (dic.containsKey(e1.getKey())) {
                    docContext += e1.getValue().ID + "," + docID + "," + e1.getValue().TFIDF + "\n";
                    maxWordId = Math.max(e1.getValue().ID, maxWordId);
                }
            }
            maxDocId = docID;
            out.write(docContext);
            lableout.write(info + "\n");
            docID++;
        }
        out.flush();
        out.close();
        lableout.flush();
        lableout.close();

        System.out.println("|\t|\n共输出文档 " + docMap.size() + " 条");
        return new int[]{maxWordId, maxDocId};
    }

    // 字典关键字排序器
    private static Comparator<Entry<String, Integer>> dicKeyCmp = new Comparator<Map.Entry<String, Integer>>() {
        public int compare(Entry<String, Integer> o1, Entry<String, Integer> o2) {
            return o1.getKey().compareTo(o2.getKey());
        }
    };
    // 文档按ID排序器
    private static Comparator<Entry<String, tfidfDocument>> docIDCmp = new Comparator<Entry<String, tfidfDocument>>() {
        public int compare(Entry<String, tfidfDocument> o1,
                           Entry<String, tfidfDocument> o2) {
            // TODO Auto-generated method stu
            Integer a = new Integer(o1.getKey());
            Integer b = new Integer(o2.getKey());

            return a.compareTo(b);
        }
    };
    // 文档关键字按ID排序器
    private static Comparator<Entry<String, tfidfWord>> docKeyCmp = new Comparator<Entry<String, tfidfWord>>() {
        public int compare(Entry<String, tfidfWord> o1,
                           Entry<String, tfidfWord> o2) {
            // TODO Auto-generated method stub
            Integer a = new Integer(o1.getValue().ID);
            Integer b = new Integer(o2.getValue().ID);

            return a.compareTo(b);
        }
    };

    private static class U1 {

        private String ID;
        private double value;
        private double polar;

        public U1() {
            this.ID = "";
            this.value = 0.0;
            this.polar = 0.0;
        }

        public U1(String iD, double polar, double value) {
            super();
            ID = iD;
            this.value = value;
            this.polar = polar;
        }

        public int compareTo(U1 u) {
            if (this.value > u.value) {
                return -1;
            } else if (this.value < u.value) {
                return 1;
            } else {
                return 0;
            }
        }

        public String getID() {
            return this.ID;
        }

        @Override
        public String toString() {
            return "U1{"
                   + "ID='" + ID + '\''
                   + ", value=" + value
                   + ", polar=" + polar
                   + '}';
        }
    }
}
