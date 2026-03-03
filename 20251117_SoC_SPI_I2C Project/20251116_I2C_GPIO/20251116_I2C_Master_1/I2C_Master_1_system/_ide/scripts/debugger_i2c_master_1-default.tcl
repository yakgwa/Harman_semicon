# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: D:\es\20251111_i2c_slave_project1\20251116_I2C_Master_1\I2C_Master_1_system\_ide\scripts\debugger_i2c_master_1-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source D:\es\20251111_i2c_slave_project1\20251116_I2C_Master_1\I2C_Master_1_system\_ide\scripts\debugger_i2c_master_1-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Basys3 210183B9AA55A" && level==0 && jtag_device_ctx=="jsn-Basys3-210183B9AA55A-0362d093-0"}
fpga -file D:/es/20251111_i2c_slave_project1/20251116_I2C_Master_1/I2C_Master_1/_ide/bitstream/design_1_wrapper.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw D:/es/20251111_i2c_slave_project1/20251116_I2C_Master_1/design_1_wrapper/export/design_1_wrapper/hw/design_1_wrapper.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow D:/es/20251111_i2c_slave_project1/20251116_I2C_Master_1/I2C_Master_1/Debug/I2C_Master_1.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con
