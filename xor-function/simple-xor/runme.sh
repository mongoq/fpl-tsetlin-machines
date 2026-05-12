#!/bin/bash

iverilog -g2012 -Wall -o tsetlin_machine_sim tsetlin_machine_tb.sv tsetlin_machine.sv

if [[ -x "./tsetlin_machine_sim" ]]; then

    echo "Executable 'tsetlin_machine_sim' found, executing."

    ./tsetlin_machine_sim

else

    echo "Executable 'tsetlin_machine_sim' not found or not executable, aborting."

    exit 1

fi
