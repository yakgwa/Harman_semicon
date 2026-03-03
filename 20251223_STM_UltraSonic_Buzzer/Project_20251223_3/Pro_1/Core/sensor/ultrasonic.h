/*
 * sensor.h
 *
 *  Created on: Dec 23, 2025
 *      Author: kccistc
 */

#ifndef ULTRASONICSENSOR_ULTRASONIC_H_
#define ULTRASONICSENSOR_ULTRASONIC_H_

#include "stm32f4xx_hal.h"

#define ULTRASONUC_TRIGGER_PORT			GPIOA
#define ULTRASONIC_TRIGGER_PIN  		GPIO_PIN_1
#define ULTRASONIC_ECHO_PIN_IC  		&htim1          // GPIO_PIN_0

void Ultrasonic_Get_Distance(void);

#endif /* ULTRASONICSENSOR_ULTRASONIC_H_ */
