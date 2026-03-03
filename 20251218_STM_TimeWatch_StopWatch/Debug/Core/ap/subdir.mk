################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/ap/apMain.c 

OBJS += \
./Core/ap/apMain.o 

C_DEPS += \
./Core/ap/apMain.d 


# Each subdirectory must supply rules for building sources it contributes
Core/ap/%.o Core/ap/%.su Core/ap/%.cyclo: ../Core/ap/%.c Core/ap/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F411xE -c -I../Core/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Core-2f-ap

clean-Core-2f-ap:
	-$(RM) ./Core/ap/apMain.cyclo ./Core/ap/apMain.d ./Core/ap/apMain.o ./Core/ap/apMain.su

.PHONY: clean-Core-2f-ap

