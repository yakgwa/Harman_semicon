/*
 * ap.c
 *
 *  Created on: 2025. 11. 4.
 *      Author: kccistc
 */

#include "ap.h"
//#include "sleep.h"
#include "../driver/btn/btn.h"
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
//		FND_DispNumber(counter++); // usleepø°º≠ 10000 ¡‹
//		counter++;

//		dispPowerInd();
//		runUpCounter();

//		if (Button_getState(&upBtn) == ACT_RELEASED) {
//			LED_Toggle(&led0);
//		}
		disPowerInd();
		exeUpCounter();

		ISR();
	}
}


void ISR() // Interrupt Service Routine
{
	millisCounter();

	FND_DispNumber();
}

void millisCounter() // Interrupt Service Routine
{
	incMillis();
	usleep(1000); // 1ms rest

}
