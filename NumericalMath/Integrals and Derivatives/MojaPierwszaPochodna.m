function d = MojaPierwszaPochodna(x, y)
    %długość wektora x    
    n = length(x);
    d = zeros(size(y));
    %krok różniczkowania
    h = x(2) - x(1);
    %krańce przedziału
    d(1) = (y(2) - y(1)) / h;
    d(n) = (y(n) - y(n-1)) / h;
    %pochodna wewnątrz przedziału
    for i = 2:n-1
        d(i) = (y(i+1) - y(i-1)) / (2*h);
    end
end