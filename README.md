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

parallel SVM:

Input:
Model: C, gamma(rbf kernel)

CUDA: num of blocks; num of thread in each block;

Data: X, Y

global memory: alpha_i
shared memory： Xi，Yi，ei

step1: Initilaize alpha=0, fi;(device) 

step2: 在每个device上划分 Iup Ilo; 计算每个data的ei；根据ei和group的情况，计算每个device上的bup，blow；

step3：传递给host，计算整体的bup,blow; 和 up low对应的data的index；

step4: while(blo>bup+2*tao){

            step5: 整体的bup，blo,up_index,lo_index传递到device中；根据index找到对应的两个thread，去得到k(lo,lo),k(up,up),k(lo,up)
            
            step6：根据index找到对应的两个thread，计算新的alpha_lo, alpha_up（alpha是放到global里的）
            
            step7:这两个thread上的up和low集合进行调整，计算新的ei--->得到新的blo和bup（only these two threads）--->传递给host
            
            step8: 计算整体的bup,blow; 和 up low对应的data的index；
            
        }
step9: return alpha

Problem: kernel calculation;
