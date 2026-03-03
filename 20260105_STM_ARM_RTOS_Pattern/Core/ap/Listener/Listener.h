/*
 * Listener.h
 *
 *  Created on: Jan 5, 2026
 *      Author: kccistc
 */

#ifndef AP_LISTENER_LISTENER_H_
#define AP_LISTENER_LISTENER_H_

#include "../Model/Model_Mode.h"
#include "../Model/Model_StopWatch.h"
#include "../../driver/button/button.h"
#include "Listener_Distance.h"
#include "Listener_StopWatch.h"
#include "Listener_TempHumid.h"

#define BTN_MODE_GPIO	GPIOC
#define BTN_MODE_PIN	GPIO_PIN_10

void Listener_Init();
void Listener_Excute();
void Listener_CheckEvent();

#endif /* AP_LISTENER_LISTENER_H_ */
