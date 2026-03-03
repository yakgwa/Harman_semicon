simSetSimulator "-vcssv" -exec "simv" -args "test=cctv_test"
debImport "-dbdir" "simv.daidir"
debLoadSimResult /home/pedu04/dev/tb_test/cctv_top.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
verdiWindowResize -win $_Verdi_1 "8" "31" "2560" "1369"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb_top"
wvGetSignalSetScope -win $_nWave2 "/tb_top/dut/U_UART_TOP"
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_top/dut/U_UART_TOP/U_RX_FIFO/i_push_data\[7:0\]} -height 16 \
{/tb_top/dut/U_UART_TOP/U_RX_FIFO/o_pop_data\[7:0\]} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 )} 
wvSetPosition -win $_nWave2 {("G1" 2)}
wvGetSignalSetScope -win $_nWave2 "/tb_top/dut/U_UART_TOP/U_TX_FIFO"
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_top/dut/U_UART_TOP/U_RX_FIFO/i_push_data\[7:0\]} -height 16 \
{/tb_top/dut/U_UART_TOP/U_RX_FIFO/o_pop_data\[7:0\]} -height 16 \
{/tb_top/dut/U_UART_TOP/U_TX_FIFO/i_push_data\[7:0\]} -height 16 \
{/tb_top/dut/U_UART_TOP/U_TX_FIFO/o_pop_data\[7:0\]} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 3 4 )} 
wvSetPosition -win $_nWave2 {("G1" 4)}
wvGetSignalClose -win $_nWave2
wvSetCursor -win $_nWave2 27704629.467505 -snap {("G1" 3)}
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 26955855.698113 28546999.958071
wvSetCursor -win $_nWave2 27853834.806665 -snap {("G1" 3)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 100424219.355542 -snap {("G1" 1)}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb_top"
wvGetSignalSetScope -win $_nWave2 "/tb_top/dut"
wvGetSignalSetScope -win $_nWave2 "/tb_top/dut/U_UART_TOP"
wvGetSignalSetScope -win $_nWave2 "/tb_top/dut/U_UART_TOP/U_RX_FIFO"
wvGetSignalSetScope -win $_nWave2 "/tb_top/dut/U_UART_TOP/U_TX_FIFO"
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_top/dut/U_UART_TOP/U_RX_FIFO/i_push_data\[7:0\]} -height 16 \
{/tb_top/dut/U_UART_TOP/U_RX_FIFO/o_pop_data\[7:0\]} -height 16 \
{/tb_top/dut/U_UART_TOP/U_TX_FIFO/i_push_data\[7:0\]} -height 16 \
{/tb_top/dut/U_UART_TOP/U_TX_FIFO/o_pop_data\[7:0\]} -height 16 \
{/tb_top/dut/U_UART_TOP/U_TX_FIFO/i_push_data\[7:0\]} -height 16 \
{/tb_top/dut/U_UART_TOP/U_TX_FIFO/o_pop_data\[7:0\]} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 5 6 )} 
wvSetPosition -win $_nWave2 {("G1" 6)}
wvGetSignalClose -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 6 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetCursor -win $_nWave2 112037904.587136 -snap {("G1" 3)}
wvZoom -win $_nWave2 107255798.903538 118186326.180332
wvZoom -win $_nWave2 114606979.512295 114712389.209304
