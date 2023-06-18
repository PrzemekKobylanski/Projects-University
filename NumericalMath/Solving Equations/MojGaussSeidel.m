function [x, iteracje,error] = MojGaussSeidel(A, b, x0, eps)
    %Wynik poprawny i macierz na błędy    
    result=A\b;
    error=zeros(100,3);
    %macierz diagonalna
    D = diag(diag(A));
    %macierz poddiagonalna
    L = triu(A, 1);
    %macierz naddiagonalna
    U = tril(A, -1);

    %parametry iteracyjne
    Mgs = -inv(D + L) * U;
    wgs = inv(D + L) * b;

    %szukana różnica
    r = b - A * x0;
    %pętla iteracji
    % Pętla iteracji
    for i = 1:100
        % Jeśli błąd jest mniejszy niż zakładany
        if(norm(r,inf) < norm(b,inf) * eps)
           x = x0;
           iteracje = i;
           break ;
        end
        % Następny krok iteracji
        x0 = Mgs * x0 + wgs;
        r = b - A * x0;
        %Zapisanie błędów w macierzy
        error(i,1) =abs((x0(1)-result(1))/result(1));
        error(i,2) =abs((x0(2)-result(2))/result(2));
        error(i,3) =abs((x0(3)-result(3))/result(3));
    end
end