function [x,iteracje,error] = MojNewton(f,df,a,b,eps)
iteracje = 1;
error = [];

% Sprawdzamy przedział
if f(a)*f(b) > 0
    disp('Zły przedział');
    return;
end

% Punkt początkowy
if f(a)*df(a) < 0
    x = a;
else
    x = b;
end

while iteracje < 100
    %przybliżenie wzorem Newtona
    xi = x - f(x)/df(x);
    %błąd od konkretnego xi
    error(iteracje) = abs(f(xi));
    %jeśli błąd w normie to kończymy
    if error(iteracje) < eps
        x = xi;
        return
    end
    iteracje = iteracje + 1;
    x = xi;
end
end