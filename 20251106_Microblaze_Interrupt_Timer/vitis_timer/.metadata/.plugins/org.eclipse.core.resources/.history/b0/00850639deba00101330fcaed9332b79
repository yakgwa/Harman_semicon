/*
 * ap.c
 *
 *  Created on: 2025. 11. 4.
 *      Author: kccistc
 */

#include "ap.h"
#include "../driver/btn/button.h"

hLed powerLed;
hLed upLed;
hLed downLed;
hLed led0;

hButton upBtn;

void ap_main() {
	//LED_Init(&powerLed, LED_GPIO, LED_0);
	//LED_Init(&upLed, LED_GPIO, LED_1);
	//LED_Init(&downLed, LED_GPIO, LED_2);

	//FND_Init();

	initPowerInd();
	initUpcounter();

	Button_Init(&upBtn, GPIOC, GPIO_PIN_0);
	LED_Init(&led0, GPIOB, LED_0);

	while (1) {
//		FND_DispNumber(counter++); // usleep에서 10000 줌
//		counter++;

//		dispPowerInd();
//		runUpCounter();

//		if (Button_getState(&upBtn) == ACT_RELEASED) {
//			LED_Toggle(&led0);
//		}
		dispPowerInd();
		exeUpCounter();

		ISR();
	}
}

void ISR() { // Interrupt Service Routine
	millisCounter();

	FND_DispNumber();
}

void millisCounter() {
	incMillis();
	usleep(1000);
}
