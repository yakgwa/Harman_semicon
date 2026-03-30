/*
 * Ruler.h
 *
 *  Created on: Dec 24, 2025
 *      Author: kccistc
 */

#ifndef AP_RULER_RULER_H_
#define AP_RULER_RULER_H_

#include <stdio.h>
#include "stm32f4xx_hal.h"
#include "../driver/SR04/SR04.h"
#include "../driver/button/button.h"
#include "../driver/fnd/fnd.h"
#include "../driver/lcd/lcd.h"

void Ruler_Init();
void Ruler_Execute();
void Ruler_Modify();
void Ruler_DispLCD();
void Ruler_DispLCD_Offset();
void Ruler_DispFND();

#endif /* AP_RULER_RULER_H_ */
