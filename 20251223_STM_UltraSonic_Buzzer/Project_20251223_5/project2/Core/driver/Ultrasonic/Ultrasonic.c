/*
 * Ultrasonic.c
 *
 *  Created on: Dec 24, 2025
 *      Author: kccistc
 */

//#include "Ultrasonic.h"
//
//uint16_t timerCounterValue = 0;
//int ultraSonicCmpltFlag = 0;
//TIM_HandleTypeDef *phUltraSonicTim;
//
//void UltraSonic_init(TIM_HandleTypeDef *phUSonicTim)
//{
//	phUltraSonicTim = phUSonicTim;
//}
//
//int UltraSonic_getCmpltFlag()
//{
//	return ultraSonicCmpltFlag;
//}
//
//void UltraSonic_setCmpltFlag(int state)
//{
//	ultraSonicCmpltFlag = state;
//}
//
//void UltraSonic_ISR()
//{
//	int edge = HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_8);
//	if(edge){ //rising edge
//		// timer = 0, timer start
//		__HAL_TIM_SET_COUNTER(phUltraSonicTim, 0);
//		HAL_TIM_Base_Start(phUltraSonicTim);
//	}
//	else { //falling edge
//		// timer stop, timer value read
//		HAL_TIM_Base_Stop(phUltraSonicTim);
//		timerCounterValue = __HAL_TIM_GET_COUNTER(phUltraSonicTim);
//		ultraSonicCmpltFlag = 1;
//	}
//}
//
//void UltraSonic_trigger()
//{
//	HAL_GPIO_WritePin(ULTRASONIC_TRIGGER_GPIO, ULTRASONIC_TRIGGER_GPIO_PIN, GPIO_PIN_SET);
//	HAL_Delay(1);
//	HAL_GPIO_WritePin(ULTRASONIC_TRIGGER_GPIO, ULTRASONIC_TRIGGER_GPIO_PIN, GPIO_PIN_RESET);
//}
//
//int UltraSonic_getDistance()
//{
//	int distance = (int)(timerCounterValue * 0.017);
//	return distance;
//}

#include "Ultrasonic.h"

uint16_t timerCounterValue = 0;
int ultraSonicCmpltFlag = 0;
TIM_HandleTypeDef *phUltraSonicTim;

void UltraSonic_init(TIM_HandleTypeDef *phUSonicTim)
{
	phUltraSonicTim = phUSonicTim;
}

int UltraSonic_getCmpltFlag()
{
	return ultraSonicCmpltFlag;
}

void UltraSonic_setCmpltFlag(int state)
{
	ultraSonicCmpltFlag = state;
}

void UltraSonic_ISR()
{
	int edge = HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_9);
	if(edge){ //rising edge
		// timer = 0, timer start
		__HAL_TIM_SET_COUNTER(phUltraSonicTim, 0);
		HAL_TIM_Base_Start(phUltraSonicTim);
	}
	else { //falling edge
		// timer stop, timer value read
		HAL_TIM_Base_Stop(phUltraSonicTim);
		timerCounterValue = __HAL_TIM_GET_COUNTER(phUltraSonicTim);
		ultraSonicCmpltFlag = 1;
	}
}

void UltraSonic_trigger()
{
	HAL_GPIO_WritePin(ULTRASONIC_TRIGGER_GPIO, ULTRASONIC_TRIGGER_GPIO_PIN, GPIO_PIN_SET);
	HAL_Delay(1);
	HAL_GPIO_WritePin(ULTRASONIC_TRIGGER_GPIO, ULTRASONIC_TRIGGER_GPIO_PIN, GPIO_PIN_RESET);
}

int UltraSonic_getDistance()
{
	int distance = (int)(timerCounterValue * 0.017);
	return distance;
}
