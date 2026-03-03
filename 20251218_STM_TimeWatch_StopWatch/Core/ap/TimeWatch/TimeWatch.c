/*
 * TimeWatch.c
 *
 *  Created on: Dec 18, 2025
 *      Author: kccistc
 */
#include <stdio.h>
#include "TimeWatch.h"

TimeWatch_t TimeWatchData = { 12, 0, 0, 0 };
enum {
	MODI_HOUR, MODI_MIN, MODI_SEC
};

int modifyState = MODI_HOUR;

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
	if (TimeWatchData.msec == 999) {
		TimeWatchData.msec = 0;
	} else {
		TimeWatchData.msec++;
		return;
	}

	if (TimeWatchData.sec == 59) {
		TimeWatchData.sec = 0;
	} else {
		TimeWatchData.sec++;
		return;
	}

	if (TimeWatchData.min == 59) {
		TimeWatchData.min = 0;
	} else {
		TimeWatchData.min++;
		return;
	}
	if (TimeWatchData.hour == 23) {
		TimeWatchData.hour = 0;
	} else {
		TimeWatchData.hour++;
	}
}

void TimeWatch_DispLCD() {
	char str[80];
	char *modeStr[3] = { "hh", "mm", "ss" };
	static int prevMSec = 0, prevModifyMode = MODI_HOUR;
	int curMSec = TimeWatchData.msec / 100;

	if (prevMSec != curMSec) {
		prevMSec = curMSec;
		if (curMSec < 5) {
			sprintf(str, "%02d:%02d:%02d", TimeWatchData.hour,
					TimeWatchData.min, TimeWatchData.sec);
		} else {
			sprintf(str, "%02d %02d %02d", TimeWatchData.hour,
					TimeWatchData.min, TimeWatchData.sec);
		}
		LCD_WriteStringXY(0, 6, str);
	}
	if (prevModifyMode != modifyState) {
		prevModifyMode = modifyState;
		LCD_WriteStringXY(0, 4, modeStr[modifyState]);
	}
}

void TimeWatch_Execute() {
	TimeWatch_DispLCD();
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
		if (TimeWatchData.hour == 23) {
			TimeWatchData.hour = 0;
		} else {
			TimeWatchData.hour++;
		}
	}
}

void TimeWatch_ModifyMin() {
	if (Button_GetState(&btnModiUp) == ACT_RELEASED) {
		if (TimeWatchData.min == 59) {
			TimeWatchData.min = 0;
		} else {
			TimeWatchData.min++;
		}
	}
}

void TimeWatch_ModifySec() {
	if (Button_GetState(&btnModiUp) == ACT_RELEASED) {
		TimeWatchData.sec = 0;
		TimeWatchData.msec = 0;
	}
}

