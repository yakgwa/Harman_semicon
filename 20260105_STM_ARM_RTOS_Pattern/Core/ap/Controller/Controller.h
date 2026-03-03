/*
 * Controller.h
 *
 *  Created on: Jan 5, 2026
 *      Author: kccistc
 */

#ifndef AP_CONTROLLER_CONTROLLER_H_
#define AP_CONTROLLER_CONTROLLER_H_

#include <stdint.h>
#include "Controller_StopWatch.h"
#include "Controller_Distance.h"
#include "Controller_TempHumid.h"
#include "../Model/Model_Mode.h"

void Controller_Init();
void Controller_Excute();
void Controller_CheckEventMode();

#endif /* AP_CONTROLLER_CONTROLLER_H_ */
