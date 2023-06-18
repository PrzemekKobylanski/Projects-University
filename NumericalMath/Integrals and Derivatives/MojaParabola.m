function integral = MojaParabola(fun, a, b, npanel)
    % Szerokość podprzedziału    
    h = (b - a) / npanel;
    %punkty podprzedziałów
    x = linspace(a, b, npanel+1);
    y = fun(x);
    
    %sumy wyrazów parzystych i nieparzystych
    sumNP = sum(y(2:2:end-1));
    sumP = sum(y(3:2:end-2));
    
    %wynik z uwzględnieniem wag
    integral = h/3 * (fun(a) + 4*sumNP + 2*sumP + fun(b));
end