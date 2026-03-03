#include "ultrasonic.h"

extern TIM_HandleTypeDef htim1;
extern volatile float distance;       // Changed to match your main.c float
extern volatile uint8_t isReadingFinished;

static volatile uint8_t isRisingCaptured = 0;
static volatile uint32_t IC_Value1 = 0;
static volatile uint32_t IC_Value2 = 0;
static volatile uint32_t IC_Difference = 0;

void Ultrasonic_Get_Distance(void)
{
    isReadingFinished = 0;
    isRisingCaptured = 0;

    // Set polarity to Rising initially just in case
    __HAL_TIM_SET_CAPTUREPOLARITY(&htim1, TIM_CHANNEL_1, TIM_INPUTCHANNELPOLARITY_RISING);

    /* Send Trigger Signal */
    HAL_GPIO_WritePin(ULTRASONUC_TRIGGER_PORT, ULTRASONIC_TRIGGER_PIN, GPIO_PIN_SET);

    // A simple blocking delay for 10us (assuming ~168MHz clock)
    // 10us is roughly 1680 cycles.
    for(volatile int i = 0; i < 200; i++);

    HAL_GPIO_WritePin(ULTRASONUC_TRIGGER_PORT, ULTRASONIC_TRIGGER_PIN, GPIO_PIN_RESET);

    /* Enable Capture Interrupt */
    __HAL_TIM_ENABLE_IT(&htim1, TIM_IT_CC1);
    HAL_TIM_IC_Start_IT(&htim1, TIM_CHANNEL_1);
}

void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *htim)
{
    if (htim->Instance == TIM1)
    {
        if (isRisingCaptured == 0)
        {
            IC_Value1 = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_1);
            isRisingCaptured = 1;
            __HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_1, TIM_INPUTCHANNELPOLARITY_FALLING);
        }
        else
        {
            IC_Value2 = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_1);

            if (IC_Value2 > IC_Value1) {
                IC_Difference = IC_Value2 - IC_Value1;
            } else {
                IC_Difference = (0xFFFF - IC_Value1) + IC_Value2;
            }

            // Calculation: (Time in us * 0.0343) / 2
            distance = (float)IC_Difference * 0.01715f;
            isReadingFinished = 1;
            isRisingCaptured = 0;

            __HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_1, TIM_INPUTCHANNELPOLARITY_RISING);
            __HAL_TIM_DISABLE_IT(htim, TIM_IT_CC1);
            HAL_TIM_IC_Stop_IT(htim, TIM_CHANNEL_1);
        }
    }
}
