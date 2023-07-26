function [table_queue,table_edges] = zad1BFS(matrix)


       %indeksy  1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9
g=graph(matrix,{'a','b','c','d','e','f','g','h','i'});
plot(g);

dict = ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i'];

%stworzenie elementów przechowujących wierzchołki i informacje o wizycie
tops=size(matrix,1);
visited=zeros(1,tops);
queue=CQueue(); %tworzenie kolejki
queue_letters=CQueue(); %kolejka na ładne dane

%wkładanie pierwszego wierzchołka (a) na kolejkę i zaznaczenie wizyty
queue.push(1);
queue_letters.push(dict(1));
visited(1,1)=1 ;
queues=queue_letters.content()

%zmienne przechowujące kolejki i krawędzie
table_queue={string(queue.content())};
table_edges={[]};
edge=zeros(2,0);
edges=string([])

%dopóki kolejka nie jest pusta
while ~queue.isempty()

    %zmienna przejścia 
    deeper=false;
    %pętla po wierzchołkach
    for i=1:tops
        checked=queue.front(); %sprawdzenie pozycji
        if(matrix(checked,i)==1 && visited(1,i)==0) %warunek dodania do kolejki
            queue.push(i); %dodanie do kolejki
            queue_letters.push(dict(i)); %dodanie do kolejki jako literka
            visited(1,i)=1; %zaznaczenie wizyty
            edge(:,end+1)=[checked;i]; %wyznaczenie krawędzi
            edges=dict(edge) %zamiana na literki
            table_edges{end+1}=edges; %dodanie do tabeli
            table_queue{end+1}=string(queue_letters.content()); %dodanie do tabeli kolejki
            deeper=true; %przejście
            break;
        end
    end
    %usuwanie elementów
    if(deeper==false)
        queue.pop() ; 
        queue_letters.pop();
    end
    %wyświetlanie kolejki
    queues=queue_letters.content()
end

end