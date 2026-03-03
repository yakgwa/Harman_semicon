################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/common/common.c 

OBJS += \
./Core/common/common.o 

C_DEPS += \
./Core/common/common.d 


# Each subdirectory must supply rules for building sources it contributes
Core/common/%.o Core/common/%.su Core/common/%.cyclo: ../Core/common/%.c Core/common/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F411xE -c -I../Core/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Core-2f-common

clean-Core-2f-common:
	-$(RM) ./Core/common/common.cyclo ./Core/common/common.d ./Core/common/common.o ./Core/common/common.su

.PHONY: clean-Core-2f-common

