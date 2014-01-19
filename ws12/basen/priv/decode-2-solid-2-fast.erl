#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -sname decoder
%%
%%  Простая и быстрая программа перевода двоичных октетов входного потока,
%%  в байты выходного потока. На вход подаются строка, например:
%%      010010000110010101101100011011000110111100001010
%%  В результате работы программы она будет переведена в строку `Hello`.
%%  WARNING:
%%      Не пытайтесь дословно воспроизвести всю логику в программе на Си.
%%      Erlang имеет иную парадигму программирования. 
%%      В отличие от Си он основан не на машине фон Неймана.
%%      Однако, на уровне идеи логика будет сходной.
%%

main(_) ->
    % Считываем 131072 символа (128 КиБ).
    % На самом деле тут все равно сколько считывать.
    % Но удобнее, если это число будет кратно количеству байт, 
    % представляющих закодированный символ.
    case io:get_chars('', 131072) of
        eof -> 
            % Если это конец файла, останавливаем программу.
            init:stop();
        "\n" ->
            % Если это перевод строки, то ничего не делаем,
            % просто повторяем итерацию.
            main([]);
        Input ->
            % Иначе разберем входную строку вручную, 
            % и получим перекодированную строку.
            Output = parse(Input),
            % Выведем строку как строку.
            io:format("~s", [Output]),
            % Повторяем итерацию.
            main([])
    end.

%%
%% @doc Разбирает входной список символов и декодирует его.
%% @spec parse(list()) -> list().
%%
parse(List) ->
    parse(List, []).

%%
%% @doc Разбирает входной список символов и декодирует его.
%%      Первый параметр это входной список, 
%%      во втором параметре накапливаются значения выходного списка.
%%      Функция состоит из трех уравнений.
%%          *   Первое уравнение срабатывает если входной список пуст 
%%              (т.е. мы уже все разобрали). Тогда просто возвращаем выходной 
%%              список, предварительно перевернув его.
%%          *   Второе уравнение срабатывает, если мы встретили символ 
%%              перевода строки. Тогда откусываем, этот символ 
%%              от входного списка, во входной список следующей итерации 
%%              кладем то, что осталось, а выходной список 
%%              оставляем без изменения.
%%          *   Третье уравнение срабатывает, когда во входном списке есть,
%%              восемь символов. Откусываем от входного списка восемь элементов,
%%              кладем, что осталось во входной список следующей итерации.
%%              Вычисляем результирующий символ по схеме Горнера 
%%              и добавляем его в начало выходного списка.
%% @spec parse(list(), list()) -> list().
%%
parse([], Acc) ->
    lists:reverse(Acc);

parse([$\n| Rest], Acc) ->
    parse(Rest, Acc);

parse([X1,X2,X3,X4,X5,X6,X7,X8| Rest], Acc) ->
    % Вычислим многочлен по основанию 2 по схеме Горнера.
    Number = 
        (
            (
                (
                    (
                        (
                            (
                                (
                                    (
                                        (
                                            (
                                                (
                                                    (
                                                        convert(X1) 
                                                        * 2
                                                    ) + convert(X2)
                                                ) * 2
                                            ) + convert(X3)
                                        ) * 2
                                    ) + convert(X4)
                                ) * 2
                            ) + convert(X5)
                        ) * 2
                    ) + convert(X6)
                ) * 2
            ) + convert(X7)
        ) * 2 
        + convert(X8),
    parse(
        Rest, % Остаток входного списка.
        [Number|Acc] % Добавка к выходному списку.
    ).

%%
%% @doc Переводит символ в число.
%%      Просто отнимаем от входного символа код символа '0'.
%% @spec convert(integer()) -> integer()
%% 
convert(X) ->
    X - $0.