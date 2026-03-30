/*
 * common.h
 *
 *  Created on: Dec 18, 2025
 *      Author: rhoblack
 */

#ifndef COMMON_COMMON_H_
#define COMMON_COMMON_H_

#include "stm32f4xx_hal.h"

#include "../ap/TimeWatch/TimeWatch.h"
#include "../ap/StopWatch/StopWatch.h"
#include "../ap/Elevator/Elevator.h"
#include "../driver/fnd/fnd.h"
#include "../driver/SR04/SR04.h"
#include "../driver/PhotoInterrupter/PhotoInterrupter.h"

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim);
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin);

#endif /* COMMON_COMMON_H_ */
