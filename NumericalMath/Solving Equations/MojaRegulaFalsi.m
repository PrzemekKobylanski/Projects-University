function [x, iteracje, error] = MojaRegulaFalsi(f, a, b, eps)
iteracje = 1;
error = [];

% Sprawdzamy przedział
if f(a)*f(b) > 0
    disp('Zły przedział');
    return;
end

while iteracje < 100
    % Wyznaczamy kolejny punkt
    x = b - f(b)*(b-a)/(f(b)-f(a));
    % Błąd od konkretnego x
    error(iteracje) = abs(f(x));
    % Jeśli błąd w normie to kończymy
    if error(iteracje) < eps
        return;
    end
    iteracje = iteracje + 1;
    % Uaktualniamy przedział
    if f(a)*f(x) < 0
        b = x;
    else
        a = x;
    end
end
end
