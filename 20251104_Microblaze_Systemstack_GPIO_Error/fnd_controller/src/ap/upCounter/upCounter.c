/*
 * upCounter.c
 *
 *  Created on: 2025. 11. 5.
 *      Author: kccistc
 */
#include "upCounter.h"

enum { STOP,RUN,CLEAR };

int upCounterState = STOP;
int counter = 0;

hLed upLed;
hLed downLed;

hButton btnRunStop;
hButton btnClear;

void initUpcounter() {
	upCounterState = STOP;
	counter = 0;

	FND_Init();

	LED_Init(&upLed, LED_GPIO, LED_1);
	LED_Init(&downLed, LED_GPIO, LED_2);

	Button_Init(&btnRunStop, BUTTON_GPIO, BUTTON_0); // UP Button
	Button_Init(&btnClear, BUTTON_GPIO, BUTTON_1);   // Left Button
}


void exeUpCounter() {
	switch (upCounterState)
	{
		case STOP:
			if (Button_getState(&btnRunStop) == ACT_PUSHED) {
				upCounterState = RUN;
			} else if (Button_getState(&btnClear) == ACT_PUSHED) {
				upCounterState = CLEAR;
			}
			break;
		case RUN:
			runUpCounter();
			if (Button_getState(&btnRunStop) == ACT_PUSHED) {
				upCounterState = STOP;
			}
			break;
		case CLEAR:
			clearUpCounter();
			upCounterState = STOP;
			break;
	}
}


void runUpCounter() {
	static uint32_t prevTime = 0;
	uint32_t curTime = millis();

	if (curTime - prevTime < 100) return;
	prevTime = curTime;

	FND_SetNumber(counter++);
	LED_Off(&downLed);
	LED_Toggle(&upLed);
}


void clearUpCounter() {
	counter = 0;
	FND_SetNumber(counter);
}

//enum {STOP, RUN, CLEAR};
//
//int upCounterState = STOP;
//int counter = 0;
//hLed upLed;
//hLed downLed;
//hButton btnRunStop;
//hButton btnClear;
//
//void initUpCounter()
//{
//	upCounterState = STOP;
//	counter = 0;
//	FND_Init();
//	LED_Init(&upLed, LED_GPIO, LED_1);
//	LED_Init(&downLed, LED_GPIO, LED_2);
//
//	Button_Init(&btnRunStop, BUTTON_GPIO, BUTTON_0);
//	Button_Init(&btnClear, BUTTON_GPIO, BUTTON_1);
//}
//
//void exeUpCounter()
//{
//	switch(upCounterState)
//	{
//	case STOP :
//		if(Button_getState(&btnRunStop) == ACT_PUSHED){
//			upCounterState = RUN;
//		}
//		else if(Button_getState(&btnClear) == ACT_PUSHED){
//			upCounterState = CLEAR;
//		}
//		break;
//	case RUN :
//		runUpCounter();
//		if(Button_getState(&btnRunStop) == ACT_PUSHED){
//			upCounterState = STOP;
//		}
//		break;
//	case CLEAR :
//		clearUpCounter();
//		upCounterState = STOP;
//		break;
//	}
//}
//
//void runUpCounter()
//{
//	static uint32_t prevTime = 0;
//	uint32_t curTime = millis();
//	if(curTime - prevTime < 100) return;
//	prevTime = curTime;
//
//	FND_SetNumber(counter++);
//	LED_Off(&downLed);
//	LED_Toggle(&upLed);
//}
//
//void clearUpCounter()
//{
//	counter = 0;
//	FND_SetNumber(counter);
//}
