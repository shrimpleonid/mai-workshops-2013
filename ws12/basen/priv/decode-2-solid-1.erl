#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -sname decoder
%%
%%  Простая программа перевода двоичных октетов входного потока,
%%  в байты выходного потока. На вход подаются строка, например:
%%      010010000110010101101100011011000110111100001010
%%  В результате работы программы она будет переведена в строку `Hello`
%%

main(_) ->
    % Считываем 8 символов.
    case io:get_chars('', 8) of
        eof -> 
            % Если это конец файла, останавливаем программу.
            init:stop();
        "\n" ->
            % Если это перевод строки, то просто его выводим.
            io:format("~n");
        String ->
            % В противном случае, переводим строку в число.
            Byte = erlang:list_to_integer(String, 2),
            % Выводим число как символ.
            io:format("~c", [Byte]),
            % Повторяем цикл, вызывая функцию рекурсивно.
            main([])
    end.
