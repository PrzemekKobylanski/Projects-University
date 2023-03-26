#include "CatDetectionClasses.h"
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/objdetect.hpp>
#include <iostream>
#include <fstream>

using namespace cv;
using namespace std;


/////////////////////////
////////////////////////
//// Metody klasy image
///////////////////////
////////////////////////
string Image:: getPath()
{

	return path;
}

void Image:: grabData(Mat &im,string pa)
{
	
	Mat empty;
	cout << "Podaj sciezke do zdjecia:" << endl;
	int x = 0;
			
	do
	{
		cin >> path;
		im = imread(path);
		x++;
		int y = 0;
		if (im.empty())
		{
			cout << "Zla sciezka" << endl;
		}
		else
			cout << "Mamy zdjecie" << endl;
		if (x >= 3)
		{
			cout << "Czy chcesz kontynuowaæ?" << "\n" << "1.Tak" << "\n" << "2.Nie" << endl;
			do
			{
				cin >> y;
				if (y != 1 && y != 2)
					cout << "Taka opcja nie istnieje" << endl;
			} while (y < 1 && y > 2);

			switch (y)
			{
			case 1:
			{
				cout << "W takim razie podaj sciezke" << endl;
				x = 1;
				break;
			}
			case 2:
			{
				cout << "Konczymy program" << endl;
				return;
			}
			default:
			{
				cout << "Jak sie tu dostales?" << endl;
				return ;
			}
			}

		} 

	} while (im.empty() != 0);
	return ;
}

void Image:: showData(Mat im)
{
	imshow("Image", im);
	waitKey(10000);
	return;
}

/////////////////////////
////////////////////////
//// Metody klasy Video
///////////////////////
////////////////////////
string Video::getPath()
{

	return path;
}

void Video::grabData(Mat &im,string pa)
{
	Mat empty;
	cout << "Podaj sciezke do video:" << endl;
	int x = 0,z=1;

	do
	{
		cin >> path;
		VideoCapture cap(path);
		im = imread(path);
		x++;
		int y = 0;
		if (!cap.isOpened())
		{
			cout << "Zla sciezka" << endl;
			z = 0;
		}
		else
		{
			cout << "Mamy video" << endl;
			z = 1;
		}
		if (x >= 3)
		{
			cout << "Czy chcesz kontynuowac?" << "\n" << "1.Tak" << "\n" << "2.Nie" << endl;
			do
			{
				cin >> y;
				if (y != 1 && y != 2)
					cout << "Taka opcja nie istnieje" << endl;
			} while (y < 1 && y > 2);

			switch (y)
			{
			case 1:
			{
				cout << "W takim razie podaj sciezke" << endl;
				x = 1;
				break;
			}
			case 2:
			{
				path = "0";
				cout << "Konczymy program" << endl;
				return ;
			}
			default:
			{
				cout << "Nie powinno cie tu byc" << endl;
				return ;
			}
			}

		}
		
	} while (z!=1);
	return ;
}

/////////////////////////
////////////////////////
//// Metody klasy Webca,
///////////////////////
////////////////////////
string Webcam::getPath()
{

	return path;
}

void Webcam:: grabData(Mat &im,string pa)
{
	cout << "Podaj numer kamerki:" << endl;
	int number = 0;
	int z = 0;
	do
	{
		while (!(cin >> x))
		{
			cin.clear();
			cin.ignore(1000, '\n');
		}
		VideoCapture cap(x);
		
		int y = 0;
		if (!cap.isOpened())
		{
			cout << "Zla sciezka" << endl;
			z = 0;
		}
		else
		{
			cout << "Mamy video" << endl;
			z = 1;
		}
		if (number >= 3)
		{
			cout << "Czy chcesz kontynuowac?" << "\n" << "1.Tak" << "\n" << "2.Nie" << endl;
			do
			{
				cin >> y;
				if (y != 1 && y != 2)
					cout << "Taka opcja nie istnieje" << endl;
			} while (y < 1 && y > 2);

			switch (y)
			{
			case 1:
			{
				cout << "W takim razie podaj numer kamerki" << endl;
				x = 1;
				break;
			}
			case 2:
			{
				path = "0";
				cout << "Konczymy program" << endl;
				return;
			}
			default:
			{
				cout << "Nie powinno cie tu byc" << endl;
				return;
			}
			}

		}
		number++;
	} while (z != 1);
	return;
}


/////////////////////////
////////////////////////
//// Metody zaprzyjaŸnione
///////////////////////
////////////////////////
void detectVideo( Mat &im, Cat c,string pa,int ch)
{
	CascadeClassifier faceCas;
	string xmlPath;
	cout << "Podaj sciezke do folderu z opencv" << endl;
	cin >> xmlPath;
	faceCas.load(xmlPath+"/build/etc/haarcascades/haarcascade_frontalcatface_extended.xml");
	if (faceCas.empty())
	{
		cout << "Nie znaleziono pliku .xml" << endl;
		return;
	}
	Video vid;
	Webcam web;
	VideoCapture cap1(pa);
	VideoCapture cap2(web.x);
	while (true)
	{
		if (ch == 2)
		{
			cap1.read(im);
			cap1 >> im;
		}
		else if (ch == 3)
		{
			cap2.read(im);
			cap2 >> im;
		}
		if (im.empty())
			break;
		vector<Rect> cats;
		faceCas.detectMultiScale(im, cats, 1.1, 10);
		for (int i = 0; i < cats.size(); i++)
		{
			rectangle(im, cats[i].tl(), cats[i].br(), Scalar(0, 255, 255), 3);
			putText(im, to_string(i + 1) + " Cat Found", cats[i].tl(), FONT_HERSHEY_DUPLEX, 0.5, Scalar(255, 0, 255));
		}
		imshow("Image", im);
		if(ch==2)
		waitKey(10);
		else if (ch == 3)
		{
			char c = (char)waitKey(10);
			if (c == 27 || c == 'q' || c == 'Q')
				break;
		}
	}
}

void detectData(Mat& im, Cat c)
{
	CascadeClassifier faceCas;
	string xmlPath;
	cout << "Podaj sciezke do folderu z opencv" << endl;
	cin >> xmlPath;
	faceCas.load(xmlPath + "/build/etc/haarcascades/haarcascade_frontalcatface_extended.xml");
	if (faceCas.empty())
	{
		cout << "Nie znaleziono pliku .xml" << endl;
		return;
	}
	faceCas.detectMultiScale(im,c.cats, 1.1, 10);
	for (int i = 0; i < c.cats.size(); i++)
	{
		rectangle(im, c.cats[i].tl(), c.cats[i].br(), Scalar(0, 255, 255), 3);
		putText(im, to_string(i + 1) + "Cat Found", c.cats[i].tl(), FONT_HERSHEY_DUPLEX, 0.5, Scalar(255, 0, 255));
	}
}

