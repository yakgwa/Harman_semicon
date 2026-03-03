/*
 * Buzzer.c
 *
 *  Created on: Dec 24, 2025
 *      Author: kccistc
 */


#include "Buzzer.h"

TIM_HandleTypeDef *hBuzzerTim;
uint32_t buzzerChannel;

void Buzzer_init(TIM_HandleTypeDef *hTim, uint32_t channel){
	hBuzzerTim = hTim;
	buzzerChannel = channel;
}


void Buzzer_makeSound(int herz){

//	uint32_t arrValue = (uint32_t)(1000000/herz);

//	__HAL_TIM_SET_AUTORELOAD(hBuzzerTim,arrValue-1); // change frequency duty ration (ARR register)
//	__HAL_TIM_SET_COMPARE(hBuzzerTim, buzzerChannel, (arrValue/2-1)); // change duty ratio (CCR register)
	if (herz == 0) {
	        __HAL_TIM_SET_COMPARE(hBuzzerTim, buzzerChannel, 0);
	        return;
	    }

	    // 1,000,000Hz (1MHz) 클럭 기준 계산 (Prescaler 100-1 일 때)
	    // uint32_t로 선언해야 956 같은 큰 숫자가 안 잘립니다.
	    uint32_t arrValue = (uint32_t)(1000000 / herz);

	    __HAL_TIM_SET_AUTORELOAD(hBuzzerTim, arrValue - 1);

	    // 부저는 50% 듀티비(절반)일 때 소리가 가장 큽니다.
	    __HAL_TIM_SET_COMPARE(hBuzzerTim, buzzerChannel, (arrValue / 2 - 1));
}

void Buzzer_startSound(){
	HAL_TIM_PWM_Start(hBuzzerTim, buzzerChannel);
}

void Buzzer_stopSound(){
	HAL_TIM_PWM_Stop(hBuzzerTim, buzzerChannel);
}
