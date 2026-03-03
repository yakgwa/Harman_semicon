#include <stdint.h>

#define __IO volatile

/********************************************************
 * 레지스터 구조체 정의
 ********************************************************/

// GPO 출력 포트
typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t ODR;
} GPO_TypeDef;

// GPI 입력 포트
typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t IDR;
} GPI_TypeDef;

// FND 제어용 구조체
typedef struct {
    __IO uint32_t FCR;
    __IO uint32_t FDR;
    __IO uint32_t FPR;
    __IO uint32_t NOUSE;
    __IO uint32_t HEX;
    __IO uint32_t BCD;
} FND_TypeDef;

// GPIO 공통 포트 구조체
typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t IDR;
    __IO uint32_t ODR;
} GPIO_TypeDef;

// 타이머
typedef struct {
    __IO uint32_t TCR;
    __IO uint32_t TCNT;
    __IO uint32_t PSC;
    __IO uint32_t ARR;
} TIM_TypeDef;

// 초음파 센서 구조체
typedef struct {
    __IO uint32_t UCR;
    __IO uint32_t USR;
    __IO uint32_t UDR;
} US_TypeDef;

// UART FIFO 구조체
typedef struct {
    __IO uint32_t USR;
    __IO uint32_t ULS;
    __IO uint32_t UWD;
    __IO uint32_t URD;
}UART_TypeDef;

// DHT11 센서 구조체
typedef struct {
    __IO uint32_t TRIG;
    __IO uint32_t HMD;
    __IO uint32_t TMP;
    __IO uint32_t SUM;
} DHT_TypeDef;

/********************************************************
 * 주소 매핑 (APB 기준)
 ********************************************************/
#define APB_BASEADDR      0x10000000
#define GPOA_BASEADDR     (APB_BASEADDR + 0x1000)
#define GPIB_BASEADDR     (APB_BASEADDR + 0x2000)
#define GPIOC_BASEADDR    (APB_BASEADDR + 0x3000)
#define GPIOD_BASEADDR    (APB_BASEADDR + 0x4000)
#define FND_BASEADDR      (APB_BASEADDR + 0x5000)
#define UART_BASEADDR     (APB_BASEADDR + 0x6000)
#define TIM_BASEADDR      (APB_BASEADDR + 0x7000)
#define US_BASEADDR       (APB_BASEADDR + 0x8000)
#define DHT_BASEADDR      (APB_BASEADDR + 0x9000)

#define GPOA   ((GPO_TypeDef *) GPOA_BASEADDR)
#define GPIB   ((GPI_TypeDef *) GPIB_BASEADDR)
#define GPIOC  ((GPIO_TypeDef *) GPIOC_BASEADDR)
#define GPIOD  ((GPIO_TypeDef *) GPIOD_BASEADDR)
#define FND    ((FND_TypeDef *) FND_BASEADDR)
#define UART   ((UART_TypeDef *) UART_BASEADDR)
#define TIM   ((TIM_TypeDef *) TIM_BASEADDR)
#define US     ((US_TypeDef  *) US_BASEADDR)
#define DHT    ((DHT_TypeDef *) DHT_BASEADDR)

/********************************************************
 * 함수 선언
 ********************************************************/
void delay(int n);

// GPO/GPI 제어 함수
void GPO_init(GPO_TypeDef* GPOx);
void GPO_write(GPO_TypeDef* GPOx, uint32_t data);

// FND 제어 함수
void fndEn(FND_TypeDef* FNDx, uint32_t n);
void fndfont(FND_TypeDef* FNDx, uint32_t fndFont);
void fndDot(FND_TypeDef* FNDx, uint32_t Dot);
uint32_t fndBCD(FND_TypeDef* FNDx);

// 버튼 및 LED 제어 함수
void Button_init(GPIO_TypeDef *GPIOx);
uint32_t Button_getState(GPIO_TypeDef *GPIOx);
void LED_init(GPIO_TypeDef *GPIOx);
void LED_write(GPIO_TypeDef *GPIOx, uint32_t data);

// Switch 제어 함수
void sw_init(GPI_TypeDef *GPIx);
uint32_t sw_read(GPI_TypeDef *GPIx);

// 타이머 제어 함수
void TIM_start(TIM_TypeDef *tim);
void TIM_stop(TIM_TypeDef *tim);
uint32_t TIM_readCount(TIM_TypeDef *tim);
void TIM_writePrescaler(TIM_TypeDef *tim, uint32_t psc);
void TIM_writeAutoReload(TIM_TypeDef *tim, uint32_t arr);
void TIM_clear(TIM_TypeDef *tim);

// UART 제어 함수
uint32_t UART_state(UART_TypeDef *UARTx);
void UART_loop (UART_TypeDef *UARTx);
void UART_writeData (UART_TypeDef *UARTx, uint32_t data);
uint32_t UART_readData(UART_TypeDef *UARTx);


// 초음파 제어 함수
void US_start(US_TypeDef *USx, uint32_t data);
uint32_t US_dist_read(US_TypeDef *USx);
uint32_t US_check_vaild(US_TypeDef *USx);

// DHT 온습도 함수
void DHTinit(DHT_TypeDef *DHTx, uint32_t dht);
uint32_t DHTreadSUM(DHT_TypeDef* DHTx);
uint32_t DHTreadHMD(DHT_TypeDef* DHTx);
uint32_t DHTreadTMP(DHT_TypeDef* DHTx);
uint32_t Productfunc(uint32_t x, int n);
void Show_HMD();
void Show_TMP();
void Show_SUM();

// 디스플레이 기능 함수
// void power(uint32_t *prevTime, uint32_t *data);
// void display_tcnt_on_fnd();

/////////////////////////////////////////////
// sw로 수동모드 선택했을 때 동작 함수

// 초음파 수동 측정 함수
uint32_t us_measure(uint32_t *us_dist);
// 온습도 수동 측정 함수
void dht_measure(uint32_t *temp, uint32_t *hmd, uint32_t *sum);

// 각 기능 수행 함수
void func1(uint32_t *prevTime, uint32_t *data , uint32_t *us_dist);
void func2(uint32_t *prevTime, uint32_t *data , uint32_t *us_dist);
void func3(uint32_t *prevTime, uint32_t *data , uint32_t *us_dist);
void func4(uint32_t *prevTime, uint32_t *data , uint32_t *dht_t, uint32_t *dht_h );
void func5(uint32_t *prevTime, uint32_t *data , uint32_t *dht_t, uint32_t *dht_h );

void uart_us_auto_mode();
void uart_us_manual_mode();
void uart_temp_auto_mode();
void uart_temp_manual_mode();


/**********************
 * 버튼 번호 매핑
 **********************/
#define BUTTON_1    4
#define BUTTON_2    5
#define BUTTON_3    6
#define BUTTON_4    7

enum {IDLE, US_READY, TEMP_READY, FUNC1, FUNC2, FUNC3, FUNC4 , FUNC5, FUNC6};

int main() {
    Button_init(GPIOD); // 버튼 기능 on
    LED_init(GPIOC);
    sw_init(GPIB); // sw 기능 on
    fndEn(FND,1); //  fnd 기능 on


    uint32_t temp_sw = 0;
    uint32_t us_dist = 0; // 초음파 거리 측정값 
    uint32_t dht_t = 0;   // 온습도 온도 측정값
    uint32_t dht_h = 0;   // 온습도 습도 측정값
    uint32_t dht_c = 0;   // 온습도 체크섬 측정값

     // 각 기능별 시간 저장 변수 및 데이터 변수
    uint32_t func1PrevTime = 0, func1Data = 0;
    uint32_t func2PrevTime = 0, func2Data = 0;
    uint32_t func3PrevTime = 0, func3Data = 0;
    uint32_t func4PrevTime = 0, func4Data = 0;
    uint32_t func5PrevTime = 0, func5Data = 0;
    

    // 타이머 설정: 1ms에 한 번 1 증가하도록 프리스케일 설정
    TIM_writePrescaler(TIM, 100000 - 1);
    TIM_writeAutoReload(TIM, 0xFFFFFFFF);
    TIM_start(TIM);

    uint32_t state = IDLE; // 초기 상태
    uint32_t state_t = IDLE; // 초기 상태

    uint32_t uart_rdata_us = 0;
    uint32_t uart_rdata_temp = 0;


    while (1) {
        uart_rdata_us = 0;
        uart_rdata_temp = 0;
        temp_sw = sw_read(GPIB);
        uint32_t sw0_US_or_DHT = temp_sw & (1<<0); // FND 출력 선택을 위한 SW
        uint32_t sw1_DHT_Choose = temp_sw & (1<<1); // FND 출력 선택을 위한 SW

        US_start(US, 0); // 초음파 초기 상태 
        us_measure(&us_dist);  // 초음파 측정 함수
        dht_measure(&dht_t, &dht_h, &dht_c); // 온습도 측정 함수

        // FND 출력 파트
        if (!sw0_US_or_DHT){   // SW0 == 0 (FND 초음파 출력)
            fndfont(FND, us_dist);
            fndDot(FND, 0x00);
        } 
        else if (sw0_US_or_DHT){    // SW0 == 1 (FND 온습도 출력)
            if(!sw1_DHT_Choose) {
                fndDot(FND, 0x04);
                fndfont(FND, dht_t); // 온도 출력
            } else {
                fndDot(FND, 0x04);
                fndfont(FND, dht_h); // 습도 출력
            }
        }
  
        // UART입력을 통해 상태 전환
        if (!(UART_state(UART) & (1<<0))) { // rx empty가 아닐때 읽기
                uint32_t r = UART_readData(UART);
                uart_rdata_us = r;
                uart_rdata_temp = r;

                UART_writeData (UART, r);
                UART_writeData (UART, '\n');
        }

        // 초음파 FSM (func1~3)
        switch (state) {
    case FUNC1:
        func1(&func1PrevTime, &func1Data, &us_dist);
        break;
    case FUNC2:
        func2(&func2PrevTime, &func2Data, &us_dist);
        break;
    case FUNC3:
        func3(&func3PrevTime, &func3Data, &us_dist);
        break;
}

switch (state) {
    case IDLE:
        if (uart_rdata_us == 'u' || uart_rdata_us == 'U') state = US_READY;
        break;

    case US_READY:
        if (uart_rdata_us == '1') state = FUNC1;
        else if (uart_rdata_us == '2') state = FUNC2;
        else if (uart_rdata_us == '3') state = FUNC3;
        else if (uart_rdata_us == 'x' || uart_rdata_us == 'X') state = IDLE;
        break;

    case FUNC1:
        if (uart_rdata_us == '2') state = FUNC2;
        else if (uart_rdata_us == '3') state = FUNC3;
        else if (uart_rdata_us == 'x' || uart_rdata_us == 'X') state = IDLE;
        break;

    case FUNC2:
        if (uart_rdata_us == '1') state = FUNC1;
        else if (uart_rdata_us == '3') state = FUNC3;
        else if (uart_rdata_us == 'x' || uart_rdata_us == 'X') state = IDLE;
        break;

    case FUNC3:
        if (uart_rdata_us == '1') state = FUNC1;
        else if (uart_rdata_us == '2') state = FUNC2;
        else if (uart_rdata_us == 'x' || uart_rdata_us == 'X') state = IDLE;
        break;
}


        // 온습도 FSM (func4,func5)
        switch (state_t) {
            case FUNC4: func4(&func4PrevTime, &func4Data, &dht_t, &dht_h); break;
            case FUNC5: func5(&func5PrevTime, &func5Data, &dht_t, &dht_h); break;
        }

       switch (state_t) {
    case IDLE:
        if (uart_rdata_temp == 't' || uart_rdata_temp == 'T') state_t = TEMP_READY;
        break;

    case TEMP_READY:
        if (uart_rdata_temp == '4') state_t = FUNC4;
        else if (uart_rdata_temp == '5') state_t = FUNC5;
        else if (uart_rdata_temp == 's' || uart_rdata_temp == 'S') state_t = IDLE;
        break;

    case FUNC4:
        if (uart_rdata_temp == '5') state_t = FUNC5;
        else if (uart_rdata_temp == 's' || uart_rdata_temp == 'S') state_t = IDLE;
        break;

    case FUNC5:
        if (uart_rdata_temp == '4') state_t = FUNC4;
        else if (uart_rdata_temp == 's' || uart_rdata_temp == 'S') state_t = IDLE;
        break;
}




        delay(100);
        }

    return 0;
}


/********************************************************
 * 기본 유틸리티 함수
 ********************************************************/

// 루프 기반 딜레이 함수
void delay(int n) {
    volatile uint32_t temp = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < 1000; j++) {
            temp++;
        }
    }
}

/********************************************************
 * GPO/GPI 함수 (LED) / (switch) 
 ********************************************************/

// GPO 포트를 출력 모드로 초기화
void GPO_init(GPO_TypeDef* GPOx) {
    GPOx->MODER = 0xFF;
}

// GPO 포트에 값 출력
void GPO_write(GPO_TypeDef* GPOx, uint32_t data) {
    GPOx->ODR = data;
}

// GPI 포트를 입력 모드로 초기화 (switch)
void sw_init(GPI_TypeDef* GPIx) {
    GPIx->MODER = 0x00;
}

// GPI 포트의 입력 값 읽기 (switch)
uint32_t sw_read(GPI_TypeDef* GPIx) {
    return GPIx->IDR;
}

/********************************************************
 * FND 제어 함수
 ********************************************************/

// FND 출력 활성화 또는 비활성화
void fndEn(FND_TypeDef* FNDx, uint32_t n) {
    FNDx->FCR = (n == 1) ? 0x01 : 0x00;
}

// FND에 숫자 출력
void fndfont(FND_TypeDef* FNDx, uint32_t fndFont) {
    FNDx->FDR = fndFont;
}

// FND 소수점(dot) 위치 설정
void fndDot(FND_TypeDef* FNDx, uint32_t Dot) {
    FNDx->FPR = Dot;
}

uint32_t fndBCD(FND_TypeDef* FNDx){
    return FNDx->BCD;
}
/********************************************************
 * 버튼 및 LED 함수 (GPIO)
 ********************************************************/

// 버튼 입력 포트 초기화
void Button_init(GPIO_TypeDef *GPIOx) {
    GPIOx->MODER = 0x00000000;
}

// 버튼 입력 상태 읽기
uint32_t Button_getState(GPIO_TypeDef *GPIOx) {
    return GPIOx->IDR;
}

// LED 출력 포트 초기화
void LED_init(GPIO_TypeDef *GPIOx) {
    GPIOx->MODER = 0xff;
}

// LED 값 출력
void LED_write(GPIO_TypeDef *GPIOx, uint32_t data) {
    GPIOx->ODR = data;
}

/********************************************************
 * 타이머 함수
 ********************************************************/

// 타이머 시작
void TIM_start(TIM_TypeDef *tim) {
    tim->TCR |= (1 << 0);
}

// 타이머 정지
void TIM_stop(TIM_TypeDef *tim) {
    tim->TCR &= ~(1 << 0);
}

// 현재 타이머 카운터 값 읽기
uint32_t TIM_readCount(TIM_TypeDef *tim) {
    return tim->TCNT;
}

// 타이머 프리스케일러 설정
void TIM_writePrescaler(TIM_TypeDef *tim, uint32_t psc) {
    tim->PSC = psc;
}

// 타이머 자동 리로드 값 설정
void TIM_writeAutoReload(TIM_TypeDef *tim, uint32_t arr) {
    tim->ARR = arr;
}

// 타이머 카운터 클리어
void TIM_clear(TIM_TypeDef *tim) {
    tim->TCR |= (1 << 1);
    tim->TCR &= ~(1 << 1);
}

/********************************************************
 * UART FIFO 함수
 ********************************************************/

// UART FIFO 상태 확인
uint32_t UART_state(UART_TypeDef *UARTx) {
    return UARTx->USR;
}


// FIFO에 데이터 쓰기 (Loopback 테스트용)
void UART_loop (UART_TypeDef *UARTx) {
    UARTx->UWD = UARTx->URD;
}

void UART_writeData (UART_TypeDef *UARTx, uint32_t data) {
    UARTx->UWD = data;
}

// FIFO에서 데이터 읽기
uint32_t UART_readData(UART_TypeDef *UARTx) {
    return UARTx->URD;
}

/********************************************************
 * 초음파 센서 함수
 ********************************************************/

// 초음파 센서 트리거 (0 > 1 되면 측정)
void US_start(US_TypeDef *USx, uint32_t data) {
    USx->UCR = data; 
}

// 측정된 거리 값 읽기
uint32_t US_dist_read(US_TypeDef *USx) {
    return USx->UDR;
}

// 측정 error인지 확인
uint32_t US_check_vaild(US_TypeDef *USx) {
    return USx->USR;
}

/********************************************************
 * DHT11 온습도 함수
 ********************************************************/

// DHT 센서 트리거 (1: 시작, 0: 정지)
void DHTinit(DHT_TypeDef *DHTx, uint32_t dht) {
    DHTx->TRIG = (dht == 1) ? 0x01 : 0x00;
}

// DHT Checksum 값 읽기
uint32_t DHTreadSUM(DHT_TypeDef* DHTx) {
    return DHTx->SUM;
}

// DHT 습도값 읽기 및 정수+소수 합산
uint32_t DHTreadHMD(DHT_TypeDef* DHTx) {
    uint32_t frac = DHTx->HMD & 0x7F;
    uint32_t intg = (DHTx->HMD >> 8) & 0xFF;
    return Productfunc(intg, 100) + frac;
}

// DHT 온도값 읽기 및 정수+소수 합산
uint32_t DHTreadTMP(DHT_TypeDef* DHTx) {
    uint32_t frac = DHTx->TMP & 0x7F;
    uint32_t intg = (DHTx->TMP >> 8) & 0xFF;
    return Productfunc(intg, 100) + frac;
}

// 곱셈기 없이 x * n 구현
uint32_t Productfunc(uint32_t x, int n) {
    uint32_t y = 0;
    for (int i = 0; i < n; i++) {
        y += x;
    }
    return y;
}


/********************************************************
 * 초음파/ 온습도 측정 함수 (자동/ 수동 트리거 합친)
 ********************************************************/

// 초음파 수동 측정 함수 (거리 값 반환)
uint32_t us_measure(uint32_t *us_dist) {

    if (Button_getState(GPIOD) & (1 << 5)) { // 수동 측정 트리거 부분 (버튼 입력)
        while (Button_getState(GPIOD) & (1 << 5));  
        US_start(US, 1); 
        US_start(US, 0); 

        delay(100);
        uint32_t dist = US_dist_read(US);
        *us_dist = dist;  
        FND->HEX = dist;
        uint32_t bcd = fndBCD(FND);

        uart_us_manual_mode();
        UART_writeData(UART, ((bcd >> 24) & 0xff));
        delay(10);    
        UART_writeData(UART, ((bcd >> 16) & 0xff));
        delay(10);
        UART_writeData(UART, ((bcd >> 8) & 0xff));
        delay(10);
        UART_writeData(UART, (bcd & 0xff));
        delay(10);
        UART_writeData(UART, '\n');
    }

    uint32_t valid = US_check_vaild(US);
    uint32_t dist = US_dist_read(US);

    if (!(valid & 0x01)) { // 유효한지 확인, 유효할때만 dist값 내보내기
        return dist;
    } else {
        return 0xFFFFFFFF;       // 에러 값
    }

}


// 온습도 수동 측정 함수 (온도, 습도, 체크섬을 포인터로 반환)
void dht_measure(uint32_t *temp, uint32_t *hmd, uint32_t *sum) {
    DHTinit(DHT, 0);

    if (Button_getState(GPIOD) & (1 << 6)) { // 수동 측정 트리거 부분 (버튼 입력)
        while (Button_getState(GPIOD) & (1 << 6));
        DHTinit(DHT, 1);
        delay(500);

        uint32_t temper = DHTreadTMP(DHT);
        uint32_t humid = DHTreadHMD(DHT);
        FND->HEX = temper;
        uint32_t bcd = fndBCD(FND);

        uart_temp_manual_mode();
        UART_writeData(UART, 't'); delay(5);
        UART_writeData(UART, '='); delay(5);
        UART_writeData(UART, ((bcd >> 24) & 0xff)); delay(5);
        UART_writeData(UART, ((bcd >> 16) & 0xff) ); delay(5);
        UART_writeData(UART, '.'); delay(5);
        UART_writeData(UART, ((bcd >> 8) & 0xff)); delay(5);
        UART_writeData(UART, (bcd & 0xff)); delay(5);
        UART_writeData(UART, ','); delay(5);

        FND->HEX = humid;
        uint32_t bcd_h = fndBCD(FND);
        UART_writeData(UART, 'h'); delay(5);
        UART_writeData(UART, '='); delay(5);
        UART_writeData(UART, ((bcd_h >> 24) & 0xff)); delay(5);
        UART_writeData(UART, ((bcd_h >> 16) & 0xff) ); delay(5);
        UART_writeData(UART, '.'); delay(5);
        UART_writeData(UART, ((bcd_h >> 8) & 0xff)); delay(5);
        UART_writeData(UART, (bcd_h & 0xff)); delay(5);
        UART_writeData(UART, '\n');


    }


    *temp = DHTreadTMP(DHT);
    *hmd  = DHTreadHMD(DHT);
    *sum  = DHTreadSUM(DHT);


}




void uart_us_auto_mode(){
    UART_writeData(UART, '['); delay(5);
    UART_writeData(UART, 'u'); delay(5);
    UART_writeData(UART, 's'); delay(5);
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, 'a'); delay(5);
    UART_writeData(UART, 'u'); delay(5);
    UART_writeData(UART, 't'); delay(5);
    UART_writeData(UART, 'o'); delay(5);
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, 'm'); delay(5);
    UART_writeData(UART, 'o'); delay(5);
    UART_writeData(UART, 'd'); delay(5);
    UART_writeData(UART, 'e'); delay(5);
    UART_writeData(UART, ']'); delay(5);
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, 'd'); delay(5);
    UART_writeData(UART, 'i'); delay(5);
    UART_writeData(UART, 's'); delay(5);
    UART_writeData(UART, 't'); delay(5);
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, '='); delay(5);
    UART_writeData(UART, ' '); delay(5);
}

void uart_us_manual_mode(){
    UART_writeData(UART, '['); delay(5);
    UART_writeData(UART, 'u'); delay(5);
    UART_writeData(UART, 's'); delay(5);
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, 'm'); delay(5);
    UART_writeData(UART, 'a'); delay(5);
    UART_writeData(UART, 'n'); delay(5);
    UART_writeData(UART, 'u'); delay(5);
    UART_writeData(UART, 'a'); delay(5);
    UART_writeData(UART, 'l'); delay(5);
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, 'm'); delay(5);
    UART_writeData(UART, 'o'); delay(5);
    UART_writeData(UART, 'd'); delay(5);
    UART_writeData(UART, 'e'); delay(5);
    UART_writeData(UART, ']'); delay(5);
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, 'd'); delay(5);
    UART_writeData(UART, 'i'); delay(5);
    UART_writeData(UART, 's'); delay(5);
    UART_writeData(UART, 't'); delay(5);
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, '='); delay(5);
    UART_writeData(UART, ' '); delay(5);
}

void uart_temp_auto_mode(){
    UART_writeData(UART, '['); delay(5);
    UART_writeData(UART, 'd'); delay(5);
    UART_writeData(UART, 'h'); delay(5);
    UART_writeData(UART, 't'); delay(5);
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, 'a'); delay(5);
    UART_writeData(UART, 'u'); delay(5);
    UART_writeData(UART, 't'); delay(5);
    UART_writeData(UART, 'o'); delay(5);
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, 'm'); delay(5);
    UART_writeData(UART, 'o'); delay(5);
    UART_writeData(UART, 'd'); delay(5);
    UART_writeData(UART, 'e'); delay(5);
    UART_writeData(UART, ']'); delay(5);
    UART_writeData(UART, ' '); delay(5);
}

void uart_temp_manual_mode(){
    UART_writeData(UART, '['); delay(5);
    UART_writeData(UART, 'd'); delay(5);
    UART_writeData(UART, 'h'); delay(5);
    UART_writeData(UART, 't'); delay(5);
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, 'm'); delay(5);
    UART_writeData(UART, 'a'); delay(5);
    UART_writeData(UART, 'n'); delay(5);
    UART_writeData(UART, 'u'); delay(5);
    UART_writeData(UART, 'a'); delay(5);
    UART_writeData(UART, 'l'); delay(5);
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, 'm'); delay(5);
    UART_writeData(UART, 'o'); delay(5);
    UART_writeData(UART, 'd'); delay(5);
    UART_writeData(UART, 'e'); delay(5);
    UART_writeData(UART, ']'); delay(5);
    UART_writeData(UART, ' '); delay(5);
}



/***** Function Implementation *****/

// func1~3 : 초음파 자동 측정 모드
// func4,5 : 온습도 자동 측정 모드

// func1: 500 카운트 주기(0.5초 주기)로 LED 1번 토글, 초음파 측정 & UART tx 출력까지
void func1(uint32_t *prevTime, uint32_t *data, uint32_t *us_dist) {
    uint32_t curTime = TIM_readCount(TIM);
    if (curTime - *prevTime < 500) return;
    *prevTime = curTime;

    *data ^= 1 << 1;
    LED_write(GPIOC, *data);

    US_start(US, 1);
    US_start(US, 0);
    delay(100);
    uint32_t dist = US_dist_read(US);
    *us_dist = dist;  
    FND->HEX = dist;
    uint32_t bcd = fndBCD(FND);

    uart_us_auto_mode();
    UART_writeData(UART, ((bcd >> 24) & 0xff)); delay(5);
    UART_writeData(UART, ((bcd >> 16) & 0xff) ); delay(5);
    UART_writeData(UART, ((bcd >> 8) & 0xff)); delay(5);
    UART_writeData(UART, (bcd & 0xff)); delay(5);
    UART_writeData(UART, '\n');
}

// func2: 1000 카운트 주기(1초 주기)로 LED 2번 토글, 초음파 측정 & UART tx 출력까지
void func2(uint32_t *prevTime, uint32_t *data , uint32_t *us_dist) {
    uint32_t curTime = TIM_readCount(TIM);
    if (curTime - *prevTime < 1000) return;
    *prevTime = curTime;

    *data ^= 1 << 2;
    LED_write(GPIOC, *data);
    US_start(US, 1);
    US_start(US, 0);
    delay(100);
    uint32_t dist = US_dist_read(US);
    *us_dist = dist;  
    FND->HEX = dist;
    uint32_t bcd = fndBCD(FND);

    uart_us_auto_mode();
    UART_writeData(UART, ((bcd >> 24) & 0xff)); delay(5);
    UART_writeData(UART, ((bcd >> 16) & 0xff) ); delay(5);
    UART_writeData(UART, ((bcd >> 8) & 0xff)); delay(5);
    UART_writeData(UART, (bcd & 0xff)); delay(5);
    UART_writeData(UART, '\n');
}

// func3: 2000 카운트 주기(2초 주기)로 LED 3번 토글, 초음파 측정 & UART tx 출력까지
void func3(uint32_t *prevTime, uint32_t *data , uint32_t *us_dist) {
    uint32_t curTime = TIM_readCount(TIM);
    if (curTime - *prevTime < 2000) return;
    *prevTime = curTime;

    *data ^= 1 << 3;
    LED_write(GPIOC, *data);
  
    DHTinit(DHT, 1);
    delay(500);
    uint32_t temper = DHTreadTMP(DHT);
    uint32_t humid = DHTreadHMD(DHT);
    
    uint32_t dist = US_dist_read(US);
    *us_dist = dist;  
    FND->HEX = dist;
    uint32_t bcd = fndBCD(FND);

    uart_us_auto_mode();
    UART_writeData(UART, ((bcd >> 24) & 0xff)); delay(5);
    UART_writeData(UART, ((bcd >> 16) & 0xff) ); delay(5);
    UART_writeData(UART, ((bcd >> 8) & 0xff)); delay(5);
    UART_writeData(UART, (bcd & 0xff)); delay(5);
    UART_writeData(UART, '\n');
}

// func4: 10000 카운트 주기(10초 주기)로 LED 3번 토글, 온습도 측정 & UART tx 출력까지
void func4(uint32_t *prevTime, uint32_t *data , uint32_t *dht_t,uint32_t *dht_h ) {
    uint32_t curTime = TIM_readCount(TIM);
    if (curTime - *prevTime < 10000) return;
    *prevTime = curTime;

    *data ^= 1 << 4;
    LED_write(GPIOC, *data);  

    DHTinit(DHT, 1);
    delay(500);

    uint32_t temper = DHTreadTMP(DHT);
    uint32_t humid = DHTreadHMD(DHT);
    FND->HEX = temper;
    uint32_t bcd = fndBCD(FND);

    uart_temp_auto_mode();
    UART_writeData(UART, 't'); delay(5);
    UART_writeData(UART, '='); delay(5);
    UART_writeData(UART, ((bcd >> 24) & 0xff)); delay(5);
    UART_writeData(UART, ((bcd >> 16) & 0xff) ); delay(5);
    UART_writeData(UART, '.'); delay(5);
    UART_writeData(UART, ((bcd >> 8) & 0xff)); delay(5);
    UART_writeData(UART, (bcd & 0xff)); delay(5);
    UART_writeData(UART, ','); delay(5);
    FND->HEX = humid;
    uint32_t bcd_h = fndBCD(FND);
    UART_writeData(UART, 'h'); delay(5);
    UART_writeData(UART, '='); delay(5);
    UART_writeData(UART, ((bcd_h >> 24) & 0xff)); delay(5);
    UART_writeData(UART, ((bcd_h >> 16) & 0xff) ); delay(5);
    UART_writeData(UART, '.'); delay(5);
    UART_writeData(UART, ((bcd_h >> 8) & 0xff)); delay(5);
    UART_writeData(UART, (bcd_h & 0xff)); delay(5);
    UART_writeData(UART, '\n');

}

// func5: 20000 카운트 주기(20초 주기)로 LED 3번 토글, 초음파 측정 & UART tx 출력까지
void func5(uint32_t *prevTime, uint32_t *data , uint32_t *dht_t, uint32_t *dht_h ) {
    uint32_t curTime = TIM_readCount(TIM);
    if (curTime - *prevTime < 20000) return;
    *prevTime = curTime;

    *data ^= 1 << 3;
    LED_write(GPIOC, *data);
  
    DHTinit(DHT, 1);
    delay(500);

    uint32_t temper = DHTreadTMP(DHT);
    uint32_t humid = DHTreadHMD(DHT);
    FND->HEX = temper;
    uint32_t bcd = fndBCD(FND);

    uart_temp_auto_mode();
    UART_writeData(UART, 't'); delay(5);
    UART_writeData(UART, '='); delay(5);
    UART_writeData(UART, ((bcd >> 24) & 0xff)); delay(5);
    UART_writeData(UART, ((bcd >> 16) & 0xff) ); delay(5);
    UART_writeData(UART, '.'); delay(5);
    UART_writeData(UART, ((bcd >> 8) & 0xff)); delay(5);
    UART_writeData(UART, (bcd & 0xff)); delay(5);
    UART_writeData(UART, ','); delay(5);
    FND->HEX = humid;
    uint32_t bcd_h = fndBCD(FND);
    UART_writeData(UART, 'h'); delay(5);
    UART_writeData(UART, '='); delay(5);
    UART_writeData(UART, ((bcd_h >> 24) & 0xff)); delay(5);
    UART_writeData(UART, ((bcd_h >> 16) & 0xff) ); delay(5);
    UART_writeData(UART, '.'); delay(5);
    UART_writeData(UART, ((bcd_h >> 8) & 0xff)); delay(5);
    UART_writeData(UART, (bcd_h & 0xff)); delay(5);
    UART_writeData(UART, '\n');

}
