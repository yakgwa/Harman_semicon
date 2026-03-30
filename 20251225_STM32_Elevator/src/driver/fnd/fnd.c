/*
 * fnd.c
 *
 *  Created on: Dec 12, 2025
 *      Author: rhoblack
 */
#include "fnd.h"

const FND_TypeDef fndDigitCom[4] = {
#define X(name, port, pin) {GPIO##port, GPIO_PIN_##pin},
		FND_COM_LIST
#undef X
		};

const FND_TypeDef fndPin[8] = {
#define X(name, port, pin) {GPIO##port, GPIO_PIN_##pin},
		FND_SEG_LIST
#undef X
		};

FND_FontTable customFonts[MAX_CUSTOM_FONT];
int customFontCount = 0;
uint16_t fndDP[4] = { 0 };
uint16_t fndDispBuffer[4];

void FND_ISR() {
	FND_Display();
}

void FND_SetNum(uint16_t num) {
	fndDispBuffer[0] = (num / 1000) % 10;
	fndDispBuffer[1] = (num / 100) % 10;
	fndDispBuffer[2] = (num / 10) % 10;
	fndDispBuffer[3] = num % 10;
}

uint8_t FND_GetBitmap(uint8_t id) {
	const uint8_t basicFont[10] = { 0x3f, // 0 => 0011 1111
			0x06, // 1 => 0000 0110
			0x5b, // 2 => 0101 1011
			0x4f, // 3 => 0100 1111
			0x66, // 4 => 0110 0110
			0x6d, // 5 => 0110 1101
			0x7d, // 6 => 0111 1101
			0x07, // 7 => 0000 0111
			0x7f, // 8 => 0111 1111
			0x6f  // 9 => 0110 1111
			};
	if (id <= 9)
		return basicFont[id];

	for (int i = 0; i < customFontCount; i++) {
		if (customFonts[i].id == id) {
			return customFonts[i].bitmap;
		}
	}
	return 0x00;
}

void FND_AppendFont(uint8_t id, uint8_t bitmap) {
	if (customFontCount < MAX_CUSTOM_FONT) {
		customFonts[customFontCount].id = id;
		customFonts[customFontCount].bitmap = bitmap;
		customFontCount++;
	}
}

void FND_DispDigit(uint8_t id, int position) {
	uint8_t font = FND_GetBitmap(id) | (uint8_t) fndDP[position];
	for (int i = 0; i < 8; i++) {
		if (!(font & (1 << i))) {
			HAL_GPIO_WritePin(fndPin[i].GPIOx, fndPin[i].GPIO_Pin, RESET);
		} else {
			HAL_GPIO_WritePin(fndPin[i].GPIOx, fndPin[i].GPIO_Pin, SET);
		}
	}
}

void FND_AllOff() {
	HAL_GPIO_WritePin(fndDigitCom[0].GPIOx, fndDigitCom[0].GPIO_Pin, SET);
	HAL_GPIO_WritePin(fndDigitCom[1].GPIOx, fndDigitCom[1].GPIO_Pin, SET);
	HAL_GPIO_WritePin(fndDigitCom[2].GPIOx, fndDigitCom[2].GPIO_Pin, SET);
	HAL_GPIO_WritePin(fndDigitCom[3].GPIOx, fndDigitCom[3].GPIO_Pin, SET);
}

void FND_DigitOn(int digit) {
	FND_AllOff();
	switch (digit) {
	case DIGIT_1000:
		HAL_GPIO_WritePin(fndDigitCom[0].GPIOx, fndDigitCom[0].GPIO_Pin, RESET);
		break;
	case DIGIT_100:
		HAL_GPIO_WritePin(fndDigitCom[1].GPIOx, fndDigitCom[1].GPIO_Pin, RESET);
		break;
	case DIGIT_10:
		HAL_GPIO_WritePin(fndDigitCom[2].GPIOx, fndDigitCom[2].GPIO_Pin, RESET);
		break;
	case DIGIT_1:
		HAL_GPIO_WritePin(fndDigitCom[3].GPIOx, fndDigitCom[3].GPIO_Pin, RESET);
		break;
	}
}

void FND_Display() {
	static int digit = 0;
	digit = (digit + 1) % 4;

	FND_AllOff();
	FND_DispDigit(fndDispBuffer[digit], digit);
	FND_DigitOn(digit);
}

void FND_SetDP(int position, int state) {
	if (state == FND_DP_ON) {
		fndDP[position] = 0x80;
	} else {
		fndDP[position] = 0x00;
	}
}

void FND_WriteChar(int position, char c) {
	fndDispBuffer[position] = c;
}

void FND_WriteString(char *str) {
	int bufIdx = 0;
	int strIdx = 0;
	while (str[strIdx] != '\0' && bufIdx < 4) {
		char c = str[strIdx];
		if (c >= '0' && c <= '9') {
			fndDispBuffer[bufIdx] = c - '0';
		} else if (c == ' ' || c == '\0') {
			fndDispBuffer[bufIdx] = 0xFF;
		} else {
			fndDispBuffer[bufIdx] = (uint8_t) c;
		}
		bufIdx++;
		strIdx++;
	}
	while (bufIdx < 4) {
		fndDispBuffer[bufIdx++] = 0xFF;
	}
}
