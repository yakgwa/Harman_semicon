/*
 * timer.c
 *
 *  Created on: 2025. 11. 6.
 *      Author: kccistc
 */

#include "timer.h"

void TMR_SetPSC(Timer_TypeDef *tmr, uint32_t psc)
{
	tmr->PSC = psc;
}


void TMR_SetARR(Timer_TypeDef *tmr, uint32_t arr)
{
	tmr->ARR = arr;
}


uint32_t TMR_GetPSC(Timer_TypeDef *tmr)
{
	return tmr->PSC;
}


uint32_t TMR_GetARR(Timer_TypeDef *tmr)
{
	return tmr->ARR;
}


void TMR_Start(Timer_TypeDef *tmr)
{
	tmr->CR |= (1<<TMR_EN_PIN);
}

void TMR_Stop(Timer_TypeDef *tmr)
{
	tmr->CR &= ~(1<<TMR_EN_PIN);
}

void TMR_INTR_Start(Timer_TypeDef *tmr)
{
	tmr->CR |= (1<<TMR_INTR_EN_PIN);
}

void TMR_INTR_Stop(Timer_TypeDef *tmr)
{
	tmr->CR &= ~(1<<TMR_INTR_EN_PIN);
}

uint32_t TMR_ReadCNT(Timer_TypeDef *tmr)
{
	return tmr->CNT;
}

