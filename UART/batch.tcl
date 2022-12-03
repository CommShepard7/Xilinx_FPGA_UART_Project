wave add -r testRxUnit
vcd dumpfile output.vcd
vcd dumpvars -m testRxUnit -l 0
run 8000ns
vcd dumpflush
exit
