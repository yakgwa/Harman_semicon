#include <stdio.h>
#include <stdint.h>
#include <sleep.h>
#include "platform.h"
#include "xil_printf.h"

typedef struct {
   volatile uint32_t CMD;
   volatile uint32_t tx_data;
   volatile uint32_t rx_data;
   volatile uint32_t SR;
} IIC_typedef;

typedef enum {
   IDLE_CMD = 0,
   START_CMD = 1,
   STOP_CMD = 2,
   RESTART_CMD = 3,
   RD_CMD = 4,
   WR_CM = 5
} IIC_CMD;

#define IIC_BASEADDR 0x44a00000
#define IIC ((IIC_typedef *) IIC_BASEADDR)

void start_transmission(IIC_typedef * iic, uint32_t target_slaveNum, uint32_t start_regAddr);
void write_IIC(IIC_typedef * iic, uint32_t data);
void stop_transmission(IIC_typedef * iic);

int main() {
   init_platform();

   uint32_t target_slaveNum = 0b00000000;
   uint32_t start_regAddr = 0b00000000;
   uint32_t data = 0xaa;
   uint32_t count = 0;

   start_transmission(IIC, target_slaveNum, start_regAddr);
   print("Start Transmission!\n");
   while(1){
      write_IIC(IIC, data);
      if(count++ == 10000) {
         data = ~data;
         count = 0;
      }
   }
   stop_transmission(IIC);
   print("Stop Transmission!\n");

   cleanup_platform();
   return 0;
}

void start_transmission(IIC_typedef * iic, uint32_t target_slaveNum, uint32_t start_regAddr) {
   iic->CMD = START_CMD;
   iic->CMD = IDLE_CMD;
   while (!(iic->SR & (1 << 2)));
   write_IIC(iic, target_slaveNum);
   write_IIC(iic, start_regAddr);
}

void write_IIC(IIC_typedef * iic, uint32_t data) {
   iic->tx_data = data;
   iic->CMD = WR_CM;
   iic->CMD = IDLE_CMD;
   while (!(iic->SR & (1 << 2)));
}

void stop_transmission(IIC_typedef * iic) {
   iic->CMD = STOP_CMD;
   iic->CMD = IDLE_CMD;
   while (!(iic->SR & (1 << 2)));
}
