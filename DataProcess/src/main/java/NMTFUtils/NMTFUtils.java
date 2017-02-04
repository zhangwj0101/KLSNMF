package NMTFUtils;

import bean.tfidfDocument;
import bean.TFIDF;
import de.bwaldvogel.liblinear.Predict;
import de.bwaldvogel.liblinear.Train;
import org.apache.commons.io.FileUtils;

import java.io.*;
import java.util.*;

/**
 * Created by zwj on 2016/4/21.
 */
public class NMTFUtils {

    public static void main(String[] args) throws Exception {
        System.out.println("Start!");
        File file = new File("E:\\cls-acl10-processed_cutshortdoc\\mydata_add_withtraintest/");
        String[] list = file.list();
        System.out.println(String.join("','",Arrays.asList(list)));
//        TF2TFIDF();
        //一定要把原领域的test加入到训练集中,论文中的实验是4000天训练数据
        //join();
//        batch();
    }

    /**
     * 转换book music dvd 到SVM需要的格式
     *
     * @param path
     * @throws IOException
     */
    public static void transfer(String path) throws IOException {
        BufferedReader br = new BufferedReader(new FileReader((path)));
        String line = null;
        int lineId = 1;
        PrintStream ps = new PrintStream(path + ".dat");
        while ((line = br.readLine()) != null) {
            if (line.length() < 20) {
                continue;
            }
            String substring = line.substring(0, line.lastIndexOf(" "));
            String[] split = line.split(" ");

            //后边加，直接删除过短的测试文档
            if (split.length <= 5) {
                continue;
            }
            //
            int totalWordSize = 0;
            for (int i = 0; i < split.length - 1; i++) {
                totalWordSize += Integer.valueOf(split[i].split(":")[1]);
            }
            double label = 0.0;
            String s = split[split.length - 1].split(":")[1].trim().toLowerCase();
            if ("negative".equals(s)) {
                label = -1.0;
            } else if ("positive".equals(s)) {
                label = 1.0;
            } else {

                System.out.println("ERROR");
                return;
            }
            ps.println(lineId++ + " " + totalWordSize + " " + label + " " + substring);
        }
        ps.flush();
        ps.close();
        br.close();

    }

    public static double saveToMatlabFormat(String trainPath, String testpath, Set<String> sets, String dir, boolean addflag) throws Exception {

        // 初始化字典
        Map<String, Integer> Dic = TFIDF.initDicWithoutStopWord(new String[]{
            trainPath, testpath}, sets);

        // 初始化训练语料
        Map<String, tfidfDocument> cnTest = TFIDF.readFille(testpath);
        // 初始化标注语料
        Map<String, tfidfDocument> trainDoc = TFIDF.readFille(trainPath);

        PrintStream ps = new PrintStream("c:/dict.dat");
        Set<Map.Entry<String, Integer>> entries = Dic.entrySet();
        List<DIC> dicLists = new ArrayList<>();

        for (Map.Entry<String, Integer> temp : entries) {
            dicLists.add(new DIC(temp.getKey(), temp.getValue()));
//            ps.println(temp.getKey() + "@:@" + temp.getValue());
        }
        Collections.sort(dicLists);
        for (DIC temp : dicLists) {
            ps.println(temp.id + "@:@" + temp.word);
        }
        ps.flush();
        ps.close();

        String bestTrain = dir + "Train.data";
        String bestlabel = dir + "Train.label";
        String test = dir + "Test.data";
        String testlabel = dir + "Test.label";
        TFIDF.saveDocsAsTFIDFFOR_NMTF(bestTrain, bestlabel, trainDoc, Dic);
        TFIDF.saveDocsAsTFIDFFOR_NMTF(test, testlabel, cnTest, Dic);

        if (addflag) {
            addWord(bestTrain, test);
        } else {
            cutWord(bestTrain, test);
        }

        return 0;
    }

    /**
     * 转换成matlab格式时候添加一些词保证两个领域之间的维度是一样的
     *
     * @param bestTrain
     * @param test
     * @throws IOException
     */
    public static void addWord(String bestTrain, String test) throws IOException {
        List<String> trainData = FileUtils.readLines(new File(bestTrain), "utf-8");
        List<String> testData = FileUtils.readLines(new File(test), "utf-8");
        List<MatDataNode> trainLists = new ArrayList<>();
        List<MatDataNode> testLists = new ArrayList<>();
        int trainMaxWordId = 0;
        int trainMaxdocId = 0;
        int testMaxWordId = 0;
        int testMaxdocId = 0;
        for (String te : trainData) {
            String[] split = te.split(",");
            int wordId = Integer.valueOf(split[0]);
            int docId = Integer.valueOf(split[1]);
            double tfidf = Double.valueOf(split[2]);
            trainMaxWordId = Math.max(trainMaxWordId, wordId);
            trainMaxdocId = Math.max(trainMaxdocId, docId);
            trainLists.add(new MatDataNode(wordId, docId, tfidf));
        }

        for (String te : testData) {
            String[] split = te.split(",");
            int wordId = Integer.valueOf(split[0]);
            int docId = Integer.valueOf(split[1]);
            double tfidf = Double.valueOf(split[2]);
            testMaxWordId = Math.max(testMaxWordId, wordId);
            testMaxdocId = Math.max(testMaxdocId, docId);
            testLists.add(new MatDataNode(wordId, docId, tfidf));
        }
        if (trainMaxWordId > testMaxWordId) {
            testLists.add(new MatDataNode(trainMaxWordId, testMaxdocId, 0.07));
        } else if (trainMaxWordId < testMaxWordId) {
            trainLists.add(new MatDataNode(testMaxWordId, trainMaxdocId, 0.07));
        }
        save(bestTrain, trainLists);
        save(test, testLists);
    }

    /**
     * 转换成matlab格式时候删除过长维度的词，保证两个领域之间的维度一样
     *
     * @param bestTrain
     * @param test
     * @throws IOException
     */
    public static void cutWord(String bestTrain, String test) throws IOException {
        List<String> trainData = FileUtils.readLines(new File(bestTrain), "utf-8");
        List<String> testData = FileUtils.readLines(new File(test), "utf-8");
        List<MatDataNode> trainLists = new ArrayList<>();
        List<MatDataNode> testLists = new ArrayList<>();
        int trainMaxWordId = 0;
        int trainMaxdocId = 0;
        int testMaxWordId = 0;
        int testMaxdocId = 0;
        for (String te : trainData) {
            String[] split = te.split(",");
            int wordId = Integer.valueOf(split[0]);
            int docId = Integer.valueOf(split[1]);
            double tfidf = Double.valueOf(split[2]);
            trainLists.add(new MatDataNode(wordId, docId, tfidf));
        }

        for (String te : testData) {
            String[] split = te.split(",");
            int wordId = Integer.valueOf(split[0]);
            int docId = Integer.valueOf(split[1]);
            double tfidf = Double.valueOf(split[2]);
            testLists.add(new MatDataNode(wordId, docId, tfidf));
        }
        Collections.sort(trainLists, new Comparator<MatDataNode>() {
            @Override
            public int compare(MatDataNode o1, MatDataNode o2) {
                int diff = o1.wordId - o2.wordId;
                if (diff > 0) {
                    return 1;
                } else if (diff < 0) {
                    return -1;
                } else {
                    return 0;
                }

            }
        });
        Collections.sort(testLists, new Comparator<MatDataNode>() {
            @Override
            public int compare(MatDataNode o1, MatDataNode o2) {
                int diff = o1.wordId - o2.wordId;
                if (diff > 0) {
                    return 1;
                } else if (diff < 0) {
                    return -1;
                } else {
                    return 0;
                }

            }
        });
        while (true) {
            MatDataNode t1 = trainLists.get(trainLists.size() - 1);
            MatDataNode t2 = testLists.get(testLists.size() - 1);
            trainMaxWordId = t1.wordId;
            trainMaxdocId = t1.docId;
            testMaxWordId = t2.wordId;
            testMaxdocId = t2.docId;
            if (trainMaxWordId - testMaxWordId > 5) {
                trainLists.remove(trainLists.size() - 1);
            } else if (testMaxWordId - trainMaxWordId > 5) {
                testLists.remove(testLists.size() - 1);
            } else {
                break;
            }
        }
        if (trainMaxWordId > testMaxWordId) {
            testLists.add(new MatDataNode(trainMaxWordId, testMaxdocId, 0.07));
        } else if (trainMaxWordId < testMaxWordId) {
            trainLists.add(new MatDataNode(testMaxWordId, trainMaxdocId, 0.07));
        }
        save(bestTrain, trainLists);
        save(test, testLists);
    }

    public static void save(String path, List<MatDataNode> lists) throws IOException {
        PrintStream ps = new PrintStream(path);
        for (MatDataNode temp : lists) {
            ps.print(String.format("%d,%d,%f\n", temp.wordId, temp.docId, temp.tfidf));
        }
        ps.flush();
        ps.close();
    }

    /**
     * 用于个测试使用
     *
     * @throws Exception
     */
    public static void build() throws Exception {
        String trainPath = "C:\\Workspaces\\CoTraining\\datafiles\\co-training\\book\\cn_l_doc.dat";
        String testPath = "C:\\cls-acl10-processed\\de\\music\\trans\\en\\music\\test.processed.dat";
        // 初始化字典
        Map<String, Integer> cnDic = TFIDF.initDic(new String[]{
            trainPath, testPath});
        System.out.println("词典长度 : " + cnDic.size());
        PrintStream ps = new PrintStream("c:/dict.dat");
        Set<Map.Entry<String, Integer>> entries = cnDic.entrySet();
        for (Map.Entry<String, Integer> entr : entries) {
            ps.println(entr.getKey() + "@:@" + entr.getValue());
        }
        ps.close();
        String bestTrain = "c:/NMTFUtils/Train.data";
        String bestlabel = "c:/NMTFUtils/Train.label";
        String test = "c:/NMTFUtils/Test.data";
        String testlabel = "c:/NMTF/Test.label";
        // 初始化训练语料
        Map<String, tfidfDocument> cnTest = TFIDF.readFille(testPath);
        // 初始化未标注语料
        Map<String, tfidfDocument> train = TFIDF.readFille(trainPath);
        TFIDF.saveDocsAsTFIDFFOR_NMTF(bestTrain, bestlabel, train, cnDic);
        TFIDF.saveDocsAsTFIDFFOR_NMTF(test, testlabel, cnTest, cnDic);
    }

    /**
     * 批量转换数据到matlab输入格式
     *
     * @throws Exception
     */
    public static void batch() throws Exception {
        boolean addflag = true;
        String basedir = addflag ? "f:/cls-acl10-processed_cutshortdoc/mydata_add_withtraintest/" : "c:/mydata_cut/";
        String language[] = {"de", "fr", "jp"};
        String cat[] = {"books", "dvd", "music"};
        for (int i = 0; i < cat.length; i++) {
            String trainPath = String.format("f:/cls-acl10-processed_cutshortdoc\\en\\%s\\train.processed.dat", cat[i]);
            for (int j = 0; j < language.length; j++) {
                for (int k = 0; k < cat.length; k++) {
                    String testpath = String.format("f:/cls-acl10-processed_cutshortdoc\\%s\\%s\\trans\\en\\%s\\test.processed.dat", language[j], cat[k], cat[k]);
                    String dir = String.format("%s/en_%s_%s_%s/", basedir, language[j], cat[i], cat[k]);
                    File file = new File(dir);
                    if (!file.exists()) {
                        file.mkdirs();
                    }
                    saveToMatlabFormat(trainPath, testpath, null, dir, addflag);
//                    runSVM(trainPath, testpath, null);
                }
            }
        }
    }

    /**
     * 拼接测试文档到训练文档保证训练文档为4000个
     *
     * @throws IOException
     */
    public static void join() throws IOException {
        String path = "E:\\cls-acl10-processed_cutshortdoc\\en\\music\\test.processed.dat";
        List<String> lines = FileUtils.readLines(new File(path), "utf-8");
        List<String> results = new ArrayList<>();
        int docId = 2001;
        for (String line : lines) {
            results.add(docId++ + line.substring(line.indexOf(' ')));
        }
        FileUtils.writeLines(new File(path), results);
    }

    /**
     * 批量转换成TFIDF格式，并删除短文本
     */
    public static void TF2TFIDF() throws IOException {
        String dir = "f:/cls-acl10-processed_cutshortdoc";
        List<String> paths = new ArrayList<>();
        path(new File(dir), paths);
        for (String path : paths) {
            transfer(path);
        }
    }

    static void path(File file, List<String> paths) {
        if (file.isDirectory()) {
            for (File temp : file.listFiles()) {
                path(temp, paths);
            }
        } else {
            if (file.getName().endsWith("processed")) {
                paths.add(file.getAbsolutePath());
            }
        }
    }

    public static double runSVM(String trainPath, String testpath, Set<String> sets) throws Exception {
        double result = 0.0;

        // 初始化字典
        Map<String, Integer> cnDic = TFIDF.initDicWithoutStopWord(new String[]{
            trainPath,
            testpath}, sets);

        // 初始化训练语料
        Map<String, tfidfDocument> cnTest = TFIDF.readFille(testpath);
        // 初始化未标注语料
        Map<String, tfidfDocument> Train = TFIDF.readFille(trainPath);

        String[] cnTestPath = {"C:/tmp/",
                               "model.dat", "train.dat",
                               "test_rand.dat", "result.dat"};
        TFIDF.saveDocsAsSVM(cnTestPath[0] + cnTestPath[2], Train, cnDic);
        TFIDF.saveDocsAsSVM(cnTestPath[0] + cnTestPath[3], cnTest, cnDic);
        result = runTestLinear(cnTestPath, null, true, 1);
        return result;
    }

    /**
     * 获取SVM对跨领域分类的结果
     *
     * @throws Exception
     */
    public static void getSVMResult() throws Exception {
        PrintStream ps = new PrintStream("c:/AllSVM_result.txt");
        String language[] = {"de", "fr", "jp"};
        String cat[] = {"books", "dvd", "music"};
        for (int i = 0; i < cat.length; i++) {
            String trainPath = String.format("E:/cls-acl10-processed_cutshortdoc\\en\\%s\\train.processed.dat", cat[i]);
            for (int j = 0; j < language.length; j++) {
                for (int k = 0; k < cat.length; k++) {
                    String testpath = String.format("E:/cls-acl10-processed_cutshortdoc\\%s\\%s\\trans\\en\\%s\\test.processed.dat", language[j], cat[k], cat[k]);

                    double score = runSVM(trainPath, testpath, null);

                    ps.printf("en,%s,%s,%s,%.2f\n", language[j], cat[i], cat[k], score * 100);
                }
            }
        }
        ps.flush();
        ps.close();
    }

    private static double runTestLinear(String[] args, String resultPath,
                                        boolean train, int randNum) throws Exception {
        if (train) {
            String[] argv1 = {"-s", "0", "-c", "1.0", args[0] + args[2], // train
                              args[0] + args[1] // model
        };
            Train.main(argv1);
            System.out.println("SVM model training is Done!  " + args[0]
                               + args[2]);
        }

        String[] argv2 = {"-b", "1", args[0] + args[3], // test
                          args[0] + args[1], // model
                          args[0] + args[4] // output
    };// usage: svm_predict [options] test_file model_file output_file

        double result = Predict.main(argv2, resultPath);
        System.out.println("SVM model prediction is Done!  " + args[0]
                           + args[3]);
        return result;
    }

    /**
     * 生成CL-SCL的运行格式
     *
     * @throws FileNotFoundException
     */
    public static void command() throws FileNotFoundException {

        PrintStream ps = new PrintStream("c:/running.dat");
        String language[] = {"de", "fr", "jp"};
        String cat[] = {"books", "dvd", "music"};
        for (int j = 0; j < language.length; j++) {
            for (int i = 0; i < cat.length; i++) {
                for (int k = 0; k < cat.length; k++) {
                    String trainPath = String.format("python ./clscl_train en %s cls-acl10-processed/en/%s/train.processed "
                                                     + "cls-acl10-processed/en/%s/unlabeled.processed"
                                                     + " cls-acl10-processed/%s/%s/unlabeled.processed "
                                                     + "cls-acl10-processed/dict/en_%s_dict.txt "
                                                     + "model.bz2 --phi 30 --max-unlabeled=50000 -k 100 -m 450 --strategy=parallel", language[j], cat[i], cat[i], language[j], cat[k], language[j]);

                    String testpath = String.format("python ./clscl_predict cls-acl10-processed/en/%s/train.processed"
                                                    + " model.bz2 cls-acl10-processed/%s/%s/test.processed", cat[i], language[j], cat[k]);
                    ps.println(String.format("##%s\t%s\t%s", language[j], cat[i], cat[k]));
                    ps.println(trainPath);
                    ps.println(testpath);
                }
            }
        }
    }

    static class DIC implements Comparable<DIC> {

        public DIC(String word, Integer id) {
            this.word = word;
            this.id = id;
        }

        String word;
        Integer id;

        @Override
        public int compareTo(DIC o) {
            return this.id - o.id;
        }
    }

}
