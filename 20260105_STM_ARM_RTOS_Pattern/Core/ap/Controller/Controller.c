/*
 * Controller.c
 *
 *  Created on: Jan 5, 2026
 *      Author: kccistc
 */

#include "Controller.h"

void Controller_Init() {
	Controller_StopWatch_Init();
	Controller_Distance_Init();
	Controller_TempHumid_Init();
}

void Controller_Excute() {
	modeState_t modeState = Model_GetMode();

	Controller_CheckEventMode();
	switch (modeState) {
	case STOPWATCH_MODE:
		Controller_StopWatch_Excute();
		break;
	case DISTANCE_MODE:
		Controller_Distance_Excute();
		break;
	case TEMP_HUMID_MODE:
		Controller_TempHumid_Excute();
		break;
	}
}

void Controller_CheckEventMode() {
	osEvent evt = osMessageGet(modeEventMsgBox, 0);
	uint16_t evtState;
	if (evt.status == osEventMessage) {
		evtState = evt.value.v;
		if (evtState != EVENT_MODE)
			return;

		modeState_t state = Model_GetMode();
		if (state == STOPWATCH_MODE) {
			Model_SetMode(DISTANCE_MODE);
		} else if (state == DISTANCE_MODE) {
			Model_SetMode(TEMP_HUMID_MODE);
		} else {
			Model_SetMode(STOPWATCH_MODE);
		}
	}
}
