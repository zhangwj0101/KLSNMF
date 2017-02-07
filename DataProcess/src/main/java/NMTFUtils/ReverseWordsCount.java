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
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.apache.commons.io.FileUtils;

/**
 *
 * @author zwj
 */
public class ReverseWordsCount {

    public static void main(String[] args) throws IOException {
        List<String> readLines = FileUtils
                .readLines(new File("G:\\张鹤\\LTNMT\\LTNMT\\sougou\\sougou2500.txt"));
        Map<String, Integer> words = new HashMap<>();

        for (String line : readLines) {
            String[] split = line.split(" ");
            for (String wprd : split) {
                Integer get = words.get(wprd);
                if (get == null) {
                    words.put(wprd, 1);
                } else {
                    words.put(wprd, get + 1);
                }
            }
        }
        Set<Map.Entry<String, Integer>> entrySet = words.entrySet();
        List<Map.Entry<String, Integer>> reverseLists = new ArrayList<>(entrySet);
        Collections.sort(reverseLists, new Comparator<Map.Entry<String, Integer>>() {
            @Override
            public int compare(Map.Entry<String, Integer> o1, Map.Entry<String, Integer> o2) {
                return o2.getValue().compareTo(o1.getValue());
            }
        });
        PrintStream ps = new PrintStream("c:/reverseWords.txt");
        for (Map.Entry<String, Integer> teEntry : reverseLists) {
            ps.println(teEntry.getKey() + " " + teEntry.getValue());
        }
        ps.close();
    }
}
