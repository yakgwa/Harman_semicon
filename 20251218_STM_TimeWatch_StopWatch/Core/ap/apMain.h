/*
 * apMain.h
 *
 *  Created on: Dec 18, 2025
 *      Author: kccistc
 */

#ifndef AP_APMAIN_H_
#define AP_APMAIN_H_

#include "stm32f4xx_hal.h"
#include "TimeWatch/TimeWatch.h"
#include "StopWatch/StopWatch.h"
#include "../driver/lcd/lcd.h"
#include "../common/common.h"

void apMain_Init();
void apMain();

#endif /* AP_APMAIN_H_ */
