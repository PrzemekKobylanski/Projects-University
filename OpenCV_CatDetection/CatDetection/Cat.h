//*********************
//*********************
//Przemys�aw Kobyla�ski
//3.09.2021
//
//Deklaracja klasy kot na kt�rej obiekcie operuje program
//*********************
//*********************


#pragma once
#include "CatDetectionClasses.h"
#include <iostream>
#include <opencv2/highgui.hpp>
#include <opencv2/objdetect.hpp>

using namespace std;
using namespace cv;


class Cat
{

protected:
	vector<Rect>cats;
public:
	Mat img;
	friend void detectData(Mat &im, Cat c);
	friend void detectVideo(Mat& im, Cat c,string pa,int ch);
	vector < Rect> getVector(); 

};

