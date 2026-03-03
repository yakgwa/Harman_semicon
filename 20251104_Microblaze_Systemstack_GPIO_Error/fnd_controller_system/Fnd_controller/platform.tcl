# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\kccistc\20251104_Microblaze_Systemstack\fnd_controller_system\Fnd_controller\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\kccistc\20251104_Microblaze_Systemstack\fnd_controller_system\Fnd_controller\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {Fnd_controller}\
-hw {C:\Users\kccistc\20251104_Microblaze_Systemstack\design_1_wrapper.xsa}\
-proc {microblaze_0} -os {standalone} -fsbl-target {psu_cortexa53_0} -out {C:/Users/kccistc/20251104_Microblaze_Systemstack/fnd_controller_system}

platform write
platform generate -domains 
platform active {Fnd_controller}
bsp reload
