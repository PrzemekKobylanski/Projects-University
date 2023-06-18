function Lagrange = MojaInterpLagrange(xi,fxi)

%zmienna symboliczna x
syms x;
% Obliczenie liczby węzłów interpolacji
n = length(xi);
% Inicjalizacja wektora współczynników wielomianu Lagrange'a
wsp = sym('wsp', [n, 1]);

% Obliczenie współczynników
for j = 1:n
    w = 1;
    for i = 1:n
        if i ~= j
            w = w .* (x - xi(i)) ./ (xi(j) - xi(i));
        end
    end
    wsp(j) = fxi(j) .* w;
end

% Obliczenie wielomianu interpolacyjnego
Lagrange = sum(wsp);
end