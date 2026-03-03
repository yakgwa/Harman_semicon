################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/sensor/ultrasonic.c 

OBJS += \
./Core/sensor/ultrasonic.o 

C_DEPS += \
./Core/sensor/ultrasonic.d 


# Each subdirectory must supply rules for building sources it contributes
Core/sensor/%.o Core/sensor/%.su Core/sensor/%.cyclo: ../Core/sensor/%.c Core/sensor/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F411xE -c -I../Core/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Core-2f-sensor

clean-Core-2f-sensor:
	-$(RM) ./Core/sensor/ultrasonic.cyclo ./Core/sensor/ultrasonic.d ./Core/sensor/ultrasonic.o ./Core/sensor/ultrasonic.su

.PHONY: clean-Core-2f-sensor

