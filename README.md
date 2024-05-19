# PARP — zadanie z języka Prolog

## Polecenie
W ramach zadania należy napisać grę przygodową w SWI-Prolog. Gry tego typu nazywane są też interaktywną fikcją (ang. interactive fiction). Wyobrażenie na temat takich gier daje krótki przewodnik pod adresem: https://pr-if.org/doc/play-if-card/. Temat gry może być dowolny: od ratowania księżniczki z wieży i szukania skarbów po przetrwanie na statku kosmicznym opanowanym przez hordę zombie. Jako punkt startowy należy wykorzystać plik adventure.pl . Zawiera on
szkielet gry z jedną lokacją, z której można pójść tylko na północ (po czym wraca się w to samo miejsce) oraz jednym przedmiotem, który można podnieść lub upuścić. 

## Szczegóły
W grze powinien wystąpić jeden (lub więcej) z motywów: zamknięte drzwi, które trzeba jakoś otworzyć; ukryty przedmiot, który trzeba znaleźć; niekompletny przedmiot, który trzeba skompletować; ograniczone zasoby, jak czas lub pieniądze, do wykonania zadania (może to wymagać użycia arytmetyki w Prologu). Gra powinna zawierać predykat start/0 (0-argumentowy), służący do rozpoczęcia gry i dowiedzenia się jakie są dostępne polecenia (podobnie, jak w przykładowym pliku). Ponadto, dostępne powinno być polecenie inventory i jego skrót i , które informuje o przedmiotach posiadanych aktualnie przez gracza (stan ekwipunku). Granie powinno polegać na wpisywaniu zapytań.

## Przykład polecenia:
"ask policeman about corpse" z klasycznej tekstowej gry przygodowej, może mieć tu postać:
``?- ask(policeman, corpse).``
