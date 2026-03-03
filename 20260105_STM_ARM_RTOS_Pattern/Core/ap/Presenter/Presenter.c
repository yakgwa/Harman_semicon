/*
 * Presenter.c
 *
 *  Created on: Jan 5, 2026
 *      Author: kccistc
 */

#include "Presenter.h"

void Presenter_Init() {
	LCD_Init(&hi2c1);
	Presenter_StopWatch_Init();
	Presenter_Distance_Init();
	Presenter_TempHumid_Init();
}

void Presenter_Excute() {
	modeState_t modeState = Model_GetMode();

	Presenter_DispMode();
	switch (modeState) {
	case STOPWATCH_MODE:
		Presenter_StopWatch_Excute();
		break;
	case DISTANCE_MODE:
		Presenter_Distance_Excute();
		break;
	case TEMP_HUMID_MODE:
		Presenter_TempHumid_Excute();
		break;
	}
}

void Presenter_DispMode() {
	static modeState_t prevModeState = 20;
	modeState_t modeState = Model_GetMode();

	if (prevModeState == modeState) return;

	switch (modeState) {
	case STOPWATCH_MODE:
		LCD_WriteStringXY(0, 0, "STOPWATCH_MODE  ");
		break;
	case DISTANCE_MODE:
		LCD_WriteStringXY(0, 0, "DISTANCE_MODE   ");
		break;
	case TEMP_HUMID_MODE:
		LCD_WriteStringXY(0, 0, "TEMP_HUMID_MODE ");
		break;
	}
}
