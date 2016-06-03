package liblinear;

import de.bwaldvogel.liblinear.*;

public class LinearSVM {

    private static String[] cnPredictPath = {
        // "datafiles/"+TYPE+"/cn/",
        "./res/music-test/", "model.dat", "train.dat", "test.dat",
        "result.dat"};

    public static void main(String args[]) throws Exception {
        String trainPath = "./res/music-test/train.dat";
        LinearSVM.train(cnPredictPath);
    }

    /**
     * String basePath = paths[0]; String modelPath = paths[1]; String trainPath
     * = paths[2]; String predictPath = paths[3]; String outputPath = paths[4];
     */
    public static void train(String args[]) throws Exception {
        String[] argv1 = {"-c", "1.0", "-eps", "0.001", args[0] + args[2], // train
                          args[0] + args[1] // model
    };
        Train.main(argv1);
        System.out.println("SVM model training is Done!");

        String[] argv2 = {
            // "-b", "1",
            args[0] + args[3], // test
            args[0] + args[1], // model
            args[0] + args[4] // output
        };// usage: svm_predict [options] test_file model_file output_file
        Predict.main(argv2, null);
        System.out.println("SVM model prediction is Done!");

    }

    public void linearSVM(String args[]) {
        try {
            train(args);
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

}
