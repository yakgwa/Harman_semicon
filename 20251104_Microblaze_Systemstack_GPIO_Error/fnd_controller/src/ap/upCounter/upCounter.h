/*
 * upCounter.h
 *
 *  Created on: 2025. 11. 5.
 *      Author: kccistc
 */

#ifndef SRC_AP_UPCOUNTER_UPCOUNTER_H_
#define SRC_AP_UPCOUNTER_UPCOUNTER_H_
#include <stdint.h>
#include "../../driver/fnd/fnd.h"
#include "../../driver/common/millis.h"
#include "../../driver/led/led.h"
#include "../../driver/btn/btn.h"

void initUpcounter();
void runUpCounter();
void clearUpCounter();
void exeUPCounter();

#endif /* SRC_AP_UPCOUNTER_UPCOUNTER_H_ */
