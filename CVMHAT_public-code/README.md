# CVMHAT: Multiple Human Association and Tracking from Egocentric and Complementary Top Views


### Introduction

This MATLAB code of the proposed CVMHAT tracker. 
This code create the single-view tracklets, explained in the paper, in overlapping segments. 
We compute the cost matrix (including the over-time and cross-view cost) for single-view tracklets and solve the BIP problem to get the cross-view short trajectory results. 
To form the long trajectories, we conncet the cross-view short trajectories that overlap. 

You can use the code to run it on the given complementary-view sequence dataset or the similar sequences.
For more details, please refer to our [PAMI paper](https://ieeexplore.ieee.org/document/9394804).

The code is consist of four main section:
- Creating low-level tracklets using overlap and appearance feature. This part is not optimized and it is the slow (especially using the appearance feature). You may replace it with a faster method.
- Creating the cost matrix (including the over-time and cross-view cost) for low-level tracklets.
- Solving BIP problem to get the short cross-view trajectory results in overlaping segments. 
- Stitching the tracklets to form the long cross-view trajectory results.


### Citing CVMHAT

Please cite CVMHAT in your publications if it helps your research:

    @article{han2021CVMHAT,
      title={Multiple Human Association and Tracking from Egocentric and Complementary Top Views}, 
      author={Han, Ruize and Feng, Wei and Zhang, Yunjun and Zhao, Jiewen and Wang, Song},  
      year={2021},  
      journal={IEEE TRANSACTIONS ON PATTERN ANALYSIS AND MACHINE INTELLIGENCE}
    }

    @inproceedings{han2020cvmht,
      title={Complementary-View Multiple Human Tracking}, 
      author={Han, Ruize and Feng, Wei and Zhao, Jiewen and Niu, Zicheng and Zhang, Yunjun and Wan, Liang and Wang, Song},  
      year={2020},  
      booktitle={AAAI Conference on Artificial Intelligence}
    }


### Dependencies

  The CPLEX dependencies are included for Windows and Ubuntu. 
  For Mac you need to include the corresponding files by following the installation on IBM website. 
  (CPLEX is an optimization software with license provided FREE FOR ACADEMIC PURPOSES by IBM.
  You can download CPLEX by following this link.)

  http://www.ibm.com/developerworks/downloads/ws/ilogcplex/index.html?cmp=dwenu&cpb=dwweb&ct=dwcom&cr=dwcom&ccy=zz

  Check out the IBM Academic initiative to get a free license.

  http://www-304.ibm.com/ibm/university/academic/pub/page/ban_ilog_programming

### Installation

1. Get the code @ Github.
   https://github.com/RuizeHan/CVMHAT

2. Download sample data set @ BaiduYun.
   Link: https://pan.baidu.com/s/1dS9sGqxOcaDsxddl6r2OKA   Password: CVHT.

### Test
1. Select the test sequence by changing configSeqs.m file. 

2. Run main.m

### Extention
Please note the proposed method mainly focuses the *complementary-view* videos.
If you plan to run it on your own sequences, check the the format of the provided data. 
You just need to provide the tracklets in the same format that the code requires. 
You can also modify the netCost matrix generator depending on your own sequences.
