package cnjdk1;

import java.io.File;
import java.io.IOException;
import java.io.PrintStream;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Created by zwj on 2017/1/18.
 */
public class OPt {
    public static void main(String[] args) throws IOException {
        List<String> p = new ArrayList<>();
        getPath(new File("G:\\毕业设计论文\\20NG_final"), p);
        int limie = 10;
        for (String filePath : p) {
            filtsmall(filePath, limie);
        }
//        String[] srcs = {"politics.misc", "religion"};
//        String label = "-1.0";
//        String savePath = "G:\\毕业设计论文\\20newsgroup\\sci_talk\\test.dat";
//        String base = "G:\\毕业设计论文\\20newsgroup\\merge\\";
//        newsopt(base, srcs, label, savePath);
        //opt("E:\\cls-acl10-processed_cutshortdoc\\cn\\books\\test_en.dat");
        //opt("E:\\cls-acl10-processed_cutshortdoc\\cn\\dvd\\test_en.dat");
        //opt("E:\\cls-acl10-processed_cutshortdoc\\cn\\music\\test_en.dat");
    }

    public static void getPath(File file, List<String> path) {
        if (file.isDirectory()) {
            for (File f : file.listFiles()) {
                getPath(f, path);
            }
        } else {
            path.add(file.getAbsolutePath());
        }

    }

    public static void filtsmall(String path, int limie) throws IOException {
        List<String> strings = Files.readAllLines(Paths.get(path));
        List<String> collect = strings.stream()
                .filter(line -> {
                    String[] split = line.split(" ");
                    if (split.length > limie + 3) {
                        return true;
                    }
                    return false;
                })
                .map(line -> line.substring(line.indexOf(' ') + 1))
                .collect(Collectors.toList());
        List<String> save = new ArrayList<>();
        for (int i = 1; i <= collect.size(); i++) {
            save.add(i + " " + collect.get(i - 1));
        }
        Files.write(Paths.get(path), save);
    }

    public static void mergeIn() throws IOException {
        int[] nums = {17, 18, 19, 20};
        String cat = "talk";
        for (int num : nums) {
            merge("G:\\20newgroups\\train\\" + cat + "\\" + num, "G:\\20newgroups\\test\\" + cat + "\\" + num,
                    "G:\\20newgroups\\merge\\" + cat + "\\" + num);
        }
    }

    public static void newsopt(String base, String[] trainSrcs, String label, String savePath) throws IOException {
        List<String> res = new ArrayList<>();
        for (String path : trainSrcs) {
            List<String> strings = Files.readAllLines(Paths.get(base + path));
            List<String> collect = strings.stream().map(line -> {
                int pt = line.indexOf(' ', line.indexOf(' ') + 1) + 1;
                return line.substring(pt);
            }).collect(Collectors.toList());
            res.addAll(collect);
        }
        List<String> save = new ArrayList<>();
        for (int i = 1; i <= res.size(); i++) {
            String s = res.get(i - 1);
            int sum = 0;
            for (String words : s.split(" ")) {
                sum += Integer.valueOf(words.split(":")[1]);
            }
            save.add(i + " " + sum + " " + label + " " + s);
        }
        Files.write(Paths.get(savePath), save, StandardOpenOption.CREATE, StandardOpenOption.APPEND, StandardOpenOption.WRITE);
    }

    public static void merge(String train, String test, String target) throws IOException {
        List<String> trains = Files.readAllLines(Paths.get(train));
        List<String> tests = Files.readAllLines(Paths.get(test));
        trains.addAll(tests);
        Files.write(Paths.get(target), trains);
    }

    public static void opt(String path) throws IOException {
        List<String> strings = Files.readAllLines(Paths.get(path), Charset.defaultCharset());
        List<String> posLists = new ArrayList<>();
        List<String> negLists = new ArrayList<>();
        strings.stream()
                .filter(line -> line.split(" ").length > 8)
                .forEach(line -> {
                    String[] split = line.split(" ");
                    Double integer = Double.valueOf(split[2]);
                    if (integer == -1.) {
                        negLists.add(line);
                    } else if (integer == 1.) {
                        posLists.add(line);
                    }
                });
        posLists.sort((a, b) -> {
            if (a.length() > b.length()) {
                return -1;
            } else if (a.length() < b.length()) {
                return 1;
            }
            return 0;
        });
        negLists.sort((a, b) -> {
            if (a.length() > b.length()) {
                return -1;
            } else if (a.length() < b.length()) {
                return 1;
            }
            return 0;
        });
        List<String> res = new ArrayList<>();
        PrintStream ps = new PrintStream(new File(path + ".test.processed.dat"));
        for (int i = 1; i <= 1000; i++) {
            String line = posLists.get(i - 1);
            line = line.substring(line.indexOf(' '));
            res.add(line);
            line = negLists.get(i - 1);
            line = line.substring(line.indexOf(' '));
            res.add(line);
        }
        Collections.shuffle(res);
        for (int i = 1; i <= res.size(); i++) {
            ps.println(i + res.get(i - 1));
        }
        ps.flush();
        ps.close();
    }
}
