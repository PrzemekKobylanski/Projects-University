function [x, iteracje, error] = MojePolowienie(f, a, b, eps)
iteracje = 0; 
error = []; 

while iteracje <100
    %obliczenie środka
    center = (a + b)/2; 
    %dodawanie błędu do wektora błędów
    error(iteracje+1) = abs(f(center) - 0); 
    %jeśli osiągnięto dokładność to koniec iterowania
    if error(iteracje+1) < eps 
        x = center; 
        return 
    end
    %sprawdzenie czy pierwiastek jest w połówkach i przesunięcie przedziału
    if f(a)*f(center) < 0 
        b = center; 
    else
        a = center; 
    end
    iteracje = iteracje + 1; 
end

x = center; 

end