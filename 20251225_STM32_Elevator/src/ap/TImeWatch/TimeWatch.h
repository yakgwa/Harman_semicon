/*
 * TimeWatch.h
 *
 *  Created on: Dec 18, 2025
 *      Author: rhoblack
 */

#ifndef AP_TIMEWATCH_TIMEWATCH_H_
#define AP_TIMEWATCH_TIMEWATCH_H_

#include <stdio.h>
#include "stm32f4xx_hal.h"
#include "../../driver/lcd/lcd.h"
#include "../../driver/fnd/fnd.h"
#include "../../driver/button/button.h"

typedef struct {
	int hour;
	int min	;
	int sec	;
	int msec;
} timeWatch_t;

enum {
	MODI_HOUR, MODI_MIN, MODI_SEC
};

void TimeWatch_Init();
void TimeWatch_ISR();
void TimeWatch_IncMSec();
void TimeWatch_DispLCD();
void TimeWatch_DispFND();
void TimeWatch_Execute();
void TimeWatch_Modify();
void TimeWatch_ModifyHour();
void TimeWatch_ModifyMin();
void TimeWatch_ModifySec();

#endif /* AP_TIMEWATCH_TIMEWATCH_H_ */
