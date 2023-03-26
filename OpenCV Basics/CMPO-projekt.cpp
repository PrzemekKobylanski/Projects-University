//// CMPO-projekt.cpp : Ten plik zawiera funkcję „main”. W nim rozpoczyna się i kończy wykonywanie programu.
////
//
#include <iostream>
#include<opencv2/imgcodecs.hpp>
#include<opencv2/highgui.hpp>
#include<opencv2/imgproc.hpp>
#include<opencv2/objdetect.hpp>
#include<cmath>

using namespace cv;
using namespace std;

 
// ---------------------------------------------------------
///    Ar2
// ---------------------------------------------------------
Mat reverseLut(Mat img,float g,int x,int y,int w, int h)
{
    Mat lookUpTable(1, 256, CV_8U);
    uchar* lut = lookUpTable.ptr();
    for (int i = 0; i < 256; ++i)
        lut[i] = saturate_cast<uchar>(pow(i / 255.0, (1/g)) * (255.0));
    for (int i = x; i < (x+w); i++)
    {
        for (int j = y; j <(y+h); j++)
            img.at<unsigned char>(i, j) = lut[img.at<unsigned char>(i, j)];
    }
    return img;

}
Mat Lut(Mat img,float gamma,int ch,int x,int y,int w,int h)
{
  
    Mat lookUpTable(1, 256, CV_8U);
    uchar* lut = lookUpTable.ptr();
    uchar* revLut = lookUpTable.ptr();
    //Stworzenie tablicy do korekcji gamma
    for (int i = 0; i < 256; ++i)
        lut[i] = saturate_cast<uchar>(pow(i / 255.0, gamma) * 255.0);
    if (ch == 1)
    {
        for (int i = x; i <( x + w ) ;i++)
        {
            for (int j = y; j < (y + h); j++)
            {
                    img.at<unsigned char>(i, j) = lut[img.at<unsigned char>(i, j)];
            }
        }

        return img;
    }
    // Dla 3 kanałów
    else if (ch == 2)
    {
        for (int k = x; k < (x + w); k++)
        {
            for (int l = y; l <( y + h ); l++)
            {
                for (int i = 0; i < img.cols; i++)
                {
                    for (int j = 0; j < img.rows; j++)
                    {
                        img.at<Vec3b>(i, j)[0] = lut[img.at<unsigned char>(i, j)];
                        img.at<Vec3b>(i, j)[1] = lut[img.at<unsigned char>(i, j)];
                        img.at<Vec3b>(i, j)[2] = lut[img.at<unsigned char>(i, j)];
                    }
                }
            }
        }

        return img;
    }
    //image.at<Vec3b>(x, y)[c]
}
bool ROI(Mat img, int x, int y, int w, int h)
{
    bool check = 0;
    if (x + w > img.cols || y+h>img.rows)
    {
        cout << "Sorry but your data is out of image range. Try again" << endl;
        check = 0;
        return check;
    }
    else if (x + w < img.cols || y + h < img.rows)
    {
        check = 1;
        return check;
    }

}



// ---------------------------------------------------------
///                     Mo1
// ---------------------------------------------------------
Mat dilation(Mat img, Mat kernel) 
{

    Mat temp = Mat(img.rows, img.cols, CV_8U,Scalar::all(0));
    int kernelSize = 5;
    int border = kernelSize / 2;
    for (int x = border; x < img.cols - border; x++) 
    {
        for (int y = border; y < img.rows - border; y++)
        {
            for (int i = -border; i < border; i++) 
            {
                for (int j = -border; j < border; j++)
                {
                    if (img.at<unsigned char>(y + j, x + i)) 
                    {
                        temp.at<unsigned char>(y, x) = 255;
                        break;
                    }
                }
            }

        }
    }

    return temp;


}
Mat erosion(Mat img, Mat kernel) 
{

    Mat temp = Mat(img.rows, img.cols, CV_8U,Scalar::all(0));
    int kernelSize = 5;
    int border = kernelSize / 2;
    for (int x = border; x < img.cols - border; x++) 
    {
        for (int y = border; y < img.rows - border; y++) 
        {
            for (int i = -border; i < border; i++) 
            {
                for (int j = -border; j < border; j++) 
                {
                    if (!img.at<unsigned char>(y + j, x + i)) 
                    {
                        temp.at<unsigned char>(y, x) = 0;
                        break;
                    }
                }
            }

        }
    }
    return temp;


}
Mat closing(Mat img, int iterations,Mat kernel) 
{
    for (int i = 0; i < iterations; i++)
    {
        Mat dilated = dilation(img,kernel);
        Mat closed = erosion(dilated,kernel);
        return closed;
    }

}

Mat opening(Mat img, int iterations, Mat kernel) 
{
    for (int i = 0; i < iterations; i++) 
    {
        Mat eroded = erosion(img,kernel);
        Mat opened = dilation(eroded,kernel);
        return opened;
    }
}

/// Menu
int main()
{
    int choice;
    do
    {
        cout << "What would you like to see" << endl;
        cout << "1.Ar2" << "\n" << "2.Mo1" << "\n" << "3.Nothing" << endl;
        while (!(cin >> choice))
        {
            cin.clear();
            cin.ignore(1000, '\n');
            if (choice < 1 || choice>3)
            {
                cout << "There is no such an option" << endl;
            }
        }
    } while (choice < 1 || choice>3);
    //
    if (choice == 3)
    {
        return 0;

    }
    Mat img;
    string path;
    cout << "Where is the picture?" << endl;
    cin >> path;
    img = imread(path);

   /* do
    {*/

         //------------------------------------------------------
        /// Obsługiwanie Ar2
        //------------------------------------------------------
        if (choice == 1)
        {
            // wykonaj operacje korekcji gamma za pomocą LUT
            Mat img2;
            
           
            int ch;
            cout << "Does you have picture in GrayScale or RGB?" << endl;
            cout << "1. GrayScale" << "\n" << "2. RGB" << endl;
            do
            {
                while (!(cin >> ch))
                {
                    cin.clear();
                    cin.ignore(1000, '\n');
                    if (ch < 1 || ch>2)
                    {
                        cout << "There is no such an option" << endl;
                    }
                }
            } while (ch < 1 || ch>2);
            int part;
            cout << "What part of the picture you want to correct" << endl;
            cout << "1. All" << "\n" << "2. Roi" << endl;
            do
            {
                while (!(cin >> part))
                {
                    cin.clear();
                    cin.ignore(1000, '\n');
                    if (part < 1 || part>2)
                    {
                        cout << "There is no such an option" << endl;
                    }
                }
            } while (part < 1 || part>2);
            
            int x = 0, y = 0, w = img.cols, h = img.rows;
            if (part == 2)
            {
                bool accept = 0;
                do
                {
                   
                    cout << "I need the starting point from you" << endl;
                    cout << "X: " << endl;
                    cin >> x;
                    cout << "Y: " << endl;
                    cin >> y;
                    cout << "Tell me the width: " << endl;
                    cin >> w;
                    cout << "And height:" << endl;
                    cin >> h;
                    accept = ROI(img, x, y, w, h);
                } while (accept == 0);
            }
            cout << "What gamma you want to use?" << endl;
            float g;
            cin >> g;
            cvtColor(img, img, COLOR_BGR2GRAY);
            imshow("Przed Lut", img);
            int ch2;
            img2=Lut(img,g,ch,x,y,w,h);
            
            imshow("Po Lut", img2);
            cout << "Satisfited?" << "\n" << "1.Yes" << "\n" << "2.No, reverse it" << "\n" << "3. No, repeat with different gamma" << endl;
           
            do
            {
                while (!(cin >> ch2))
                {
                    cin.clear();
                    cin.ignore(1000, '\n');
                    if (ch2 < 1 || ch2>3)
                    {
                        cout << "There is no such an option" << endl;
                    }
                }
            } while (ch2 < 1 || ch2>3);
           
            if (ch2 == 2)
            {
                img2=reverseLut(img, g,x,y,w,h);
                imshow("Po Lut odwrocone", img2);
            }
            else if (ch == 3)
            {
                img2=Lut(img,g,ch,x,y,w,h);
                imshow("Po Lut znowu", img2);
            }
            
            waitKey(0);

        }


        //------------------------------------------------------
        /// Obsługiwanie Mo1
        //------------------------------------------------------
        else if (choice == 2)
        {
            int ch=0,figure=-1,iterations=0;
            cvtColor(img, img,COLOR_BGR2GRAY);
            threshold(img, img, 100, 255, THRESH_BINARY);
            imshow("Original image", img);
            cout << "Tell me what you want to do" << endl;
            cout << "1.Closing" << "\n" << "2.Opening" << endl;
            do
            {
                while (!(cin >> ch))
                {
                    cin.clear();
                    cin.ignore(1000, '\n');
                    if (ch < 1 || ch>2)
                    {
                        cout << "There is no such an option" << endl;
                    }
                }
            } while (ch < 1 || ch>2);
            cout << "What shape of kernel you want to use?" << endl;
            cout << "0.Rectangle" << "\n" << "1.Cross" << "\n" << "2.Elipse";
            do
            {
                while (!(cin >> figure))
                {
                    cin.clear();
                    cin.ignore(1000, '\n');
                    if (figure < 0 || figure>2)
                    {
                        cout << "There is no such an option" << endl;
                    }
                }
            } while (figure < 0 || figure>2);
            cout << "How many iterations do you want" << endl;
            do
            {
                while (!(cin >> iterations))
                {
                    cin.clear();
                    cin.ignore(1000, '\n');
                    if (iterations < 1)
                    {
                        cout << "It must be bigger than 1" << endl;
                    }
                }
            } while (iterations < 1);
            //0 - prostokąt 1-krzyż 2 - elipsa
            Mat kernel = getStructuringElement(figure, Size(3, 3));
            if (ch == 1)
            {
                Mat closed = closing(img, iterations, kernel);
                imshow("closed", closed);
                waitKey(0);
            }
            else if (ch == 2)
            {
                Mat opened = opening(img, iterations, kernel);
                imshow("closed", opened);
                waitKey(0);
            }
            
  
            
        }
      
    /*    x = endOfProgram();*/

   /* } while (x == 0);*/

    return 0;
}
//// Uruchomienie programu: Ctrl + F5 lub menu Debugowanie > Uruchom bez debugowania
//// Debugowanie programu: F5 lub menu Debugowanie > Rozpocznij debugowanie
//
//// Porady dotyczące rozpoczynania pracy:
////   1. Użyj okna Eksploratora rozwiązań, aby dodać pliki i zarządzać nimi
////   2. Użyj okna programu Team Explorer, aby nawiązać połączenie z kontrolą źródła
////   3. Użyj okna Dane wyjściowe, aby sprawdzić dane wyjściowe kompilacji i inne komunikaty
////   4. Użyj okna Lista błędów, aby zobaczyć błędy
////   5. Wybierz pozycję Projekt > Dodaj nowy element, aby utworzyć nowe pliki kodu, lub wybierz pozycję Projekt > Dodaj istniejący element, aby dodać istniejące pliku kodu do projektu
////   6. Aby w przyszłości ponownie otworzyć ten projekt, przejdź do pozycji Plik > Otwórz > Projekt i wybierz plik sln