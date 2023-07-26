function [table_stacks,table_edges] = zad1DFS(matrix)

       %indeksy  1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9
g=graph(matrix,{'a','b','c','d','e','f','g','h','i'});
plot(g)

dict = ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i'];

%stworzenie elementów przechowujących wierzchołki i informacje o wizycie
tops=size(matrix,1);
visited=zeros(1,tops);
stack=CStack(); %tworzenie stosu
stack_letters=CStack(); %tworzenie stosu z ładnymi nazwami punktów

%wkładanie pierwszego wierzchołka (a) na stos i zaznaczenie wizyty
stack.push(1);
stack_letters.push(dict(1));
visited(1,1)=1 ;
stacks=stack_letters.content()

%zmienne przechowujące stosy i krawędzie
table_stacks={string(stack.content())};
table_edges={[]};
edge=zeros(2,0);
edges=string([])

%dopóki stos nie jest pusty
while ~stack.isempty()

    %zmienna przechowująca informacje o wejściu w głąb
    deeper=false;
    %pętla po wierzchołkach
    for i=1:tops
        checked=stack.top(); %zapisanie badanego wierzchołka
        if(matrix(checked,i)==1 && visited(1,i)==0) %warunek dodania do stosu
            stack.push(i); %dodanie do stosu
            stack_letters.push(dict(i)); %dodanie do stosu jako literka
            visited(1,i)=1; %zaznaczenie wizyty
            edge(:,end+1)=[checked;i]; %wyznaczenie krawędzi
            edges=dict(edge) %zamiana na literki
            table_edges{end+1}=edges; %dodanie do tabeli
            table_stacks{end+1}=string(stack_letters.content()); %dodanie do tabeli
            deeper=true; %wejście w głąb
            break;
        end
    end
    %jeśli nie wchodzimy w głąb to usuwanie
    if(deeper==false)
        stack.pop();
        stack_letters.pop();
    end
    %wyświetlanie stosu
    stacks=stack_letters.content()

end

end

