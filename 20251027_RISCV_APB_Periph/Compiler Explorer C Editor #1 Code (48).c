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
#define LEFT  0
#define RIGHT 1

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

// UART 제어 함수
uint32_t UART_state(UART_TypeDef *UARTx);
void UART_loop (UART_TypeDef *UARTx);
void UART_writeData (UART_TypeDef *UARTx, uint32_t data);
uint32_t UART_readData(UART_TypeDef *UARTx);
void uart_message();
void UART_init(UART_TypeDef *UARTx);
void uart_message_start();
void uart_message_clear();
void uart_message_stop();

void LED_leftShift(GPO_TypeDef *GPOx, uint32_t *pData);
void LED_rightShift(GPO_TypeDef *GPOx, uint32_t *pData);
void System_init();

int main() {
    GPOA->MODER = 0xFF;
    uint32_t ledData = 0x01;
    int ledState = LEFT; 
    UART_init(UART);
    GPO_init(GPOA);

    while (1) {
        if (UART_state(UART) & (1<<0)) {
            uint32_t r = UART_readData(UART);
            if (r == 'r') { ledState = LEFT; uart_message_start(); }
            else if (r == 'c') { uart_message_clear(); } 
            else if (r == 's') { ledState = RIGHT; uart_message_stop(); }
        }

        if (ledState == LEFT) {
            LED_leftShift(GPOA, &ledData);
        } else {
            LED_rightShift(GPOA, &ledData);
        }

    delay(200);
}
    // while (1) {
    //     // RX에 데이터가 있으면 읽기
    //     if (UART_state(UART) & (1<<0)) {
    //         uint32_t r = UART_readData(UART);

    //         if (r == 'r') {
    //             ledState = LEFT; 
    //             uart_message_start();
    //         }
    //         else if (r == 'c') {
    //             uart_message_clear();
    //         }
    //         else if (r == 's'){
    //             ledState = RIGHT;  
    //             uart_message_stop();
                
    //         }
    //     }

    //     LED_write(GPOA, ledData);
    //     delay(200);

            // TX 준비될 때까지 대기
        //     while (!(UART_state(UART) & (1<<1))) {
        //         ; // 그냥 대기
        //     }

        //     // LED 시프트
        //     if(ledState == LEFT) {
        //         LED_leftShift(&ledData);
        //     } else {
        //         LED_rightShift(&ledData);
        //     }
        
        //     delay(5);
} 



/********************************************************
 * 기본 유틸리티 함수
 ********************************************************/

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

void LED_leftShift(GPO_TypeDef *GPOx, uint32_t *pData) {
    *pData = (*pData << 1) | (*pData >> 7); // 8비트 순환
    GPOx->ODR = *pData;                     // 바로 레지스터에 출력
}

void LED_rightShift(GPO_TypeDef *GPOx, uint32_t *pData) {
    *pData = (*pData >> 1) | (*pData << 7); // 8비트 순환
    GPOx->ODR = *pData;                     // 바로 레지스터에 출력
}

/********************************************************
 * UART FIFO 함수
 ********************************************************/

void UART_init(UART_TypeDef *UARTx) {
    // 가상의 예시
    UARTx->ULS = 0x01;  // FIFO enable, 기타 설정
    // 보레이트, 데이터 비트, 정지 비트 등 설정
}

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

void uart_message_start(){
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, 's'); delay(5);
    UART_writeData(UART, 't'); delay(5);
    UART_writeData(UART, 'a'); delay(5);
    UART_writeData(UART, 'r'); delay(5);
    UART_writeData(UART, 't'); delay(5);
    UART_writeData(UART, '!'); delay(5);
    UART_writeData(UART, '!'); delay(5);
    UART_writeData(UART, ' '); delay(5);
}

void uart_message_clear(){
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, 'c'); delay(5);
    UART_writeData(UART, 'l'); delay(5);
    UART_writeData(UART, 'e'); delay(5);
    UART_writeData(UART, 'a'); delay(5);
    UART_writeData(UART, 'r'); delay(5);
    UART_writeData(UART, '!'); delay(5);
    UART_writeData(UART, '!'); delay(5);
    UART_writeData(UART, ' '); delay(5);
}

void uart_message_stop(){
    UART_writeData(UART, ' '); delay(5);
    UART_writeData(UART, 's'); delay(5);
    UART_writeData(UART, 't'); delay(5);
    UART_writeData(UART, 'o'); delay(5);
    UART_writeData(UART, 'p'); delay(5);
    UART_writeData(UART, '!'); delay(5);
    UART_writeData(UART, '!'); delay(5);
    UART_writeData(UART, ' '); delay(5);
}
// #include <stdint.h>
// #define __IO volatile

// typedef struct {
//     __IO uint32_t USR;
//     __IO uint32_t ULS;
//     __IO uint32_t UWD;
//     __IO uint32_t URD;
// }UART_TypeDef;

// #define APB_BASE_ADDR 0x10000000
// #define GPO_OFFSET 0x1000
// #define GPI_OFFSET 0x2000
// #define GPIO_OFFSET 0x3000
// #define FND_OFFSET 0x4000
// #define UART_OFFSET 0x5000


// #define GPO_BASE_ADDR (APB_BASE_ADDR + GPO_OFFSET)
// #define GPI_BASE_ADDR (APB_BASE_ADDR + GPI_OFFSET)
// #define GPIO_BASE_ADDR (APB_BASE_ADDR + GPIO_OFFSET)
// #define FND_BASE_ADDR (APB_BASE_ADDR + FND_OFFSET)
// #define UART_BASE_ADDR (APB_BASE_ADDR + UART_OFFSET)

// #define GPO_CR (*(uint32_t *)(GPO_BASE_ADDR + 0x00))
// #define GPO_ODR (*(uint32_t *)(GPO_BASE_ADDR + 0x04))
// #define GPI_CR (*(uint32_t *)(GPI_BASE_ADDR + 0x00))
// #define GPI_IDR (*(uint32_t *)(GPI_BASE_ADDR + 0x04))
// #define GPIO_CR (*(uint32_t *)(GPIO_BASE_ADDR + 0x00))
// #define GPIO_ODR (*(uint32_t *)(GPIO_BASE_ADDR + 0x04))
// #define GPIO_IDR (*(uint32_t *)(GPIO_BASE_ADDR + 0x08))
// #define FND_EN (*(uint32_t *)(FND_BASE_ADDR + 0x00))
// #define FND_FDR (*(uint32_t *)(FND_BASE_ADDR + 0x04))
// #define FND_FPR (*(uint32_t *)(FND_BASE_ADDR + 0x08))
// #define UART   ((UART_TypeDef *) UART_BASE_ADDR)
// // #define UART_USR (*(uint32_t *)(UART_BASE_ADDR + 0x00))
// // #define UART_ULS (*(uint32_t *)(UART_BASE_ADDR + 0x04))
// // #define UART_UWD (*(uint32_t *)(UART_BASE_ADDR + 0x08))
// // #define UART_URD (*(uint32_t *)(UART_BASE_ADDR + 0x0C))

// void System_init();
// void delay(uint32_t t);
// void LED_write(uint32_t data);
// void LED_leftShift(uint32_t *pData);
// void LED_rightShift(uint32_t *pData);

// uint32_t UART_state(UART_TypeDef *UARTx);
// void UART_loop (UART_TypeDef *UARTx);
// void UART_writeData (UART_TypeDef *UARTx, uint32_t data);
// uint32_t UART_readData(UART_TypeDef *UARTx);

// enum {LEFT, RIGHT};

// int main()
// {   
//     int ledData = 0x01;// Led가 있는 위치 데이터, 이 데이터를 왼쪽을 보냈다가 오른쪽을 보냄
//     int ledState = LEFT;
//     System_init();
//     uint32_t uart_rdata_us = 0;
//     uint32_t uart_rdata_temp = 0;

//     while (1) {

//         if (!(UART_state(UART) & (1<<0))) { // rx empty가 아닐때 읽기
//                         ledState = RIGHT;
//                         uint32_t r = UART_readData(UART);
//                         uart_rdata_us = r;
//                         uart_rdata_temp = r;

//                         UART_writeData (UART, r);
//                         UART_writeData (UART, '\n');
//                 }
//         else if((uart_rdata_us == 'u' || uart_rdata_us == 'U')) ledState = LEFT;
//         break;
//     }


//     //     if(!(GPIO_IDR & (1<<7))) {
//     //         ledState = LEFT; 
//     // }
//     //     else {
//     //         ledState = RIGHT; 
//     //     }

//         LED_write(ledData);
//         delay(200);

//         switch(ledState)
//         {
//             case LEFT:
//                 ledData = ledData << 1 | ledData >> 7; // LED_leftShift(&ledData);
//             break;
//             case RIGHT:
//                 ledData = ledData >> 1 | ledData << 7; // LED_rightShift(&ledData);
//             break;
//         }
//     }
// //         GPO_ODR = GPI_IDR;
// //         GPIO_ODR = (GPIO_IDR>>4);



// void delay(uint32_t t)
// {
//     uint32_t temp = 0;;

//     for (int i = 0; i < t; i++){
//         for(int j = 0; j < 1000; j++){
//             temp++;
//         }
//     }
// }

// void System_init()
// {
//     GPO_CR = 0xff;
//     GPI_CR = 0xff;
//     GPIO_CR = 0x0f;
// }

// void LED_write(uint32_t data)
// {
//     GPO_ODR = data;
// }

// void LED_leftShift(uint32_t *pData)
// {
//     *pData = *pData << 1 | *pData >> 7;
// }

// void LED_rightShift(uint32_t *pData)
// {
//     *pData = *pData >> 1 | *pData << 7;
// }

// void FND_init(uint32_t ON_OFF)
// {
//     FND_EN = ON_OFF;
// }


// void FND_writeData(uint32_t data)
// {
//     FND_FDR = data;
// }

// // UART FIFO 상태 확인
// uint32_t UART_state(UART_TypeDef *UARTx) {
//     return UARTx->USR;
// }


// // FIFO에 데이터 쓰기 (Loopback 테스트용)
// void UART_loop (UART_TypeDef *UARTx) {
//     UARTx->UWD = UARTx->URD;
// }

// void UART_writeData (UART_TypeDef *UARTx, uint32_t data) {
//     UARTx->UWD = data;
// }

// // FIFO에서 데이터 읽기
// uint32_t UART_readData(UART_TypeDef *UARTx) {
//     return UARTx->URD;
// }


// #include <stdint.h>

// #define RAM_BASE_ADDR 0x10000000
// #define GPO_BASE_ADDR 0x10001000
// #define GPO_MODER (*(uint32_t *)(GPO_BASE_ADDR + 0x00))
// #define GPO_ODR (*(uint32_t *)(GPO_BASE_ADDR + 0x04))

// void delay(uint32_t t);

// int main()
// {
//     uint32_t a;

//     *(uint32_t *)(RAM_BASE_ADDR) = 0x1;
//     a = *(uint32_t *)(RAM_BASE_ADDR);

//     GPO_MODER = 0x0f;
//     while(1)
//     {
//         GPO_ODR = 0xf;
//         delay(300);
//         GPO_ODR = 0x0;
//         delay(300);
//     }

//     return 0;
// }

