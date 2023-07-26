function [Output] = zad1(N,A)

% zmienna przechowująca wszystkie podzbiory
Output={[A]};
%zmienna określająca istnienie maksimum
max=false;
%licznik wykonannych kroków
counter=0;
%pętla generująca określoną liczbę podzbiorów
while true
    %pętla podzbioru
    for i=1:length(N)
        %zmienna sprawdzająca czy liczba jest w podzbiorze i zbiorze
        isInA=false;
        for j=1:length(A)
            %znalezienie liczby znajdującej się w A i N
            if N(i)==A(j)
                isInA=true;
                break;
            end
        end
        %znalezienie maksymalnej wartości znajdującej się poza A
        if isInA==false
            max=N(i);
        end
    end
    if ~(max==false) % sprawdzenie czy maksimum istnieje (jest element N nienależący do A)
        for i=1:length(A) 
            if A(i)>max 
                A=[A(1:i-1),max]; %Usuwa elementy większe od max i dodaje max
                Output{end+1}=A; %dodaje podzbiór do zmiennej 
                break
            elseif i==length(A)
                A=[A,max]; %dodaje max na końcu
                Output{end+1}=A; %dodaje podzbiór do zmiennej
                break 
            end
            
        end
     %jeśli maksimum nie istnieje to koniec
    else
        return
    end
    %zwiększenie licznika pętli
    counter=counter+1;
    if counter==10
        return
    end
end

end
