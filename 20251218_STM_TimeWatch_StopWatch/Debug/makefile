################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include Drivers/STM32F4xx_HAL_Driver/Src/subdir.mk
-include Core/driver/lcd/subdir.mk
-include Core/driver/fnd/subdir.mk
-include Core/driver/button/subdir.mk
-include Core/common/subdir.mk
-include Core/ap/TimeWatch/subdir.mk
-include Core/ap/StopWatch/subdir.mk
-include Core/ap/subdir.mk
-include Core/Startup/subdir.mk
-include Core/Src/subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_DEPS)),)
-include $(S_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

OPTIONAL_TOOL_DEPS := \
$(wildcard ../makefile.defs) \
$(wildcard ../makefile.init) \
$(wildcard ../makefile.targets) \


BUILD_ARTIFACT_NAME := 251218_TimeWatch_StopWatch
BUILD_ARTIFACT_EXTENSION := elf
BUILD_ARTIFACT_PREFIX :=
BUILD_ARTIFACT := $(BUILD_ARTIFACT_PREFIX)$(BUILD_ARTIFACT_NAME)$(if $(BUILD_ARTIFACT_EXTENSION),.$(BUILD_ARTIFACT_EXTENSION),)

# Add inputs and outputs from these tool invocations to the build variables 
EXECUTABLES += \
251218_TimeWatch_StopWatch.elf \

MAP_FILES += \
251218_TimeWatch_StopWatch.map \

SIZE_OUTPUT += \
default.size.stdout \

OBJDUMP_LIST += \
251218_TimeWatch_StopWatch.list \


# All Target
all: main-build

# Main-build Target
main-build: 251218_TimeWatch_StopWatch.elf secondary-outputs

# Tool invocations
251218_TimeWatch_StopWatch.elf 251218_TimeWatch_StopWatch.map: $(OBJS) $(USER_OBJS) C:\Users\kccistc\Desktop\20251218_TimeWatch_StopWatch\STM32F411RETX_FLASH.ld makefile objects.list $(OPTIONAL_TOOL_DEPS)
	arm-none-eabi-gcc -o "251218_TimeWatch_StopWatch.elf" @"objects.list" $(USER_OBJS) $(LIBS) -mcpu=cortex-m4 -T"C:\Users\kccistc\Desktop\20251218_TimeWatch_StopWatch\STM32F411RETX_FLASH.ld" --specs=nosys.specs -Wl,-Map="251218_TimeWatch_StopWatch.map" -Wl,--gc-sections -static --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -Wl,--start-group -lc -lm -Wl,--end-group
	@echo 'Finished building target: $@'
	@echo ' '

default.size.stdout: $(EXECUTABLES) makefile objects.list $(OPTIONAL_TOOL_DEPS)
	arm-none-eabi-size  $(EXECUTABLES)
	@echo 'Finished building: $@'
	@echo ' '

251218_TimeWatch_StopWatch.list: $(EXECUTABLES) makefile objects.list $(OPTIONAL_TOOL_DEPS)
	arm-none-eabi-objdump -h -S $(EXECUTABLES) > "251218_TimeWatch_StopWatch.list"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) 251218_TimeWatch_StopWatch.elf 251218_TimeWatch_StopWatch.list 251218_TimeWatch_StopWatch.map default.size.stdout
	-@echo ' '

secondary-outputs: $(SIZE_OUTPUT) $(OBJDUMP_LIST)

fail-specified-linker-script-missing:
	@echo 'Error: Cannot find the specified linker script. Check the linker settings in the build configuration.'
	@exit 2

warn-no-linker-script-specified:
	@echo 'Warning: No linker script specified. Check the linker settings in the build configuration.'

.PHONY: all clean dependents main-build fail-specified-linker-script-missing warn-no-linker-script-specified

-include ../makefile.targets
