# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: C:\Users\kccistc\20251103_AXI4_FND_Test3\FND_Test\FND_Test_system\_ide\scripts\systemdebugger_fnd_test_system_standalone.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source C:\Users\kccistc\20251103_AXI4_FND_Test3\FND_Test\FND_Test_system\_ide\scripts\systemdebugger_fnd_test_system_standalone.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Basys3 210183B9AA55A" && level==0 && jtag_device_ctx=="jsn-Basys3-210183B9AA55A-0362d093-0"}
fpga -file C:/Users/kccistc/20251103_AXI4_FND_Test3/FND_Test/FND_Test/_ide/bitstream/design_1_wrapper.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw C:/Users/kccistc/20251103_AXI4_FND_Test3/FND_Test/design_1_wrapper/export/design_1_wrapper/hw/design_1_wrapper.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow C:/Users/kccistc/20251103_AXI4_FND_Test3/FND_Test/FND_Test/Debug/FND_Test.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con
