################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/ap/TimeWatch/TimeWatch.c 

OBJS += \
./Core/ap/TimeWatch/TimeWatch.o 

C_DEPS += \
./Core/ap/TimeWatch/TimeWatch.d 


# Each subdirectory must supply rules for building sources it contributes
Core/ap/TimeWatch/%.o Core/ap/TimeWatch/%.su Core/ap/TimeWatch/%.cyclo: ../Core/ap/TimeWatch/%.c Core/ap/TimeWatch/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F411xE -c -I../Core/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Core-2f-ap-2f-TimeWatch

clean-Core-2f-ap-2f-TimeWatch:
	-$(RM) ./Core/ap/TimeWatch/TimeWatch.cyclo ./Core/ap/TimeWatch/TimeWatch.d ./Core/ap/TimeWatch/TimeWatch.o ./Core/ap/TimeWatch/TimeWatch.su

.PHONY: clean-Core-2f-ap-2f-TimeWatch

