function x = MojGauss(A,b)
    %wyznaczenie ilości niewiadomych
    n = length(b);
    % iteracja po macierzy A
    for k = 1:n-1
        for i = k+1:n
            % mnożnik do zerowania wierszy
            m = A(i,k) / A(k,k);
            % zerowanie wierszy
            A(i,k+1:n) = A(i,k+1:n) - m * A(k,k+1:n);
            b(i) = b(i) - m * b(k);
        end
    end
    %pusta macierz rozwiązań
    x = zeros(n,1);
    % wyznaczenie ostatniej niewiadomej
    for i = 1:n
        x(n+1-i) = (b(n+1-i) - A(n+1-i,:) * x) / A(n+1-i,n+1-i);
    end
end