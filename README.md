# CUDA_SVM

- step 1: Implement SVM based on LIBSVM, in python;

- step 2: Impelement sequential SVM, Linear kernel; (Using the same data input and output processing)

- step 3: Implement CUDA based SVM, Linear kernel; (Using the same processing other than the optimzation part in step 3)


### GPU Implementation of SVM
+ GPUSVM: <https://github.com/niitsuma/gpusvm>
+ SVM CUDA implementation: <https://github.com/Site1997/SVM-Cuda>
+ LibSVM CUDA: <https://mklab.iti.gr/results/gpu-accelerated-libsvm/>

### Sequential Minimal Optimization
+ Original Paper (1998): <https://www.microsoft.com/en-us/research/publication/sequential-minimal-optimization-a-fast-algorithm-for-training-support-vector-machines/>
+ Textbook (1999): [Platt J.C., Fast training of support vector machines using sequential minimal optimization, In: Advances in kernel
methods – support vector learning, Sch lkopf, B. and Burges, C.J.C and Smola, A.J. (Eds.), 185-208, MIT Press,
Cambridge, MA, USA, 1999](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/smo-book.pdf>
+ Python Implementation: <https://jonchar.net/notebooks/SVM/)
+ C++ Implementation: <https://medium.com/@dr.sunhongyu/machine-learning-c-svm-support-vector-machine-simple-example-deff5d55d43e>

### Dataset
+ UCI Machine Learning Repository: <https://archive.ics.uci.edu/ml/datasets.php>
    + Baseline: *Glass，iris, wine, sonar, breast-cancer, adult*
    + Statlog Data: *heart, letter, shuttle*
+ *Usps*: <https://git-disl.github.io/GTDLBench/datasets/usps_dataset/>
+ *Web*: <https://archive.ics.uci.edu/ml/datasets/Anonymous+Microsoft+Web+Data>
+ *Mnist*: <https://git-disl.github.io/GTDLBench/datasets/mnist_datasets/>
