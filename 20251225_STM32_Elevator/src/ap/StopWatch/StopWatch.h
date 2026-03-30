/*
 * StopWatch.h
 *
 *  Created on: Dec 18, 2025
 *      Author: rhoblack
 */

#ifndef AP_STOPWATCH_STOPWATCH_H_
#define AP_STOPWATCH_STOPWATCH_H_

#include <stdio.h>
#include "stm32f4xx_hal.h"
#include "../../driver/button/button.h"
#include "../../driver/lcd/lcd.h"

typedef struct {
	int hour;
	int min;
	int sec;
	int msec;
} stopWatch_t;

enum {
	STOP, RUN, CLEAR
};

void StopWatch_Init();
void StopWatch_ISR();
void StopWatch_IncMSec();
void StopWatch_Clear();
void StopWatch_RunState();
void StopWatch_StopState();
void StopWatch_ClearState();
void StopWatch_DispLCD();
void StopWatch_Execute();

#endif /* AP_STOPWATCH_STOPWATCH_H_ */
