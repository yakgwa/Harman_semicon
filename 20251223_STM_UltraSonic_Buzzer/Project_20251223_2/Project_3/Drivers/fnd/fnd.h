/*
 * fnd.h
 *
 *  Created on: Dec 12, 2025
 *      Author: rhoblack
 */

#ifndef DRIVER_FND_FND_H_
#define DRIVER_FND_FND_H_
#include "stm32f4xx_hal.h"
#include <stdint.h>

#define FND_D1_GPIO		GPIOC
#define FND_D1_PIN		GPIO_PIN_0
#define FND_D2_GPIO		GPIOC
#define FND_D2_PIN		GPIO_PIN_1
#define FND_D3_GPIO		GPIOB
#define FND_D3_PIN		GPIO_PIN_0
#define FND_D4_GPIO		GPIOA
#define FND_D4_PIN		GPIO_PIN_4

#define FND_A_GPIO		GPIOC
#define FND_A_PIN		GPIO_PIN_3
#define FND_B_GPIO		GPIOC
#define FND_B_PIN		GPIO_PIN_2
#define FND_C_GPIO		GPIOA
#define FND_C_PIN		GPIO_PIN_1
#define FND_D_GPIO		GPIOA
#define FND_D_PIN		GPIO_PIN_0
#define FND_E_GPIO		GPIOC
#define FND_E_PIN		GPIO_PIN_13
#define FND_F_GPIO		GPIOB
#define FND_F_PIN		GPIO_PIN_7
#define FND_G_GPIO		GPIOA
#define FND_G_PIN		GPIO_PIN_15
#define FND_DP_GPIO		GPIOD
#define FND_DP_PIN		GPIO_PIN_2

enum {DIGIT_1000, DIGIT_100, DIGIT_10, DIGIT_1};

typedef struct {
	GPIO_TypeDef* GPIOx;
	uint16_t GPIO_Pin;
}FND_TypeDef;


void FND_DispDigit(uint16_t digit);
void FND_AllOff();
void FND_DigitOn(int digit);
void FND_DispNum();
void FND_ISR();
void FND_SetNum(uint16_t num);


#endif /* DRIVER_FND_FND_H_ */
