/*
 * btn.h
 *
 *  Created on: Dec 12, 2025
 *      Author: kccistc
 */

#ifndef DRIVER_BTN_BTN_H_
#define DRIVER_BTN_BTN_H_

#include "stm32f4xx_hal.h"
#include <stdint.h>

enum {PUSHED, RELEASED};
typedef enum {NO_ACT, ACT_PUSHED, ACT_RELEASED} button_state_t;

typedef struct {
   GPIO_TypeDef * GPIOx;
   uint32_t pinNum;
   uint32_t prevState;
}hBtn;

// 함수 프로토타입
void Button_Init(hBtn *btn, GPIO_TypeDef * GPIOx, uint32_t pinNum);

button_state_t Button_GetState(hBtn *btn);


#endif /* DRIVER_BTN_BTN_H_ */
