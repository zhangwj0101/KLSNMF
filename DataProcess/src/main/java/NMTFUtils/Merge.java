package NMTFUtils;

import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Created by zwj on 2016/9/23.
 */
public class Merge {

    public static void main(String[] args) {

        String bestTrain = "c:/NMTFUtils/Train.data";
        String bestlabel = "c:/NMTFUtils/Train.label";
        String imediateTrain = "c:/NMTFUtils/imediate.data";
        String imediatelabel = "c:/NMTFUtils/imediate.label";
        String test = "c:/NMTFUtils/Test.data";
        String testlabel = "c:/NMTFUtils/Test.label";

        sort(bestTrain);
        sort(imediateTrain);
        sort(test);
//        merge("C:\\TTL\\train\\train.dats");
//        merge("C:\\TTL\\test\\test.dats");
//        merge("C:\\TTL\\imedate\\imedate.dats");
    }

    public static void merge(String path) {
        try {
            int k = 1;
            List<String> res = new ArrayList<>();
            List<String> strings = FileUtils.readLines(new File(path));
            for (String te : strings) {
                int totalwords = 0;
                String[] split = te.split(" ");
                for (int i = 2; i < split.length; i++) {
                    totalwords += Integer.valueOf(split[i].split(":")[1]);
                }
                res.add(k++ + " " + totalwords + " " + (split[1].equals("1") ? "1.0" : "-1.0")
                        + " " + te.substring(te.indexOf(' ') + 3));
            }
            FileUtils.writeLines(new File(path + "1"), res);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void sort(String path) {

        try {
            int k = 1;
            List<String> strings = FileUtils.readLines(new File(path));
            Collections.sort(strings, new Comparator<String>() {
                @Override
                public int compare(String o1, String o2) {
                    return Integer.valueOf(o1.split(",")[0]) - Integer.valueOf(o2.split(",")[0]);
                }
            });
            FileUtils.writeLines(new File(path), strings);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


}
