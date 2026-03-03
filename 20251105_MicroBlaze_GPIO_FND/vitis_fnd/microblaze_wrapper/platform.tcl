# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\kccistc\NEW_HARMAN_Work\20251104_MicroBlaze_GPIO_FND\vitis_fnd\microblaze_wrapper\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\kccistc\NEW_HARMAN_Work\20251104_MicroBlaze_GPIO_FND\vitis_fnd\microblaze_wrapper\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {microblaze_wrapper}\
-hw {C:\Users\kccistc\NEW_HARMAN_Work\20251104_MicroBlaze_GPIO_FND\vitis_fnd\microblaze_wrapper.xsa}\
-fsbl-target {psu_cortexa53_0} -out {C:/Users/kccistc/NEW_HARMAN_Work/20251104_MicroBlaze_GPIO_FND/vitis_fnd}

platform write
domain create -name {standalone_microblaze_0} -display-name {standalone_microblaze_0} -os {standalone} -proc {microblaze_0} -runtime {cpp} -arch {32-bit} -support-app {empty_application}
platform generate -domains 
platform active {microblaze_wrapper}
platform generate -quick
platform generate
platform generate -domains standalone_microblaze_0 
platform generate -domains standalone_microblaze_0 
