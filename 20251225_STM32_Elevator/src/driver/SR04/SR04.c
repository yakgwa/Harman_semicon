/*
 * SR04.c
 *
 *  Created on: Dec 19, 2025
 *      Author: kccistc
 */

#include "SR04.h"

hSR04 sr04Data = {0, SR04_CLEAR, SR04_CLEAR};

uint32_t SR04_GetDistance() {
	return sr04Data.distance;
}

uint32_t SR04_GetState() {
	uint32_t flag = sr04Data.cmpltFlag;
	sr04Data.cmpltFlag = SR04_CLEAR;
	return flag;
}

void SR04_ConvertDistance(uint16_t microSec) {
	sr04Data.distance = (uint32_t) (microSec * 0.017);
	sr04Data.cmpltFlag = SR04_SET;
	sr04Data.busyFlag = SR04_CLEAR;
}

void SR04_Trigger() {
	if (sr04Data.busyFlag) return;

	sr04Data.cmpltFlag = SR04_CLEAR;
	sr04Data.busyFlag = SR04_SET;

	HAL_GPIO_WritePin(SR04_GPIO, SR04_PIN, GPIO_PIN_SET);
	HAL_Delay(1);
	HAL_GPIO_WritePin(SR04_GPIO, SR04_PIN, GPIO_PIN_RESET);
}
