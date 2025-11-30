from selenium import webdriver as wb # 브라우저 제어
from selenium.webdriver.common.by import By # 선택자 구분
from selenium.webdriver.common.keys import Keys # 키보드 제어
from selenium.webdriver.chrome.options import Options
import time, json, os
import pandas as pd
import tempfile
import shutil


def get_driver():
    chrome_options = Options()
    chrome_options.add_argument("--headless")  # GUI 비활성화
    chrome_options.add_argument("--no-sandbox")  # 샌드박스 비활성화(EC2 필수)
    chrome_options.add_argument("--disable-dev-shm-usage")  # /dev/shm 사용 최소화
    chrome_options.add_argument("--disable-gpu")  # GPU 비활성화
    chrome_options.add_argument("--disable-extensions")  # 확장 프로그램 비활성화
    chrome_options.add_argument("--disable-software-rasterizer")  # 소프트웨어 렌더링 비활성화
    chrome_options.add_argument("--blink-settings=imagesEnabled=false")  # ✅ 이미지 로딩 비활성화
    chrome_options.add_argument("--window-size=1920x1080")  # 크기 고정(렌더링 최적화)

    # 고유한 user-data-dir 사용 (동시 크롤링 세션 충돌 방지)
    unique_tmp = tempfile.mkdtemp(prefix="chrome_profile_")
    chrome_options.add_argument(f"--user-data-dir={unique_tmp}")

    driver = wb.Chrome(options=chrome_options)

    # 드라이버 종료 후 임시 디렉토리 삭제 보장
    def cleanup():
        try:
            driver.quit()
        finally:
            shutil.rmtree(unique_tmp, ignore_errors=True)

    driver.cleanup = cleanup
    return driver

def crawl_song(driver, genre_selector, tab_selector):
    
    time.sleep(2)
    driver.find_element(By.CSS_SELECTOR, 'a[href="/genre/M0100"]').click()
    body = driver.find_element(By.CSS_SELECTOR, 'div.top-title-line').click()
    driver.find_element(By.CSS_SELECTOR, genre_selector).click()
    body = driver.find_element(By.CSS_SELECTOR, 'div.top-title-line').click()
    driver.find_element(By.CSS_SELECTOR, tab_selector).click()
    body = driver.find_element(By.CSS_SELECTOR, 'div.top-title-line').click()
    driver.find_element(By.CSS_SELECTOR, 'a.cover').click()
    time.sleep(1)
    title = driver.find_element(By.CSS_SELECTOR,"h2.name").text
    artists = driver.find_elements(By.CSS_SELECTOR,"span.value")[0].text
    genre = driver.find_elements(By.CSS_SELECTOR,"span.value")[1].text
    date = driver.find_elements(By.CSS_SELECTOR,"span.value")[4].text
    return {
        "genre": genre,
        "artists": artists,
        "title": title,
        "date": date
    }
def save_song(song_list, file_path="songs.json"):
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(song_list, f, ensure_ascii=False, indent=2)

def main():
    driver = get_driver()  
    url_genie = "https://www.genie.co.kr/chart/genre"
    driver.maximize_window()
    driver.get(url_genie)

    targets = [
        'a[href="L0101"]',
        'a[href="L0102"]',
        'a[href="L0103"]',
        'a[href="L0105"]',
        'a[href="L0104"]',
        'a[href="L0106"]',
        'a[href="L0109"]',
        'a[href="L0108"]'
    ]

    all_songs = []
    for tab_selector in targets:
        new_song = crawl_song(driver, 'a[href="/genre/M0100"]', tab_selector)
        all_songs.append(new_song)
        print(f"[저장 완료] {new_song['title']} by {new_song['artists']}")

    save_song(all_songs)  #한 번에 저장
    driver.quit()

if __name__ == "__main__":
    main()