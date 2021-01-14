#!/bin/bash

# NOTE: You *will* have to comment out some things. I'm not sure why.

printf "# Generated by generate_error.sh\n\n" > Error.gd

printf "extends Node\n\n" >> Error.gd

printf "func print_info(err):\n\tprinterr(info(err))\n\tprint_stack()\n\n" >> Error.gd

printf "func name(err):\n\tvar error_names = {}\n" >> Error.gd
sed 's/    \(.*\) = [0-9][0-9]\? — \(.*\)/\terror_names[\1] = "\1"/' errors.txt >> Error.gd
printf "\treturn error_names[err]\n\n" >> Error.gd

printf "func message(err):\n\tvar error_messages = {}\n" >> Error.gd
sed 's/    \(.*\) = [0-9][0-9]\? — \(.*\)/\terror_messages[\1] = "\2"/' errors.txt >> Error.gd
printf "\treturn error_messages[err]\n\n" >> Error.gd

printf "func info(err):\n" >> Error.gd
printf "\treturn message(err) + ' (' + name(err) + ')'\n" >> Error.gd

rm -f src/Error.gd
mv Error.gd src/
