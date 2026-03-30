/*
 * PhotoInterrupter.c
 *
 *  Created on: Dec 26, 2025
 *      Author: kccistc
 */

#include "PhotoInterrupter.h"

void PhotoInt_Init(hPhotoInt *pInt, GPIO_TypeDef *GPIOx, uint32_t pinNum) {
	pInt->GPIOx = GPIOx;
	pInt->pinNum = pinNum;
	pInt->onBlocked = NULL;
	pInt->arg = NULL;
}

uint32_t PhotoInt_GetState(hPhotoInt *pInt) {
	uint32_t curState = HAL_GPIO_ReadPin(pInt->GPIOx, pInt->pinNum);
	return curState;
}

void PhotoInt_RegisterCallback(hPhotoInt *pInt, PhotoIntCallback cb, void *arg) {
	if (pInt != NULL) {
		pInt->onBlocked = cb;
		pInt->arg = arg;
	}
}

void PhotoInt_ISR_Handler(hPhotoInt *pInt) {
	if (pInt != NULL && pInt->onBlocked != NULL) {
		pInt->onBlocked(pInt->arg);
	}
}
