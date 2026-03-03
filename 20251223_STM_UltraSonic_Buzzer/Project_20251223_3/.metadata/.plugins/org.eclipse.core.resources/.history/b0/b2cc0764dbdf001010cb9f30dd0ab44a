/*
 * fnd.c
 *
 * Created on: Dec 12, 2025
 * Author: kccistc
 */
#include "fnd.h"

FND_TypeDef fndDigitCom[4] = {
      {FND_D1_GPIO, FND_D1_PIN},
      {FND_D2_GPIO, FND_D2_PIN},
      {FND_D3_GPIO, FND_D3_PIN},
      {FND_D4_GPIO, FND_D4_PIN}
};

FND_TypeDef fndPin[8] = {
      {FND_A_GPIO, FND_A_PIN},
      {FND_B_GPIO, FND_B_PIN},
      {FND_C_GPIO, FND_C_PIN},
      {FND_D_GPIO, FND_D_PIN},
      {FND_E_GPIO, FND_E_PIN},
      {FND_F_GPIO, FND_F_PIN},
      {FND_G_GPIO, FND_G_PIN},
      {FND_DP_GPIO, FND_DP_PIN}
};

uint16_t fndNum; // 전역 변수

void FND_ISR()
{
    FND_DispNum();
}

void FND_SetNum(uint16_t num)
{
    fndNum = num;
}

void FND_DispDigit(uint16_t digit)
{
   const uint8_t segFont[10] = {
         0x3f, // 0 -> 0011 1111
         0x06, // 1 -> 0000 0110
         0x5b, // 2 -> 0101 1011
         0x4f, // 3 -> 0100 1111
         0x66, // 4 -> 0110 0110
         0x6d, // 5 -> 0110 1101
         0x7d, // 6 -> 0111 1101
         0x07, // 7 -> 0000 0111
         0x7f, // 8 -> 0111 1111
         0x6f, // 9 -> 0110 1111

   };

   for (int i = 0; i < 8; i++) {
      if(segFont[digit] & (1<<i)) {
         HAL_GPIO_WritePin(fndPin[i].GPIOx, fndPin[i].GPIO_Pin, SET);
      }
      else {
         HAL_GPIO_WritePin(fndPin[i].GPIOx, fndPin[i].GPIO_Pin, RESET);
      }
   }
}

void FND_Alloff()
{
  HAL_GPIO_WritePin(FND_D1_GPIO, FND_D1_PIN, SET);
  HAL_GPIO_WritePin(FND_D2_GPIO, FND_D2_PIN, SET);
  HAL_GPIO_WritePin(FND_D3_GPIO, FND_D3_PIN, SET);
  HAL_GPIO_WritePin(FND_D4_GPIO, FND_D4_PIN, SET);
}

void FND_DigitOn(int digit)
{

   FND_Alloff();

   switch(digit)
   {
   case DIGIT_1000:
      HAL_GPIO_WritePin(FND_D1_GPIO, FND_D1_PIN, RESET);
      break;
   case DIGIT_100:
      HAL_GPIO_WritePin(FND_D2_GPIO, FND_D2_PIN, RESET);
      break;
   case DIGIT_10:
      HAL_GPIO_WritePin(FND_D3_GPIO, FND_D3_PIN, RESET);
      break;
   case DIGIT_1:
      HAL_GPIO_WritePin(FND_D4_GPIO, FND_D4_PIN, RESET);
      break;
   }
}


void FND_DispNum(void)
{
    static int digit = 0;
    digit = (digit + 1) % 4;

    switch(digit)
    {
        case DIGIT_1000:
            FND_Alloff();
            FND_DispDigit(fndNum / 1000 % 10);
            FND_DigitOn(DIGIT_1000);
            break;

        case DIGIT_100:
            FND_Alloff();
            FND_DispDigit(fndNum / 100 % 10);
            FND_DigitOn(DIGIT_100);
            break;

        case DIGIT_10:
            FND_Alloff();
            FND_DispDigit(fndNum / 10 % 10);
            FND_DigitOn(DIGIT_10);
            break;

        case DIGIT_1:
            FND_Alloff();
            FND_DispDigit(fndNum % 10);
            FND_DigitOn(DIGIT_1);
            break;
    }
}

