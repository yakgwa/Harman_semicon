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

#define FND_COM_LIST \
    X(D1, C, 0) \
    X(D2, C, 1) \
    X(D3, B, 0) \
    X(D4, A, 4) \

#define FND_SEG_LIST \
    X(A	, C, 3	) \
    X(B	, C, 2	) \
    X(C	, A, 1	) \
    X(D	, A, 0	) \
    X(E	, C, 13	) \
    X(F	, B, 7	) \
    X(G	, A, 15 ) \
    X(DP, D, 2	) \

#define MAX_CUSTOM_FONT 20

enum {
	DIGIT_1000, DIGIT_100, DIGIT_10, DIGIT_1
};
enum {
	FND_DP_OFF, FND_DP_ON
};

typedef struct {
	GPIO_TypeDef*	GPIOx;
	uint16_t 		GPIO_Pin;
} FND_TypeDef;

typedef struct {
    uint8_t id;
    uint8_t bitmap;
} FND_FontTable;

void FND_DispDigit(uint8_t digit, int position);
void FND_AllOff();
void FND_DigitOn(int digit);
void FND_Display();
void FND_ISR();
void FND_SetNum(uint16_t num);
void FND_SetDP(int position, int state);
uint8_t FND_GetBitmap(uint8_t id);
void FND_AppendFont(uint8_t id, uint8_t bitmap);
void FND_WriteChar(int position, char c);
void FND_WriteString(char *str);

#endif /* DRIVER_FND_FND_H_ */
