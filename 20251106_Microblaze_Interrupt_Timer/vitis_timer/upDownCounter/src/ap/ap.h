/*
 * ap.h
 *
 *  Created on: 2025. 11. 4.
 *      Author: kccistc
 */

#ifndef SRC_AP_AP_H_
#define SRC_AP_AP_H_

#include "../driver/led/led.h"
#include "../driver/fnd/fnd.h"
#include "../driver/common/millis.h"
#include "powerind/powerind.h"
#include "upCounter/upCounter.h"

#include "sleep.h"

void ap_main();
void ISR();
void millisCounter();

#endif /* SRC_AP_AP_H_ */
