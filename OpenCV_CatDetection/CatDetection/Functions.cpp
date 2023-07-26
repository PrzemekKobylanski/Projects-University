#include "Functions.h"
#include "CatDetectionClasses.h"
#include <iostream>
#include "Cat.h"


using namespace std;


int menu()
{
	int choice;
	cout << "Z jakiego rodzaju pliku chcesz korzystac?" << endl;
	cout << "1. Zdjecie" << "\n" << "2.Wideo" << "\n" << "3.Webcam" << endl;

	do
	{
		while (!(cin >> choice))
		{
			cin.clear();
			cin.ignore(1000, '\n');
			if (choice < 1 || choice>3)
			{
				cout << "Taka opcja nie istnieje" << endl;
			}
		}
	} while (choice < 1 || choice>3);

	return choice;

}

int endOfProgram()
{
	int x;
	system("cls");
	cout << "Czy chcesz wykorzystaæ nastêpne materialy?" << endl << "1.Tak" << endl << "2.Nie" << endl;
	do
	{
		while (!(cin >> x))
		{
			cin.clear();
			cin.ignore(1000, '\n');
			if (x < 1 || x>2)
			{
				cout << "Taka opcja nie istnieje" << endl;
			}
		}
	} while (x < 1 || x>2);
	switch (x)
	{
	case 1:
	{
		x = 0;
		return x;
	}
	case 2:
	{
		x = 1;
		cout << "Wybrales zakonczenie programu" << endl;
		return x;
	}
	}
}

void runProgram()
{
	int choice, x;
	Data* pointer;
	Image im;
	Video vid;
	Webcam web;
	Cat cat;
	do
	{
		choice = menu();
		if (choice == 1)
		{
			pointer = &im;
			pointer->grabData(cat.img, im.getPath());
			if (cat.img.empty())
			{
				cout << "Wybrales zakonczenie programu " << endl;
				return ;
			}
			detectData(cat.img, cat);
			im.showData(cat.img);

		}
		else if (choice == 2)
		{
			pointer = &vid;
			pointer->grabData(cat.img, vid.getPath());
			if (vid.getPath() == "0")
			{
				cout << "Wybrales zakonczenie programu " << endl;
				return;
			}
			detectVideo(cat.img, cat, vid.getPath(), choice);
		}
		else if (choice == 3)
		{
			pointer = &web;
			pointer->grabData(cat.img, web.getPath());
			detectVideo(web.img, cat, web.getPath(), choice);

		}
		x = endOfProgram();

	} while (x == 0);

	return ;
}
