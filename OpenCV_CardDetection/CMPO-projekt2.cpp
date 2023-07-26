#include<opencv2/highgui.hpp>
#include<opencv2/imgproc.hpp>
#include<iostream>

using namespace cv;
using namespace std;

//Funkcja preprocesująca przyjmująca obraz do preprocessingu
Mat preprocessing(Mat img)
{
	//Wykonanie preprocessingu na kopii
    Mat copy = img;
	//Filtr medianowy - usunięcie soli z pieprzem
    medianBlur(copy, copy, 5);
	//Zmiana koloru na szary przed filtrem gaussowskim
    cvtColor(copy, copy, COLOR_BGR2GRAY);
	//Rozmycie gaussa rekompensujące zdjęcia rozmyte
    GaussianBlur(copy, copy, Size(5, 5), 1.5);
	return copy;
}
//Funkcja segmentująca karty przyjmująca zdjęcie oraz wektory które zapełni
void segmentCards(Mat &img,vector<vector<Point>>&cards,vector<Point2d>&centers)
{
	//Stworzenie kopii
	Mat copy;
	//Binaryzacja oraz zamknięcie - nie są w preprocessingu gdyż dla następnej funkcji adaptiveThreshold przyjmuje inne parametry
	adaptiveThreshold(img, copy, 255, ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY_INV,11, 6);
	dilate(copy, copy, Mat(), Point(-1, -1), 1);
	erode(copy, copy, Mat(), Point(-1, -1), 1);
	//Wektor zapisujący kontury oraz znalezienie ich
	vector<vector<Point>>contours;
	findContours(copy, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
	//Pętla wybierająca karty
	for (size_t i = 0; i < contours.size(); i++)
	{
		if(contourArea(contours[i])>500)
			cards.push_back(contours[i]);
	}
	//Obrysowanie zdjęcia konturami
	drawContours(img, cards, -1, Scalar(255, 255, 0),5);
	//Znalezienie środków kart za pomocą momentów w postaci punktów 2d
	for (int i = 0; i < cards.size(); i++)
	{
		auto area = contourArea(cards[i]);
		auto moment = moments(cards[i]);
		auto center = Point2d{ moment.m10 / moment.m00,moment.m01 / moment.m00 };
		centers.push_back(center);
	}
 }
//Funkcja detekująca kolory - przyjmuje obraz oryginalny oraz środki kart i inta określającego która karta jest rozpatrywana
int colorDetection(Mat img,vector<Point2d>centers,int i)
{
	//Obraz pomocniczy przyjmujący wymiary badanego ROI
	Mat temp;
	temp= img(Range(centers[i].y - 80, centers[i].y + 80), Range(centers[i].x - 80, centers[i].x + 80));

	//Zmienna przechowująca informacje o kolorze
	int colorCard = 0;
	//Filtr medianowy dla usunięcia soli i pieprzu
	medianBlur(temp, temp, 5);
	//Zmiana palety barw na hsv
	cvtColor(temp, temp, COLOR_BGR2HSV);
	//Scalar przechowujący parametry kanałów kolorów
	Scalar color = (0, 0, 0);
	//Uśrednienie koloru na ROI
	color = mean(temp);

	// Określenie ifami jaki kolor ma karta - wartości znalezione ręcznie
	// Czerwony
	if (color(0) > 9 && color(0) < 19)
		colorCard = 1;
	//Żółty
	else if (color(0) > 21 && color(0) < 27)
		colorCard = 4;
	//Zielony
	else if (color(0) > 28 && color(0) < 38)
		colorCard = 2;
	//Niebieski
	else if (color(0) > 57 )
		colorCard = 3;
	else
		colorCard = 100;
	//Zwrócenie koloru karty
	return colorCard;
}
//Funkcja licząca sumę kart przyjmująca symbol karty
int countNumbers(string symbol)
{
	//Obliczenie sumy w zależności od symbolu
	int sum = 0;
	if (symbol == "One")
		sum += 1;
	else if (symbol == "Four")
		sum += 4;
	else if (symbol == "Eight")
		sum += 8;
	//Zwrócenie wartości
	return sum;
}
// Funkcja customowa znaleziona w internecie
bool compareContourAreas(const std::vector<cv::Point>& contour1, const std::vector<cv::Point>& contour2)
{
	  double i = fabs(contourArea(cv::Mat(contour1)));
	  double j = fabs(contourArea(cv::Mat(contour2)));
	  return (i > j);
}
// Funkcja detekująca karty - przyjmuje obraz oryginalny, wektor z zapisanymi kartami, współrzędne środków oraz wybór koloru dokonany przez użytkownika
int cardDetection(Mat img, vector<vector<Point>>cards,vector<Point2d>centers,int ch)
{
	//Stworzenie kopii obrazu - potrzebna do rozpoznawania kolorów
	Mat copy = img;
	//Preprocessing
	img=preprocessing(img);
	// Binaryzacja poza preprocessingiem bo inne parametry dawały lepsze rezultaty dla krawędzi a inne dla symboli
	adaptiveThreshold(img, img, 255, ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY_INV, 11, 4);
	dilate(img, img, Mat(), Point(-1, -1), 1);
	erode(img, img, Mat(), Point(-1, -1), 1);
	//Stworzenie macierzy ROI
	vector<Mat>ROI(cards.size());
	vector<vector<Point>>contours;
	//Wyszukanie ROI dla każdej karty
	for(int i=0; i<cards.size(); i++)
		ROI[i] = img(Range(centers[i].y - 80, centers[i].y + 80), Range(centers[i].x - 80 , centers[i].x + 80));
	//vector < vector<Point>>shapes;
	//Zmienns suma wykorzystywane przy zliczaniu kart 
	int sum = 0;
	//for wykonujący detekcje każdej kart po kolei
	for (int i = 0; i < 4; i++)
	{
		// zmienna symbol sprawdzająca jaka karta została wykryta
		string symbol = ".";
		int x = 0;
		//Obraz pomocniczy wielkości ROI
		Mat temp = Mat::zeros(Size(160, 160), CV_8UC1);
		//znalezienie konturów na każdym ROI
		findContours(ROI[i], contours, RETR_TREE, CHAIN_APPROX_SIMPLE);
		//posortowanie kontórów - pierwszy zawsze jest największy, a największy zawsze jest obwiednią symbolu karty
		sort(contours.begin(), contours.end(), compareContourAreas);
		//Narysowanie na pustym obrazie obwiedni symbolu
		drawContours(temp, contours, 0, Scalar(255, 0, 0), 2);
		//Sprawdzenie koloru karty
		x = colorDetection(copy,centers,i);
		//Jeśli karta ma inny kolor niż wybrał użytkownik to przechodzimy do następnej iteracji
		if (x != ch)
			continue;
		cout << "Next card" << endl;
		//Wykorzystanie momentów do wyznaczenia huMoments
		Moments moment = moments(temp, true);
		double huMoments[7];
		HuMoments(moment, huMoments);
		//Normalizacja huMoments do skali logarytmicznej
		for (int j = 0; j < 7; j++) 
		{
			huMoments[j] = -1 * copysign(1.0, huMoments[j]) * log10(abs(huMoments[j]));
		}
		//if sprawdzający symbol badany na podstawie 3 pierwszych wartości huMoments - sprawdzone ręcznie
		if (huMoments[0] > (-0.28) && huMoments[0] < (-0.15))
		{
			if (huMoments[1] > 0.01 && huMoments[1] < 0.15)
			{
				if (huMoments[2] > 0.2 && huMoments[2] < 0.45)
				{
					symbol = "One";
				}
			}
		}

		if (huMoments[0] > (-0.35) && huMoments[0] < (-0.15))
		{
			if (huMoments[1] > 0.5 && huMoments[1] < 1)
			{
				if (huMoments[2] > 0.02 && huMoments[2] < 0.25)
				{
					symbol = "Four";
				}
			}
		}

		if (huMoments[0] > (-0.5) && huMoments[0] < (-0.2))
		{
			if (huMoments[1] > 0.4 && huMoments[1] < 0.9)
			{
				if (huMoments[2] > 1.1 && huMoments[2] < 1.7)
				{
					symbol = "Eight";
				}
			}
		}
		//Dla symboli stop i reverse podanie współrzędnych środka karty
		if (huMoments[0] > (-0.5) && huMoments[0] < (-0.3))
		{
			if (huMoments[1] > 0.7 && huMoments[1] < 1.4)
			{
				if (huMoments[2] > 1.7 && huMoments[2] < 4.5)
				{
					symbol = "Stop";
					cout << "Stop center co-ordinates:" << "(" << centers[i].x << "," << centers[i].y << ")" << endl;
				}
			}
		}
		if(symbol==".")
		{
			symbol = "Reverse";
			cout << "Reverse center co-ordinates:" << "(" << centers[i].x << "," << centers[i].y << ")" << endl;
		}
		//Obliczenie sumy w zależności od symbolu
		sum += countNumbers(symbol);
	}
	//zwrócenie sumy
	return sum;
}

int main()
{
    //wczytanie zdjęć
	string path;
	cout << "Podaj sciezke do zdjecia:" << endl;
	cin >> path;
    Mat img = imread(path);
	//Sprawdzenie czy zdjęcie się wczytało
	if (img.empty())
	{
		cout << "There is no picture" << endl;
		return 0;
	}
	//Zapisanie oryginału oraz kopii
	Mat original =img;
	Mat copy = img;
	//Zmniejszenie obrazu oryginalnego ze względu na jego duze wymiary
	resize(img, img, Size(img.cols/2, img.rows/2));
	// wywołanie funkcji preprocesującej
    copy=preprocessing(img);
	//segmentacja zdjęcia
	vector<vector<Point>>card;
	vector<Point2d>centers;
	// Obraz wysegmentowany
	//Mat thresh = img;
    segmentCards(copy,card,centers);
	
	// Użytkownik wybiera kolor karty jaki go interesuje
	int ch = 0;
	cout << "What color do you want to check?" << endl;
	cout << "1. Red" << "\n" << "2. Green" <<endl<< "3. Blue" << "\n" << "4. Yellow"<< endl;
	do
	{
		//Sprawdzenie czy dobrze wpisano opcje
		while (!(cin >> ch))
		{
			cin.clear();
			cin.ignore(1000, '\n');
			if (ch < 1 || ch>4)
			{
				cout << "There is no such an option" << endl;
			}
		}
	} while (ch < 1 || ch>4);
	// Zmienna suma zwracająca sumę kart
	int sum = 0;
	//Wywołanie funkcji detekującej
	sum=cardDetection(img, card, centers, ch);
	//Naniesienie kółek zaznaczających centrum karty na zdjecie
	for (int i = 0; i < 4; i++)
	{
		circle(img, centers[i], 80, Scalar(255, 0, 0), 5);
	}
	//Jeśli znaleziono karty z liczbami odpowiedniego koloru to wypisanie ich sumy
	if (sum > 0)
	{
		cout << "Sum of all chosen cards is equal to: " << sum << endl;
	}
	//Pokazanie zdjęcia oryginalnego oraz zdjęcia z badanym ROI i konturem karty
	imshow("Oryginał", original);
    imshow("Zdjęcie z zaznaczonym ROI i konturami", img);
	waitKey(0);
    return 0;
}
