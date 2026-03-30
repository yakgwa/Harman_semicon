/*
 * SR04.h
 *
 *  Created on: Dec 19, 2025
 *      Author: kccistc
 */

#ifndef DRIVER_SR04_SR04_H_
#define DRIVER_SR04_SR04_H_

#include <stdint.h>
#include "stm32f4xx_hal.h"

#define SR04_GPIO	GPIOC
#define SR04_PIN	GPIO_PIN_8
typedef struct {
	uint32_t distance;
	uint32_t cmpltFlag;
	uint32_t busyFlag;
} hSR04;

enum {
	SR04_CLEAR, SR04_SET
};

extern hSR04 SR04Data;

uint32_t SR04_GetDistance();
uint32_t SR04_GetState();
void SR04_ConvertDistance(uint16_t microSec);
void SR04_Trigger();

#endif /* DRIVER_SR04_SR04_H_ */
