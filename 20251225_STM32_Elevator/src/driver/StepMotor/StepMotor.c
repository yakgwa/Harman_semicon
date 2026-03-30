/*
 * StepMotor.c
 *
 *  Created on: Dec 23, 2025
 *      Author: kccistc
 */

#include "StepMotor.h"

step_port_t stepA1;
step_port_t stepB1;
step_port_t stepA2;
step_port_t stepB2;

int stepDir = CW;

void StepMotor_Init() {
	StepMotor_InitPin(&stepA1, STEP_A1_GPIO, STEP_A1_PIN);
	StepMotor_InitPin(&stepB1, STEP_B1_GPIO, STEP_B1_PIN);
	StepMotor_InitPin(&stepA2, STEP_A2_GPIO, STEP_A2_PIN);
	StepMotor_InitPin(&stepB2, STEP_B2_GPIO, STEP_B2_PIN);
}

void StepMotor_InitPin(step_port_t *stepPort, GPIO_TypeDef *GPIOx,
		uint16_t GPIO_Pin) {
	stepPort->GPIOx = GPIOx;

stepPort->GPIO_Pin = GPIO_Pin;
}

void StepMotor_WritePort(step_port_t *stepPort, uint8_t state) {
	HAL_GPIO_WritePin(stepPort->GPIOx, stepPort->GPIO_Pin, state);
}

void StepMotor_CW() {
	static uint8_t stepMotorPhase = 0;
	stepMotorPhase = (stepMotorPhase + 1) % 4;

	switch (stepMotorPhase) {
	case 0:
		StepMotor_WritePort(&stepA1, SET);
		StepMotor_WritePort(&stepB1, SET);
		StepMotor_WritePort(&stepA2, RESET);
		StepMotor_WritePort(&stepB2, RESET);
		break;
	case 1:
		StepMotor_WritePort(&stepA1, RESET);
		StepMotor_WritePort(&stepB1, SET);
		StepMotor_WritePort(&stepA2, SET);
		StepMotor_WritePort(&stepB2, RESET);
		break;
	case 2:
		StepMotor_WritePort(&stepA1, RESET);
		StepMotor_WritePort(&stepB1, RESET);
		StepMotor_WritePort(&stepA2, SET);
		StepMotor_WritePort(&stepB2, SET);
		break;
	case 3:
		StepMotor_WritePort(&stepA1, SET);
		StepMotor_WritePort(&stepB1, RESET);
		StepMotor_WritePort(&stepA2, RESET);
		StepMotor_WritePort(&stepB2, SET);
		break;
	}
}

void StepMotor_CCW() {
	static uint8_t stepMotorPhase = 0;
	stepMotorPhase = (stepMotorPhase + 1) % 4;

	switch (stepMotorPhase) {
	case 0:
		StepMotor_WritePort(&stepA1, SET);
		StepMotor_WritePort(&stepB1, RESET);
		StepMotor_WritePort(&stepA2, RESET);
		StepMotor_WritePort(&stepB2, SET);
		break;
	case 1:
		StepMotor_WritePort(&stepA1, RESET);
		StepMotor_WritePort(&stepB1, RESET);
		StepMotor_WritePort(&stepA2, SET);
		StepMotor_WritePort(&stepB2, SET);
		break;
	case 2:
		StepMotor_WritePort(&stepA1, RESET);
		StepMotor_WritePort(&stepB1, SET);
		StepMotor_WritePort(&stepA2, SET);
		StepMotor_WritePort(&stepB2, RESET);
		break;
	case 3:
		StepMotor_WritePort(&stepA1, SET);
		StepMotor_WritePort(&stepB1, SET);
		StepMotor_WritePort(&stepA2, RESET);
		StepMotor_WritePort(&stepB2, RESET);
		break;
	}
}

void StepMotor_Stop() {
	HAL_TIM_Base_Stop_IT(&htim4);
}

void StepMotor_Run() {
	HAL_TIM_Base_Start_IT(&htim4);
}

void StepMotor_Speed(uint32_t speed) {
	__HAL_TIM_SET_AUTORELOAD(&htim4, speed);
}

void StepMotor_ISR() {
	switch (stepDir) {
	case CW:
		StepMotor_CW();
		break;
	case CCW:
		StepMotor_CCW();
		break;
	}
}

void StepMotor_SetDir(int dir) {
	stepDir = dir;
}
