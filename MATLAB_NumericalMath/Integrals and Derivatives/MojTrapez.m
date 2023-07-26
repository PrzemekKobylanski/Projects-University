function integral = MojTrapez(fun, a, b, npanel)
    % Szerokość podprzedziału
    h = (b - a) / npanel;
    % Punkty podprzedziałów
    x = linspace(a, b, npanel+1);
    y = fun(x);
    % Wynik
    integral = (sum(y) - (y(1) + y(end))/2) * h;
end

