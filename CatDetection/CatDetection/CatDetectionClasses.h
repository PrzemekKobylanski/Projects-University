//*********************
//*********************
//Przemys³aw Kobylañski
//3.09.2021
//
//Deklaracje klasy wirtualnej i klas pocgochodnych do niej
//*********************
//*********************

#pragma once
#include <opencv2/highgui.hpp>
#include <opencv2/objdetect.hpp>
#include <iostream>
#include <fstream>
#include "Cat.h"
using namespace cv;
using namespace std;

class Cat;
class Data
{
public:
	virtual void grabData(Mat &im,string pa) = 0;

};
class Image : public Data
{
protected:
	string path;
public:
	void grabData(Mat &im,string pa);
	friend void detectData(Mat &im, Cat c);
	void showData(Mat im);
	string getPath();
};

class Video : public Data
{
protected:
	string path;
	VideoCapture cap;
public:
	void grabData(Mat& im,string pa);
	friend void detectVideo(Mat& im, Cat c, string pa, int ch);
	string getPath();
};
class Webcam : public Data
{
	string path;
protected:
	VideoCapture cap;
public:
	int x;
	Mat img;
public:
	void grabData(Mat& im,string pa);
	friend void detectVideo(Mat& im, Cat c, string pa, int ch);
	string getPath();
};


