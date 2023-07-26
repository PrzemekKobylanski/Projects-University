function [x, iteracje,error] = MojJacobi(A, b, x0, eps)

    %Wynik poprawny i macierz na błędy
    result=A\b;
    error=zeros(100,3);
    % Macierz diagonalna
    D = diag(diag(A));
    % Macierz LU
    LU = A - D;
    % Parametry iteracyjne
    Mj = -inv(D) * LU;
    wj = inv(D) * b;
    % Definicja szukanej różnicy
    r = b - A * x0;
    % Pętla iteracji
    for i = 1:100
        % Jeśli błąd jest mniejszy niż zakładany
        if(norm(r,inf) < norm(b,inf) * eps)
           x = x0;
           iteracje = i;
           break ;
        end
        % Następny krok iteracji
        x0 = Mj * x0 + wj;
        r = b - A * x0;
        %Zapisanie błędów w macierzy
        error(i,1) =abs((x0(1)-result(1))/result(1));
        error(i,2) =abs((x0(2)-result(2))/result(2));
        error(i,3) =abs((x0(3)-result(3))/result(3));
    end
end