function Newton = MojaInterpNewton(xi, fxi)

%zmienna symboliczna x
syms x;
% Obliczenie liczby węzłów interpolacji
n = length(xi);
% Inicjalizacja wektora współczynników różnicowych
wsp = zeros(n,n);
wsp(:,1) = fxi;

% Obliczenie współczynników różnicowych
for j = 2:n
    for i = j:n
        wsp(i,j) = (wsp(i,j-1) - wsp(i-1,j-1)) / (xi(i) - xi(i-j+1));
    end
end

% Obliczenie wielomianu interpolacyjnego
Newton = wsp(n,n);
for k = n-1:-1:1
    Newton = wsp(k,k) + (x - xi(k)) .* Newton;
end
end

