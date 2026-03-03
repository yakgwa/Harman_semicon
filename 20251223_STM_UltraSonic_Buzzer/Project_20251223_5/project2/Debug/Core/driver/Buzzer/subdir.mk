################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/driver/Buzzer/Buzzer.c 

OBJS += \
./Core/driver/Buzzer/Buzzer.o 

C_DEPS += \
./Core/driver/Buzzer/Buzzer.d 


# Each subdirectory must supply rules for building sources it contributes
Core/driver/Buzzer/%.o Core/driver/Buzzer/%.su Core/driver/Buzzer/%.cyclo: ../Core/driver/Buzzer/%.c Core/driver/Buzzer/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F411xE -c -I../Core/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Core-2f-driver-2f-Buzzer

clean-Core-2f-driver-2f-Buzzer:
	-$(RM) ./Core/driver/Buzzer/Buzzer.cyclo ./Core/driver/Buzzer/Buzzer.d ./Core/driver/Buzzer/Buzzer.o ./Core/driver/Buzzer/Buzzer.su

.PHONY: clean-Core-2f-driver-2f-Buzzer

