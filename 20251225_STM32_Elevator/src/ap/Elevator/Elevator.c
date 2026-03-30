/*
 * Elevator.c
 *
 *  Created on: Dec 26, 2025
 *      Author: kccistc
 */

#include "Elevator.h"

extern I2C_HandleTypeDef hi2c1;

hBtn btn[MAX_FLOOR];
hPhotoInt photoInt[MAX_FLOOR];
hElevator elev;

static const floorConfig floorCfgs[] = {
#define X(name, bPort, bPin, sPort, sPin) \
	{GPIO##bPort, GPIO_PIN_##bPin, GPIO##sPort, GPIO_PIN_##sPin},
		FLOOR_LIST
#undef X
		};

void Elevator_onBlocked(void *arg) {
	int detectedFloor = (int) arg;
	elev.curFloor = detectedFloor;

	if (elev.curFloor == elev.destFloor) {
		Elevator_MoveStop();
		elev.state = ELEV_STOP;
	}
}

void Elevator_ISR() {
	if (elev.state == ELEV_MOVE)
		Elevator_ToggleBlink();
}

void Elevator_ToggleBlink() {
	static int blinkCount = 0;
	if (++blinkCount >= 500) {
		blinkCount = 0;
		elev.blink = !elev.blink;
	}
}

void Elevator_ISR_Handler(uint16_t GPIO_Pin) {
	for (int i = 0; i < MAX_FLOOR; i++) {
		if (GPIO_Pin == elev.photoIntFloor[i]->pinNum) {
			PhotoInt_ISR_Handler(elev.photoIntFloor[i]);
			break;
		}
	}
}

void Elevator_Init() {
	LCD_Init(&hi2c1);
	Buzzer_Init();
	FND_AppendFont('U', 0x23); // 0010 0011
	FND_AppendFont('u', 0x54); // 0101 0100
	FND_AppendFont('D', 0x1C); // 0001 1100
	FND_AppendFont('d', 0x62); // 0110 0010
	FND_AppendFont('-', 0x40); // 0100 0000
	FND_AppendFont('F', 0x71); // 0111 0001
	StepMotor_Init();
	StepMotor_Speed(MOTOR_SPEED);

	for (int i = 0; i < MAX_FLOOR; i++) {
		Button_Init(&btn[i], floorCfgs[i].btnPort, floorCfgs[i].btnPin);
		PhotoInt_Init(&photoInt[i], floorCfgs[i].photoIntPort,
				floorCfgs[i].photoIntPin);
		elev.btnFloor[i] = &btn[i];
		elev.photoIntFloor[i] = &photoInt[i];
		PhotoInt_RegisterCallback(elev.photoIntFloor[i], Elevator_onBlocked,
				(void*) (i));
	}
	elev.destFloor = -1;
	Elevator_UpdateCurFloor();
	Elevator_MoveHome();
}

void Elevator_Execute() {
	Elevator_DispLCD();
	Elevator_DispFND();
	switch (elev.state) {
	case ELEV_INIT:
		break;
	case ELEV_IDLE:
		for (int i = 0; i < MAX_FLOOR; i++) {
			if ((Button_GetState(elev.btnFloor[i]) == ACT_PUSHED)
					&& (i != elev.curFloor)) {
				elev.destFloor = i;
				Elevator_MoveStart();
			}
		}
		break;
	case ELEV_MOVE:
		break;
	case ELEV_STOP:
		Buzzer_Ring(1000);
		elev.state = ELEV_IDLE;
		break;
	}
}

void Elevator_MoveHome() {
	if (elev.curFloor == 0) {
		elev.state = ELEV_IDLE;
	} else {
		elev.state = ELEV_INIT;
		elev.destFloor = 0;
		StepMotor_SetDir(DOWN);
		StepMotor_Run();
	}
}

void Elevator_MoveStart() {
	if (elev.destFloor == -1 || elev.destFloor == elev.curFloor)
		return;
	if (elev.destFloor > elev.curFloor) {
		StepMotor_SetDir(UP);
	} else {
		StepMotor_SetDir(DOWN);
	}
	StepMotor_Run();
	elev.state = ELEV_MOVE;
}

void Elevator_MoveStop() {
	StepMotor_Stop();
	elev.destFloor = -1;
}

void Elevator_UpdateCurFloor() {
	for (int i = 0; i < MAX_FLOOR; i++) {
		if (PhotoInt_GetState(elev.photoIntFloor[i])) {
			elev.curFloor = i;
			return;
		}
	}
	elev.curFloor = -1;
}

void Elevator_DispLCD() {
	static int prevCurFloor = MAX_FLOOR;
	static int prevDestFloor = MAX_FLOOR;
	static int prevState = ELEV_STOP;
	char str[80];
	if (prevState != elev.state) {
		prevState = elev.state;
		switch (elev.state) {
		case ELEV_INIT:
			LCD_WriteStringXY(0, 0, "Init..");
			break;
		case ELEV_IDLE:
			LCD_WriteStringXY(0, 0, "IDLE  ");
			break;
		case ELEV_MOVE:
			LCD_WriteStringXY(0, 0, "Move..");
			break;
		}
	}
	if (prevCurFloor != elev.curFloor || prevDestFloor != elev.destFloor) {
		prevCurFloor = elev.curFloor;
		prevDestFloor = elev.destFloor;
		sprintf(str, "C:%0dF D:%0dF ", elev.curFloor + 1, elev.destFloor + 1);
		LCD_WriteStringXY(1, 0, str);
	}
}

void Elevator_DispFND() {
	static int prevCurFloor = MAX_FLOOR;
	static int prevDestFloor = MAX_FLOOR;
	static int prevBlink = 1;
	static int prevState = ELEV_STOP;

	int isChanged = (prevState != elev.state || prevBlink != elev.blink
			|| prevCurFloor != elev.curFloor || prevDestFloor != elev.destFloor);
	if (!isChanged)
		return;

	prevState = elev.state;
	prevBlink = elev.blink;
	prevCurFloor = elev.curFloor;
	prevDestFloor = elev.destFloor;

	char str[20];
	switch (elev.state) {
	case ELEV_INIT:
		FND_WriteString("----");
		break;
	case ELEV_IDLE:
		sprintf(str, "  %0dF", elev.curFloor + 1);
		FND_WriteString(str);
		break;
	case ELEV_MOVE:
		char arrow;
		if (elev.destFloor > elev.curFloor) {
			arrow = (elev.blink) ? 'U' : 'u';
		} else {
			arrow = (elev.blink) ? 'D' : 'd';
		}
		sprintf(str, "%c %0dF", arrow, elev.curFloor + 1);
		FND_WriteString(str);
		break;
	case ELEV_STOP:
		break;
	}
}
