## Harman Semiconductor Academy

<div align="center">

[<img src="https://img.shields.io/badge/-readme.md-important?style=flat&logo=google-chrome&logoColor=white" />]() [<img src="https://img.shields.io/badge/release-v1.0.0-ㅎㄱㄷ두?style=flat&logo=google-chrome&logoColor=white" />]() 
<br/> [<img src="https://img.shields.io/badge/프로젝트 기간-2025.07.01~2026.01.26-fab2ac?style=flat&logo=&logoColor=white" />]()

</div> 

<div align="left">

- 사용 언어 : Verilog, VHDL, C, SystemVerilog, UVM
- 프로젝트 수행 경험
  - Python을 사용한 감정 인식 기반 맞춤형 음악 추천 시스템 
    - 역할 : 데이터 수집, 전처리 
    - 결과 : MediaPipe라는 AI Cloud Service를 통해 카메라로 감정을 분석하고 웹데이터를 크롤링하여 추천 리스트를 실시간으로 업데이트하는 알고리즘 구현
  - Verilog를 사용한 UART Logic Controller
    - 역할 : DHT11(온습도계) Driver 설계 및 Simulation
    - 결과 : Button Debouncer를 이용한 Button, ComportMaster를 이용한 UART 통신으로 온습도 Data FND로 출력 및 Simulation으로 동작 확인
  - SystemVerilog를 사용한 RISCV APB Peripheral
    - 역할 : APB Interface Design 및 Peripheral Connect
    - 결과 : APB Interface의 Register를 설정 및 연결하고 C Complier를 통해 합성 후, ComportMaster를 통한 동작 확인
  - SystemVerilog를 사용한 SPI / I2C Master to Slave Controller
    - 역할 : VITIS를 이용한 SPI, I2C Master, Slave 구현
    - 결과 : VITIS를 이용한 SPI, I2C Master Module, Slave Module을 구현하고 Master로 신호가 들어왔을 때 Slave에서 FND, LED로 출력함으로써 동작 확인 및 Simulation으로 동작 확인
  - SystemVerilog를 사용한 Flag Game
    - 역할 : Color, Region Detector 설계 및 출력 텍스트 구현
    - 결과 : 정확한 Color, Region Detect 구현을 위한 Image Processing Filter 설계하여 Module로 입력 신호가 들어왔을 때 VGA 모니터에 동작에 맞는 텍스트 출력
  - SystemVerilog를 사용한 무인 드론 방공망 System
    - 역할 : VGA System Design, VGA Debugging, UI 제작
    - 결과 : Camera 상으로 Red 객체가 들어왔을 때 좌표 떨림 밑 박스가 쪼개지는 현상없이 SPI를 통해 객체의 중심 좌표가 제대로 출력 및 HDMI를 통한 출력 확인

- 프로젝트 언어 사용 경험
  - C : STM32 기반의 Firmware Software 설계
  - Python : 감정 인식 기반 맞춤형 음악 추천 시스템 설계
  - Verilog : FND Controller, UART, StopWatch, SR04, DHT11 설계
  - Systemverilog : UART, RISCV SingleCycle, RISCV MultiCycle, APB, AXI, SPI, I2C, VGA Controller 설계
  - UVM : UVM 구조를 이용해 UART 검증, VCS Tool을 이용하여 SPI, I2C Protocol UVM 검증
