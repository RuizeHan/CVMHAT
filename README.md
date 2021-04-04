# CVMHAT

```
@article{han2021CVMHAT,
  title={Multiple Human Association and Tracking from Egocentric and Complementary Top Views}, 
  author={Han, Ruize and Feng, Wei and Zhang, Yunjun and Zhao, Jiewen and Wang, Song},  
  year={2021},  
  journal={IEEE TRANSACTIONS ON PATTERN ANALYSIS AND MACHINE INTELLIGENCE}
}
```
<div align= justify>
Crowded scene surveillance can significantly benefit from combining egocentric-view and its complementary top-view cameras. A typical setting is an egocentric-view camera, e.g., a wearable camera on the ground capturing rich local details, and a top-view camera, e.g., a drone-mounted one from high altitude providing a global picture of the scene. To collaboratively analyze such complementary-view videos, an important task is to associate and track multiple people across views and over time, which is challenging and differs from classical human tracking, since we need to not only track multiple subjects in each video, but also identify the same
subjects across the two complementary views. This paper formulates it as a constrained mixed integer programming problem, wherein a major challenge is how to effectively measure subjects similarity over time in each video and across two views. Although appearance and motion consistencies well apply to over-time association, they are not good at connecting two highly different complementary views. To this end, we present a spatial distribution based approach to reliable cross-view subject association. We also build a dataset to benchmark this new challenging task. Extensive experiments verify the effectiveness of our method.
  
<div align=center><img src="https://github.com/RuizeHan/CVMHAT/blob/main/figs/example.png" width="500" height="525" alt="example"/><br/>
