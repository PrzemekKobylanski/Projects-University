function [x, iteracje, error] = MojaSieczna(f, a, b, eps)
iteracje = 1;
error = [];

% Sprawdzamy przedział
if f(a)*f(b) > 0
    disp('Zły przedział');
    return;
end

% Punkt początkowy
x0 = a;
x1 = b;

while iteracje < 100
    % Wyznaczamy kolejny punkt
    x = x1 - f(x1)*(x1-x0)/(f(x1)-f(x0));
    % Błąd od konkretnego x
    error(iteracje) = abs(f(x));
    % Jeśli błąd w normie to kończymy
    if error(iteracje) < eps
        return;
    end
    iteracje = iteracje + 1;
    % Uaktualniamy punkty
    x0 = x1;
    x1 = x;
end
end
