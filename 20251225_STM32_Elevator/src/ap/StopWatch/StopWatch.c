/*
 * StopWatch.c
 *
 *  Created on: Dec 18, 2025
 *      Author: rhoblack
 */
#include "StopWatch.h"

stopWatch_t stopWatchData = { 0, 0, 0, 0 };
int stopWatchRunState = 0;
int stopWatchState = STOP;

hBtn btnRunStop;
hBtn btnClear;

void StopWatch_Init() {
	Button_Init(&btnRunStop, GPIOC, GPIO_PIN_11);
	Button_Init(&btnClear, GPIOC, GPIO_PIN_12);
}

void StopWatch_ISR() {
	if (stopWatchRunState)
		StopWatch_IncMSec();
}

void StopWatch_IncMSec() {
	if (stopWatchData.msec == 999) {
		stopWatchData.msec = 0;
	} else {
		stopWatchData.msec++;
		return;
	}

	if (stopWatchData.sec == 59) {
		stopWatchData.sec = 0;
	} else {
		stopWatchData.sec++;
		return;
	}

	if (stopWatchData.min == 59) {
		stopWatchData.min = 0;
	} else {
		stopWatchData.min++;
		return;
	}

	if (stopWatchData.hour == 23) {
		stopWatchData.hour = 0;
	} else {
		stopWatchData.hour++;
	}
}

void StopWatch_Clear() {
	stopWatchData.hour = 0;
	stopWatchData.min = 0;
	stopWatchData.sec = 0;
	stopWatchData.msec = 0;
}

void StopWatch_RunState() {
	stopWatchRunState = 1;
}

void StopWatch_StopState() {
	stopWatchRunState = 0;
}

void StopWatch_ClearState() {
	StopWatch_Clear();
}

void StopWatch_DispLCD() {
	char str[20];
	char *strState[2] = { "STP", "RUN" };
	static int prevMSec = 1000, prevState = STOP;
	int curMSec = stopWatchData.msec / 100;

	if ((prevMSec != curMSec) || (prevState != stopWatchState)) {
		prevMSec = curMSec;
		prevState = stopWatchState;

		if (curMSec < 5) {
			sprintf(str, "[%s]:%02d:%02d:%02d:%01d", strState[stopWatchState],
					stopWatchData.hour, stopWatchData.min, stopWatchData.sec,
					stopWatchData.msec / 100);
		} else {
			sprintf(str, "[%s]:%02d %02d %02d %01d", strState[stopWatchState],
					stopWatchData.hour, stopWatchData.min, stopWatchData.sec,
					stopWatchData.msec / 100);
		}
		LCD_WriteStringXY(1, 0, str);
	}
}

void StopWatch_Execute() {
	StopWatch_DispLCD();

	switch (stopWatchState) {
	case STOP:
		StopWatch_StopState();
		if (Button_GetState(&btnRunStop) == ACT_PUSHED) {
			stopWatchState = RUN;
		} else if (Button_GetState(&btnClear) == ACT_PUSHED) {
			stopWatchState = CLEAR;
		}
		break;
	case RUN:
		StopWatch_RunState();
		if (Button_GetState(&btnRunStop) == ACT_PUSHED) {
			stopWatchState = STOP;
		}
		break;
	case CLEAR:
		StopWatch_ClearState();
		stopWatchState = STOP;
		break;
	}
}
