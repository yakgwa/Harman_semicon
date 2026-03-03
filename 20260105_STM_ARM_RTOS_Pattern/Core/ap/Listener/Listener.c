/*
 * Listener.c
 *
 *  Created on: Jan 5, 2026
 *      Author: kccistc
 */

#include "Listener.h"

hBtn hbtnMode;

void Listener_Init() {
	Button_Init(&hbtnMode, BTN_MODE_GPIO, BTN_MODE_PIN);
	Listener_StopWatch_Init();
	Listener_Distance_Init();
	Listener_TempHumid_Init();
}

void Listener_Excute() {
	modeState_t modeState = Model_GetMode();

	Listener_CheckEvent();
	switch (modeState) {
	case STOPWATCH_MODE:
		Listener_StopWatch_Excute();
		break;
	case DISTANCE_MODE:
		Listener_Distance_Excute();
		break;
	case TEMP_HUMID_MODE:
		Listener_TempHumid_Excute();
		break;
	}
}

void Listener_CheckEvent() {
	if (Button_GetState(&hbtnMode) == ACT_RELEASED) {
		osMessagePut(modeEventMsgBox, EVENT_MODE, 0);
	}
}
