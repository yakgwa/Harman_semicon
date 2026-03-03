/*
 * common.c
 *
 *  Created on: Dec 18, 2025
 *      Author: kccistc
 */

//타이머 언터럽트가 여러개가 있다 하면 각각 5개가 불려지는 함수가 있는데
//그걸 각각 따로 할수있는데 하나의 함수에서 관리할 수 있어요.
// 얘는 그럼 TIMER2같은 경우 1MS 마다 CALL 되는거죠?
// 0.1초 마다 콜되는갑니다.
#include "common.h"

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
  if (htim->Instance == TIM2){ 	// 1ms call
	  TimeWatch_ISR();
	  StopWatch_ISR();
  }
  else if (htim->Instance == TIM3){ // 0.1s call

  }
}
