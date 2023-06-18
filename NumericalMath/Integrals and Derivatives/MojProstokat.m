function integral = MojProstokat(fun,a,b,npanel)
    % Szerokość podprzedziału    
    h = (b - a) / npanel; 
    % Punkty środkowe
    x = a + h/2 : h : b - h/2;  
    y = fun(x);
    %wynik
    integral = sum(y) * h;
end



