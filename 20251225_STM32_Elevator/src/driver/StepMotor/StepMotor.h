/*
 * StepMotor.h
 *
 *  Created on: Dec 23, 2025
 *      Author: kccistc
 */

#ifndef DRIVER_STEPMOTOR_STEPMOTOR_H_
#define DRIVER_STEPMOTOR_STEPMOTOR_H_

#include "stm32f4xx_hal.h"

#define STEP_A1_GPIO	GPIOB
#define STEP_A1_PIN		GPIO_PIN_4
#define STEP_B1_GPIO	GPIOB
#define STEP_B1_PIN		GPIO_PIN_5
#define STEP_A2_GPIO	GPIOB
#define STEP_A2_PIN		GPIO_PIN_3
#define STEP_B2_GPIO	GPIOA
#define STEP_B2_PIN		GPIO_PIN_10

typedef struct {
	GPIO_TypeDef *GPIOx;
	uint16_t GPIO_Pin;
} step_port_t;

enum {
	CW, CCW
};

extern TIM_HandleTypeDef htim4;

extern step_port_t stepA1;
extern step_port_t stepB1;
extern step_port_t stepA2;
extern step_port_t stepB2;

void StepMotor_Init();
void StepMotor_InitPin(step_port_t *stepPort, GPIO_TypeDef *GPIOx,
		uint16_t GPIO_Pin);
void StepMotor_WritePort(step_port_t *stepPort, uint8_t state);
void StepMotor_CW();
void StepMotor_CCW();
void StepMotor_Stop();
void StepMotor_Run();
void StepMotor_Speed(uint32_t speed);
void StepMotor_ISR();
void StepMotor_SetDir(int dir);

#endif /* DRIVER_STEPMOTOR_STEPMOTOR_H_ */
