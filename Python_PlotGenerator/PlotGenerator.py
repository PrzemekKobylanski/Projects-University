# Wykonał: Przemysław Kobylański 297253
'''
Napisać program, który posiada GUI i służy do generowania wykresów 2D bądź 3D zaleznie od wyboru użytkownika
Wykresy są generowanie na podstawie inputu w postaci funkcji matematycznej wpisywanej w okienko GUI przez użytkownika
'''
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure
import sympy as sp
import tkinter as tk
from tkinter import messagebox
from tkinter import colorchooser
from tkinter import ttk

# Tworzenie głównego okna Tkinter
root = tk.Tk()
root.title("Generator Wykresów 2D i 3D")
root.geometry("800x600")

# Zmienne do edycji wyglądu UI
canvas = None
background_color = 'white'
plot_color = 'white'
line_color = 'blue'
plot_3d = False
colormap = 'viridis'

#zmienna do zgenerowania domylnego UI
counter = 0

#Funkcje edycji wyglądu okna
def Choose_background_color():
    global background_color
    selected_color = colorchooser.askcolor(title="Wybierz kolor tła okna", initialcolor=background_color)[1]
    if selected_color:
        background_color = selected_color
        root.configure(bg=background_color)

def Choose_plot_color():
    global plot_color
    selected_color = colorchooser.askcolor(title="Wybierz kolor tła wykresu", initialcolor=plot_color)[1]
    if selected_color:
        plot_color = selected_color
        plt.gca().set_facecolor(plot_color)

def Choose_line_color():
    global line_color
    selected_color = colorchooser.askcolor(title="Wybierz kolor linii na wykresie", initialcolor=line_color)[1]
    if selected_color:
        line_color = selected_color

#Tworzenie okienka do wyboru mapy kolorów wykresu 3D
def Choose_colormap():
    def Update_colormap():
        global colormap
        colormap = selected_colormap.get()
        colormap_window.destroy()

    colormap_window = tk.Toplevel(root)
    colormap_window.title("Wybierz mapę kolorów")

    colormap_list = ['viridis', 'plasma', 'inferno', 'magma', 'cividis', 'jet', 'rainbow', 'nipy_spectral', 'cubehelix']

    selected_colormap = tk.StringVar(value=colormap)
    colormap_combobox = ttk.Combobox(colormap_window, textvariable=selected_colormap, values=colormap_list)
    colormap_combobox.pack()

    button_confirm = tk.Button(colormap_window, text="Potwierdź", command=Update_colormap)
    button_confirm.pack()

#Funkcja generowania wykresów 2d
def Generate_2d_plot():
    global canvas
    #pobieranie wyrażenia od usera
    user_expression = entry.get()
    #inicjowanie zmiennych
    x = np.linspace(-10, 10, 100)
    y = None

    #usuwanie wykresów jesli jakis istnieje
    if canvas and canvas.get_tk_widget().winfo_exists():
        canvas.get_tk_widget().destroy()

    # Sprawdzenie czy użytkownik podał poprawne wyrażenie
    try:
        sym_x = sp.Symbol('x')
        # Sprawdź, czy wprowadzona funkcja zależy od x
        if 'x' in user_expression.lower():
            # przetworzenie podanego przez usera wyrażenia
            user_expression = sp.sympify(user_expression)
            user_function_numeric = sp.lambdify(sym_x, user_expression, 'numpy')
            #Stworzenie funkcji f(x)
            y = user_function_numeric(x)
            plot_type = "Funkcja Ciągła"
        else:
            # Jeśli nie ma x w wyrażeniu, przyjmij stałą wartość na całej długosci y
            y = np.full_like(x, float(user_expression))
            plot_type = "Funkcja Stała"

        #Tworzenie wykresu o okreslonym rozmiarze, położeniu, osiach itp
        fig, ax = plt.subplots(figsize=(10, 6))
        ax.plot(x, y, color=line_color)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
        ax.set_title(f'{plot_type}')
        ax.set_facecolor(plot_color)
        canvas = FigureCanvasTkAgg(fig, master=root)
        canvas_widget = canvas.get_tk_widget()
        canvas_widget.place(x=50,y=100)
    #Zgłoszenie wyjątku
    except Exception as e:
        messagebox.showerror("Błąd", f"Zmienna nie jest zależna od x (np. x*2 ,sin(x), itp.):\n{e}")

# Funkcja generowania wykresów 3d
def Generate_3d_plot():
    global canvas
    #Pobranie wyrażenia podanego przez usera
    user_expression = entry.get()
    #Inicjalizacja zmiennych
    x = np.linspace(-10, 10, 100)
    y = np.linspace(-10, 10, 100)
    X, Y = np.meshgrid(x, y)
    Z = np.zeros_like(X)

    #Usunięcie grafu jesli jakis istnieje
    if canvas and canvas.get_tk_widget().winfo_exists():
        canvas.get_tk_widget().destroy()
    #Sprawdzenie czy użytkownik podał poprawne wyrażenie
    try:
        sym_x, sym_y = sp.symbols('x y')
        # Sprawdzenie czy jest x lub y w wyrażeniu
        if 'x' in user_expression.lower():
            user_expression = sp.sympify(user_expression)
            user_function_numeric = sp.lambdify((sym_x, sym_y), user_expression, 'numpy')
            Z = user_function_numeric(X, Y)
            plot_type = "Funkcja 3D"
        elif 'y' in user_expression.lower():
            user_expression = sp.sympify(user_expression)
            user_function_numeric = sp.lambdify((sym_x, sym_y), user_expression, 'numpy')
            Z = user_function_numeric(X, Y)
            plot_type = "Funkcja 3D"
        else:
            # Jeśli nie ma 'x' ani 'y' w wyrażeniu, przyjmij stałą wartość na całej długosci
            Z = np.full_like(X, float(user_expression))
            plot_type = "Funkcja Stała"

        #Tworzenie wykresu o okreslonym rozmiarze, położeniu, osiach itp
        fig = Figure(figsize=(10, 6))
        ax = fig.add_subplot(111, projection='3d')
        ax.plot_surface(X, Y, Z, cmap=colormap)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
        ax.set_zlabel('z')
        ax.set_title(f'{plot_type}')
        canvas = FigureCanvasTkAgg(fig, master=root)
        canvas_widget = canvas.get_tk_widget()
        canvas_widget.place(x=50,y=100)
    # Zgłoszenie wyjątku
    except Exception as e:
        messagebox.showerror("Błąd", f"Zmienna nie jest zależna od x i y (np. x*2 + y*2,sin(x) * cos(y), itp.):\n{e}")

def Create_2dUI():
    #Zmienne globalne do edycji w innych funkcjach
    global button_background
    global button_plot_color
    global button_line_color
    global description
    global button_generator
    global user_frame
    global entry
    global counter

    #Sprawdzenie czy istnieje UI do zniszczenia
    if counter!=0:
        Destroy_3dUI()

    # Opis polecenia dla użytkownika
    description = tk.Label(root, text="Wprowadź wyrażenie funkcji (z użyciem 'x' jako zmiennej, np sin(x))")
    description.place(x=230, y=5)

    # Ramka zawierająca pole do wprowadzania tekstu
    user_frame = tk.Frame(root)
    user_frame.place(x=330, y=25)
    # Etykieta
    y_label = tk.Label(user_frame, text="y =")
    y_label.pack(side=tk.LEFT)
    # Pole do wprowadzania tekstu
    entry = tk.Entry(user_frame)
    entry.pack(side=tk.LEFT)


    # Przyciski wyboru kolorystyki
    button_background = tk.Button(root, text="Wybierz kolor tła okna", command=Choose_background_color)
    button_background.place(x=10, y=0)
    button_plot_color = tk.Button(root, text="Wybierz kolor tła wykresu 2D", command=Choose_plot_color)
    button_plot_color.place(x=10, y=30)
    button_line_color = tk.Button(root, text="Wybierz kolor linii na wykresie 2D", command=Choose_line_color)
    button_line_color.place(x=10, y=60)

    #Generowanie wykresu 2D
    button_generator = tk.Button(root, text="Generuj Wykres", command=Generate_2d_plot)
    button_generator.place(x=350, y=50)

    #zwiększenie countera żeby nie generować domyślnego UI
    counter+=1

def Create_3dUI():
    #Zmienne globalne do edycji w innych funkcjach
    global description
    global user_frame
    global button_colormap
    global button_generator
    global button_background
    global entry
    global counter

    #Sprawdzenie czy jest UI do usunięcia
    if counter!=0:
        Destroy_2dUI()

    # Opis polecenia dla użytkownika
    description = tk.Label(root, text="Wprowadź wyrażenie funkcji 3D (z użyciem 'x' i 'y' jako zmiennych, np x**2 + y**2)")
    description.place(x=230, y=5)

    # Ramka zawierająca pole do wprowadzania tekstu
    user_frame = tk.Frame(root)
    user_frame.place(x=330, y=25)
    # Etykieta
    z_label = tk.Label(user_frame, text="z =")
    z_label.pack(side=tk.LEFT)
    # Pole do wprowadzania tekstu
    entry = tk.Entry(user_frame)
    entry.pack(side=tk.LEFT)

    # Przyciski wyboru kolorystyki
    button_background = tk.Button(root, text="Wybierz kolor tła okna", command=Choose_background_color)
    button_background.place(x=10, y=0)
    button_colormap = tk.Button(root, text="Wybierz mapę kolorów wykresu 3D", command=Choose_colormap)
    button_colormap.place(x=10, y=30)

    #Generowanie wykresu 3D
    button_generator = tk.Button(root, text="Generuj Wykres", command=Generate_3d_plot)
    button_generator.place(x=350, y=50)

    #zwiększenie countera żeby nie generować domyślnego UI
    counter+=1

#Usuwanie elementów UI 2D
def Destroy_2dUI():
    user_frame.destroy()
    button_background.destroy()
    button_plot_color.destroy()
    button_line_color.destroy()
    description.destroy()
    button_generator.destroy()

#Usuwanie elementów UI 3D
def Destroy_3dUI():
    user_frame.destroy()
    button_colormap.destroy()
    description.destroy()
    button_generator.destroy()
    button_background.destroy()

#generowanie domyślnego UI
if counter==0:
    Create_2dUI()


# Tworzenie przycisków opcji dla wyboru typu wykresu (2D lub 3D)
plot_type = tk.IntVar()
plot_type.set(0)

# Przyciski wyboru między 2D i 3D
button_2d_plot = tk.Radiobutton(root, text="2D", value=False, variable=plot_type, command=Create_2dUI)
button_2d_plot.place(x=750, y=10)
button_3d_plot = tk.Radiobutton(root, text="3D", value=True, variable=plot_type, command=Create_3dUI)
button_3d_plot.place(x=750, y=30)

# Przycisk Zakończ
button_end = tk.Button(root, text="Zakończ", command=root.destroy)
button_end.place(x=400, y=550)

# Rozpoczęcie głównej pętli Tkinter
root.mainloop()
