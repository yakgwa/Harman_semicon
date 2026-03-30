/*
 * PhotoInterrupter.h
 *
 *  Created on: Dec 26, 2025
 *      Author: kccistc
 */

#ifndef DRIVER_PHOTOINTERRUPTER_PHOTOINTERRUPTER_H_
#define DRIVER_PHOTOINTERRUPTER_PHOTOINTERRUPTER_H_

#include "stm32f4xx_hal.h"
#include <stdint.h>

typedef void (*PhotoIntCallback)(void *arg);

typedef struct {
	GPIO_TypeDef *GPIOx;
	uint16_t pinNum;
	PhotoIntCallback onBlocked;
	void *arg;
} hPhotoInt;

void PhotoInt_Init(hPhotoInt *pInt, GPIO_TypeDef *GPIOx, uint32_t pinNum);
uint32_t PhotoInt_GetState(hPhotoInt *pInt);
void PhotoInt_RegisterCallback(hPhotoInt *pInt, PhotoIntCallback cb, void *arg);
void PhotoInt_ISR_Handler(hPhotoInt *pInt);
#endif /* DRIVER_PHOTOINTERRUPTER_PHOTOINTERRUPTER_H_ */
