/*
 * TimeWatch.c
 *
 *  Created on: Dec 18, 2025
 *      Author: rhoblack
 */

#include "TimeWatch.h"

int modifyState = MODI_HOUR;

timeWatch_t timeWatchData = { 12, 0, 0, 0 };

hBtn btnModiMode;
hBtn btnModiUp;

void TimeWatch_Init() {
	Button_Init(&btnModiMode, GPIOC, GPIO_PIN_11);
	Button_Init(&btnModiUp, GPIOC, GPIO_PIN_12);
}

void TimeWatch_ISR() {
	TimeWatch_IncMSec();
}

void TimeWatch_IncMSec() {
	if (timeWatchData.msec == 999) {
		timeWatchData.msec = 0;
	} else {
		timeWatchData.msec++;
		return;
	}

	if (timeWatchData.sec == 59) {
		timeWatchData.sec = 0;
	} else {
		timeWatchData.sec++;
		return;
	}

	if (timeWatchData.min == 59) {
		timeWatchData.min = 0;
	} else {
		timeWatchData.min++;
		return;
	}

	if (timeWatchData.hour == 23) {
		timeWatchData.hour = 0;
	} else {
		timeWatchData.hour++;
	}

}

void TimeWatch_DispLCD() {
	char str[80];
	char *modeStr[3] = { "hh", "mm", "ss" };
	static int prevMSec = 0, prevModifyMode = MODI_HOUR;
	int curMSec = timeWatchData.msec / 100;

	if (prevMSec != curMSec) {
		prevMSec = curMSec;
		if (curMSec < 5) {
			sprintf(str, "%02d:%02d:%02d", timeWatchData.hour,
					timeWatchData.min, timeWatchData.sec);
		} else {
			sprintf(str, "%02d %02d %02d", timeWatchData.hour,
					timeWatchData.min, timeWatchData.sec);
		}
		LCD_WriteStringXY(0, 7, str);
	}
	if (prevModifyMode != modifyState) {
		prevModifyMode = modifyState;
		LCD_WriteStringXY(0, 4, modeStr[modifyState]);
	}
}

void TimeWatch_DispFND() {
	static int prevMSec = 0;
	int curMSec = timeWatchData.msec / 100;

	if (prevMSec != curMSec) {
		prevMSec = curMSec;
		if (curMSec < 5) {
			FND_SetDP(DIGIT_100, FND_DP_ON);
		} else {
			FND_SetDP(DIGIT_100, FND_DP_OFF);
		}
	}
	FND_SetNum(timeWatchData.hour * 100 + timeWatchData.min);
}

void TimeWatch_Execute() {
	TimeWatch_DispLCD();
//	TimeWatch_DispFND();
}

void TimeWatch_Modify() {
	switch (modifyState) {
	case MODI_HOUR:
		TimeWatch_ModifyHour();
		if (Button_GetState(&btnModiMode) == ACT_RELEASED) {
			modifyState = MODI_MIN;
		}
		break;
	case MODI_MIN:
		TimeWatch_ModifyMin();
		if (Button_GetState(&btnModiMode) == ACT_RELEASED) {
			modifyState = MODI_SEC;
		}
		break;
	case MODI_SEC:
		TimeWatch_ModifySec();
		if (Button_GetState(&btnModiMode) == ACT_RELEASED) {
			modifyState = MODI_HOUR;
		}
		break;
	}
}

void TimeWatch_ModifyHour() {
	if (Button_GetState(&btnModiUp) == ACT_RELEASED) {
		if (timeWatchData.hour == 23) {
			timeWatchData.hour = 0;
		} else {
			timeWatchData.hour++;
		}
	}
}

void TimeWatch_ModifyMin() {
	if (Button_GetState(&btnModiUp) == ACT_RELEASED) {
		if (timeWatchData.min == 59) {
			timeWatchData.min = 0;
		} else {
			timeWatchData.min++;
		}
	}
}

void TimeWatch_ModifySec() {
	if (Button_GetState(&btnModiUp) == ACT_RELEASED) {
		timeWatchData.sec = 0;
		timeWatchData.msec = 0;
	}
}

