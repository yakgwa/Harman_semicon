/*
 * Elevator.h
 *
 *  Created on: Dec 26, 2025
 *      Author: kccistc
 */

#ifndef AP_ELEVATOR_ELEVATOR_H_
#define AP_ELEVATOR_ELEVATOR_H_

#include <stdio.h>
#include "../driver/button/button.h"
#include "../driver/buzzer/buzzer.h"
#include "../driver/lcd/lcd.h"
#include "../driver/fnd/fnd.h"
#include "../driver/PhotoInterrupter/PhotoInterrupter.h"
#include "../driver/StepMotor/StepMotor.h"

#define MAX_FLOOR	3
#define MOTOR_SPEED	300
#define UP			CW
#define DOWN		CCW

#define FLOOR_LIST \
    X(F1, C, 10, B, 13) \
    X(F2, C, 11, B, 14) \
    X(F3, C, 12, B, 15)

enum {
	ELEV_SENSORS_MASK = (
#define X(name, bPort, bPin, sPort, sPin) GPIO_PIN_##sPin |
	FLOOR_LIST
#undef X
			0 )
};

typedef struct {
	hBtn *btnFloor[MAX_FLOOR];
	hPhotoInt *photoIntFloor[MAX_FLOOR];
	hBuzzer *buzzer;
	int curFloor;
	int destFloor;
	int blink;
	uint32_t state;
} hElevator;

typedef struct {
	GPIO_TypeDef *btnPort;
	uint16_t btnPin;
	GPIO_TypeDef *photoIntPort;
	uint16_t photoIntPin;
} floorConfig;

enum {
	ELEV_INIT, ELEV_IDLE, ELEV_MOVE, ELEV_STOP
};

void Elevator_onBlocked(void *arg);
void Elevator_ISR_Handler(uint16_t GPIO_Pin);
void Elevator_ISR();
void Elevator_ToggleBlink();
void Elevator_Init();
void Elevator_Execute();
void Elevator_MoveHome();
void Elevator_MoveStart();
void Elevator_MoveStop();
void Elevator_UpdateCurFloor();
void Elevator_DispLCD();
void Elevator_DispFND();

#endif /* AP_ELEVATOR_ELEVATOR_H_ */
