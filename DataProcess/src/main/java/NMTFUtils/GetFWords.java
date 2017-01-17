/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package NMTFUtils;

import java.io.File;
import java.io.IOException;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.apache.commons.io.FileUtils;

/**
 *
 * @author zwj
 */
public class GetFWords {

    static String dicpath = "E:\\cls-acl10-processed_cutshortdoc\\mydata_add_withtraintest\\en_de_books_books\\dict.dat";

    public static void main(String[] args) throws IOException {
        String base = "EBGB";
        getTopWordsLSFTL(base);
//        getTopWordsTriTL(base);
    }

    public static void getTopWordsLSFTL(String base) throws IOException {
        int TOP_NUM = 20;
        List<String> dictsLists = FileUtils
                .readLines(new File(dicpath));
        List<String> indexLists = FileUtils
                .readLines(new File("G:\\syn_github\\KLSNMF\\KLSNMF\\indexs.csv"));
        Map<String, String> wordMaps = new HashMap<>();

        for (String line : dictsLists) {
            String[] split = line.split("@:@");
            if (split.length != 2) {
                wordMaps.put(split[0], "");
            } else {
                wordMaps.put(split[0], split[1]);
            }
        }
        PrintStream ps = new PrintStream("G:\\毕业设计论文\\写论文\\journal\\" + base + "\\L1SFTLs-TopWords.txt");
        for (int li = 0; li < indexLists.size(); li++) {
            String[] split = indexLists.get(li).split(",");
            StringBuilder topWords = new StringBuilder();
            for (int i = 0; i < TOP_NUM; i++) {
                String get = wordMaps.get(split[i]);
                if (get != null) {
                    topWords.append(get.trim()).append(" ");
                } else {
                    System.out.println(split[i]);
                    return;
                }
            }
            System.out.println(topWords);
            ps.println("TOP:" + (li + 1) + " " + topWords);
        }
        ps.flush();
        ps.close();

    }

    public static void getTopWordsTriTL(String base) throws IOException {
        int TOP_NUM = 20;
        List<String> dictsLists = FileUtils
                .readLines(new File(dicpath));
        List<String> indexLists = FileUtils
                .readLines(new File("F:\\matlab_code\\TriTL\\index.csv"));
        Map<String, String> wordMaps = new HashMap<>();

        for (String line : dictsLists) {
            String[] split = line.split("@:@");
            if (split.length != 2) {
                wordMaps.put(split[0], "");
            } else {
                wordMaps.put(split[0], split[1]);
            }

        }
        PrintStream ps = new PrintStream("G:\\毕业设计论文\\写论文\\journal\\" + base + "\\TRITL-TopWords.txt");
        for (int li = 0; li < indexLists.size(); li++) {
            String[] split = indexLists.get(li).split(",");
            StringBuilder topWords = new StringBuilder();
            for (int i = 0; i < TOP_NUM; i++) {
                String get = wordMaps.get(split[i]);
                if (get != null) {
                    topWords.append(get.trim()).append(" ");
                } else {
                    System.out.println(split[i]);
                    return;
                }
            }
            System.out.println(topWords);
            ps.println("TOP:" + (li + 1) + " " + topWords);
        }
        ps.flush();
        ps.close();

    }

}
