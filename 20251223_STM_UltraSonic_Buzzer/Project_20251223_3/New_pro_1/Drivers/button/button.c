/*
 * btn.c
 *
 *  Created on: Dec 12, 2025
 *      Author: kccistc
 */

#include "button.h"


void Button_Init(hBtn *btn, GPIO_TypeDef * GPIOx, uint32_t pinNum)
{
   btn->GPIOx = GPIOx;
   btn->pinNum = pinNum;
   btn->prevState = RELEASED;
}

button_state_t Button_GetState(hBtn *btn)
{
    uint32_t curState;
    curState = HAL_GPIO_ReadPin(btn->GPIOx, btn->pinNum);

    if ((btn->prevState == RELEASED) && (curState == PUSHED)) {
        // debounce
        btn->prevState = PUSHED;
        return ACT_PUSHED;
    }
    else if((btn->prevState == PUSHED) && (curState == RELEASED)) {
        // debounce
        btn->prevState = RELEASED;
        return ACT_RELEASED;
    }
    return NO_ACT;
}



