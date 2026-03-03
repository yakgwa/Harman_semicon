/*
 * apMain.c
 *
 *  Created on: Dec 18, 2025
 *      Author: kccistc
 */

#include "apMain.h"
extern I2C_HandleTypeDef hi2c1;
extern TIM_HandleTypeDef htim2; // 1ms timer interrupt
extern TIM_HandleTypeDef htim3;
extern UART_HandleTypeDef huart2;

enum {
	TIME_WATCH, STOP_WATCH, TIME_MODIFY
};

hBtn btnMode;

void apMain_Init() {
	LCD_Init(&hi2c1);
	StopWatch_Init();
	TimeWatch_Init();
	Button_Init(&btnMode, GPIOC, GPIO_PIN_10);
	HAL_TIM_Base_Start_IT(&htim2);
}

void SeoulWatch_DispMode(int state) {
	if (state == TIME_WATCH) {
		LCD_WriteStringXY(0, 0, "TIME  ");
		LCD_WriteStringXY(1, 0, "                ");
	} else if (state == STOP_WATCH) {
		LCD_WriteStringXY(0, 0, "SWTC  ");
	} else {
		LCD_WriteStringXY(0, 0, "MODI");
		LCD_WriteStringXY(1, 0, "                ");
	}
}

void apMain() {
	int watchState = TIME_WATCH;

	while (1) {
		SeoulWatch_DispMode(watchState);
		TimeWatch_Execute();

		switch (watchState) {
		case TIME_WATCH:
			if (Button_GetState(&btnMode) == ACT_RELEASED) {
				watchState = STOP_WATCH;
			}
			break;
		case STOP_WATCH:
			StopWatch_Execute();
			if (Button_GetState(&btnMode) == ACT_RELEASED) {
				watchState = TIME_MODIFY;
			}
			StopWatch_Execute();
			break;
		case TIME_MODIFY:
			TimeWatch_Modify();
			if (Button_GetState(&btnMode) == ACT_RELEASED) {
				watchState = TIME_WATCH;
			}
			break;
		}
	}
}

