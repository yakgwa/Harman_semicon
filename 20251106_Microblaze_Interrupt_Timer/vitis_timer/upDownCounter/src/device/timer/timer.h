/*
 * timer.h
 *
 *  Created on: 2025. 11. 6.
 *      Author: kccistc
 */

#ifndef SRC_DEVICE_TIMER_TIMER_H_
#define SRC_DEVICE_TIMER_TIMER_H_

#include <stdint.h>
#include "xparameters.h"

typedef struct {
	volatile uint32_t CR;
	volatile uint32_t PSC;
	volatile uint32_t ARR;
	volatile uint32_t CNT;
} Timer_TypeDef;

#define TIMER_0_BASEADDR XPAR_TIMER_0_S00_AXI_BASEADDR
#define TIMER_1_BASEADDR XPAR_TIMER_1_S00_AXI_BASEADDR

#define TMR0		((Timer_TypeDef *)TIMER_0_BASEADDR)
#define TMR1		((Timer_TypeDef *)TIMER_1_BASEADDR)

#define TMR_EN_PIN 0
#define TMR_INTR_EN_PIN 1

void TMR_SetPSC(Timer_TypeDef *tmr, uint32_t psc);
void TMR_SetARR(Timer_TypeDef *tmr, uint32_t arr);
uint32_t TMR_GetPSC(Timer_TypeDef *tmr);
uint32_t TMR_GetARR(Timer_TypeDef *tmr);
void TMR_Start(Timer_TypeDef *tmr);
void TMR_Stop(Timer_TypeDef *tmr);
void TMR_INTR_Start(Timer_TypeDef *tmr);
void TMR_INTR_Stop(Timer_TypeDef *tmr);
uint32_t TMR_ReadCNT(Timer_TypeDef *tmr);

#endif /* SRC_DEVICE_TIMER_TIMER_H_ */
