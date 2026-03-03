import serial
import numpy as np
from PIL import Image

# ===============================
# UART 설정
# ===============================
PORT = "COM4"        # Windows에서는 COM4 그대로
BAUD = 115200
WIDTH = 320
HEIGHT = 240
BYTES_PER_PIXEL = 2

FRAME_SIZE = WIDTH * HEIGHT * BYTES_PER_PIXEL

print("Opening serial...")
ser = serial.Serial(PORT, BAUD, timeout=20)
print("Serial opened")

# ===============================
# 프레임 수신
# ===============================
print("Waiting for frame...")
raw = bytearray()

while len(raw) < FRAME_SIZE:
    chunk = ser.read(FRAME_SIZE - len(raw))
    if chunk:
        raw.extend(chunk)
        print(f"\rReceived {len(raw)}/{FRAME_SIZE} bytes", end="")

print("\nFrame received")
ser.close()

# ===============================
# RGB565 → RGB888 변환
# ===============================
img = np.zeros((HEIGHT, WIDTH, 3), dtype=np.uint8)

idx = 0
for y in range(HEIGHT):
    for x in range(WIDTH):
        # 두 바이트를 합쳐 16비트 생성
        pixel = (raw[idx] << 8) | raw[idx + 1]
        idx += 2

        # 비트 마스킹 및 추출
        r = (pixel >> 11) & 0x1F  # 상위 5비트
        g = (pixel >> 5) & 0x3F   # 중간 6비트
        b = (pixel) & 0x1F        # 하위 5비트

        # 8비트(0~255) 스케일링
        # 단순히 8을 곱하는 것보다 비트를 채워주는 방식이 더 정확합니다.
        img[y, x, 0] = (r * 255) // 31
        img[y, x, 1] = (g * 255) // 63
        img[y, x, 2] = (b * 255) // 31
# ===============================
# 이미지 저장
# ===============================
image = Image.fromarray(img, "RGB")
image.save("capture.png")

image.show()

print("Saved as capture.png")
