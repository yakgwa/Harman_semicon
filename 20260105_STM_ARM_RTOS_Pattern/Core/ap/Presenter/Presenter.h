/*
 * Presenter.h
 *
 *  Created on: Jan 5, 2026
 *      Author: kccistc
 */

#ifndef AP_PRESENTER_PRESENTER_H_
#define AP_PRESENTER_PRESENTER_H_

#include "Presenter_Distance.h"
#include "Presenter_StopWatch.h"
#include "Presenter_TempHumid.h"
#include "../Model/Model_Mode.h"
#include "../../driver/lcd/lcd.h"
#include "i2c.h"

void Presenter_Init();
void Presenter_Excute();
void Presenter_DispMode();

#endif /* AP_PRESENTER_PRESENTER_H_ */
