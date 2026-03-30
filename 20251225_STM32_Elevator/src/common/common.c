/*
 * common.c
 *
 *  Created on: Dec 18, 2025
 *      Author: rhoblack
 */
#include "common.h"

extern TIM_HandleTypeDef htim3;

void HAL_TIM_PeriodElapseedCallback(TIM_HandleTypeDef *htim) {
	if (htim->Instance == TIM2) { // 1ms call
		TimeWatch_ISR();
		Elevator_ISR();
		FND_ISR();
	} else if (htim->Instance == TIM3) { // 0.1s call

	} else if (htim->Instance == TIM4) {
		StepMotor_ISR();
	}
}

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin) {
	if (GPIO_Pin == GPIO_PIN_6) {
		if (HAL_GPIO_ReadPin(GPIOC, GPIO_PIN_6) == 1) {
			__HAL_TIM_SET_COUNTER(&htim3, 0);
			HAL_TIM_Base_Start(&htim3);
		} else {
			HAL_TIM_Base_Stop(&htim3);
			uint16_t counter = __HAL_TIM_GET_COUNTER(&htim3);
			SR04_ConvertDistance(counter);
		}
	} else if (GPIO_Pin & ELEV_SENSORS_MASK) {
		Elevator_ISR_Handler(GPIO_Pin);
	}
}
