/*
 * apMain.c
 *
 *  Created on: Dec 18, 2025
 *      Author: rhoblack
 */

#include "apMain.h"

extern I2C_HandleTypeDef hi2c1;
extern TIM_HandleTypeDef htim2; // 1ms timer interrupt
extern TIM_HandleTypeDef htim3;
extern UART_HandleTypeDef huart2;

enum {ELEVATOR, TIME_MODIFY, RULER_MODIFY};
hBtn btnMode;

void apMain_Init()
{
//	LCD_Init(&hi2c1);
	Elevator_Init();
	Button_Init(&btnMode, GPIOC, GPIO_PIN_9);
	Ruler_Init();
	TimeWatch_Init();
	HAL_TIM_Base_Start_IT(&htim2);
	TimeWatch_Execute();
}

void MultiElev_DispMode(int state)
{
	switch (state) {
	case ELEVATOR:
		LCD_WriteStringXY(0, 15, " ");
		break;
	case TIME_MODIFY:
		LCD_WriteStringXY(0, 15, "T");
		break;
	case RULER_MODIFY:
		LCD_WriteStringXY(0, 15, "R");
		break;
	}
}

void apMain() {
	int elevState = ELEVATOR;
	while (1) {
		MultiElev_DispMode(elevState);
		TimeWatch_Execute();
		Buzzer_Update();
		switch (elevState)
		{
		case ELEVATOR:
			Elevator_Execute();
			Ruler_Execute();
			if (Button_GetState(&btnMode) == ACT_RELEASED) {
				elevState = TIME_MODIFY;
			}
			break;
		case TIME_MODIFY:
			TimeWatch_Modify();
			if (Button_GetState(&btnMode) == ACT_RELEASED) {
				elevState = RULER_MODIFY;
			}
			break;
		case RULER_MODIFY:
			Ruler_Modify();
			if (Button_GetState(&btnMode) == ACT_RELEASED) {
				elevState = ELEVATOR;
			}
			break;
		}
	}
}
