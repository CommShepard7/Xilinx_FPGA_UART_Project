SRC = RxUnit.vhd \
      ../TxUnit/TxUnit.vhd    \
      diviseurClk.vhd         \
      UART.vhd \
      echoUnit.vhd  \
      ctrlUnit.vhd \
      ../clkUnit/clkUnit.vhd \
      testRxUnit.vhd \
      UART_FPGA_N4.vhd\
      


# for synthesis:
UNIT = UART_FPGA_N4
ARCH = synthesis
UCF  = UART_FPGA_N4_DDR.ucf

# for simulation:
TEST = testRxUnit
# duration (to adjust if necessary)
TIME = 8000ns
PLOT = output
