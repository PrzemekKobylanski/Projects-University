
This project contains code used in Engineering thesis - the goal was to build a model able to detect defects on liquid cells surface. To achieve that, YOLOv5 was used. Dataset was created using Roboflow and notebook Cell-Defects-Detection-checkpoint was a base to build a model using YOLOv5 and was based on tutorial notebook. 
The examplary parameters of the model are shown on the 500epochs.png - Final number of epochs during training was 300. 
Weights of this model was saved in file best2.py. Code main.py was created to load weights, detect defects in specific conditions and order and save it to .csv file (like BHDC_bets2model.csv) to allow further analysis. To use this code properly there is a need to download YOLOv5 repository and add file detect2.py to yolov5 folder.

The results of detection are shown on the pictures in folder CTMA_best2model
