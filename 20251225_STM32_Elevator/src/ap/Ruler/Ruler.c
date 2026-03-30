/*
 * Ruler.c
 *
 *  Created on: Dec 24, 2025
 *      Author: kccistc
 */

#include "Ruler.h"

hBtn btnSetOffset;
hBtn btnMeasureDist;

static uint32_t offset = 0;

void Ruler_Init() {
	Button_Init(&btnSetOffset, GPIOC, GPIO_PIN_11);
	Button_Init(&btnMeasureDist, GPIOC, GPIO_PIN_12);
}

void Ruler_Execute() {
	static uint32_t prevTick = 0;
	if (HAL_GetTick() - prevTick >= 1000) {
		prevTick = HAL_GetTick();
		SR04_Trigger();
	}
	if (SR04_GetState() == SR04_SET) {
		Ruler_DispLCD_Offset();
	}
}

void Ruler_Modify() {
	char str[80];
	if (Button_GetState(&btnMeasureDist) == ACT_RELEASED) {
		SR04_Trigger();
	}
	if (SR04_GetState() == SR04_SET) {
		Ruler_DispLCD();
	}
	if (Button_GetState(&btnSetOffset) == ACT_RELEASED) {
		offset = SR04_GetDistance();
		sprintf(str, "O:%2dcm", (int) offset);
		LCD_WriteStringXY(1, 10, str);
	}
}

void Ruler_DispLCD() {
	char str[80];
	uint32_t curDist = SR04_GetDistance();
	sprintf(str, "H:%02dcm", (int) curDist);
	LCD_WriteStringXY(1, 10, str);
}

void Ruler_DispLCD_Offset() {
	char str[80];
	uint32_t curDist = SR04_GetDistance();
	int dist = (int) (curDist) - (int) (offset);
	sprintf(str, "H:%02dcm", (dist > -1) ? dist : (int) curDist);
	LCD_WriteStringXY(1, 10, str);
}

void Ruler_DispFND() {
	uint32_t curDist = SR04_GetDistance();
	FND_SetDP(DIGIT_10, FND_DP_ON);
	FND_SetNum((int) curDist);
}
