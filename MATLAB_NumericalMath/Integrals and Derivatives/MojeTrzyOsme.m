function integral = MojeTrzyOsme(fun, a, b, npanel)
    % Szerokość podprzedziału    
    h = (b - a) / npanel;
    % Punkty podprzedziałów
    x = linspace(a, b, npanel+1);
    y = fun(x);
    
    % Sumy wyrazów
    sumNiepodz = 0;
    sumPodz= 0;
    
    % Różne warunki w zależności od ostatniego npanel
    for i = 1:npanel-1
        %jeśli podzielne przez 3
        if rem(i, 3) == 0
            sumPodz = sumPodz + y(i+1);
        %niepodzielne przez 3
        else
           sumNiepodz= sumNiepodz + y(i+1);
        end
    end
    
    % Wynik z uwzględnieniem wag
    integral = (3 * h / 8) * (fun(a) + 3 * sumNiepodz + 2 * sumPodz + fun(b));
end
