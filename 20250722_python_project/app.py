from flask import Flask, request, jsonify, render_template
import urllib.parse
import base64
import threading
import json
import os

from face_rekognition_flask import analyze_emotion
from crawling import main as crawl_main
from recommendation import recommend_song

app = Flask(__name__)


song_status = "노래 리스트 없음"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/analyze', methods=['POST'])
def analyze():
    """감정 분석"""
    data = request.get_json()
    image_data = data['image'].split(',')[1]
    image_bytes = base64.b64decode(image_data)
    emotion = analyze_emotion(image_bytes)
    return jsonify({'emotion': emotion})

@app.route('/fetch-song')
def fetch_song():
    """크롤링 시작 & 상태 변경"""
    global song_status
    song_status = "노래로딩중"

    def run_crawling():
        global song_status
        try:
            crawl_main()
            song_status = "노래로딩완료"
        except Exception as e:
            song_status = "노래 리스트 없음"
            print(f"[크롤링 오류]: {e}")

    threading.Thread(target=run_crawling).start()
    return jsonify({"status": song_status})

@app.route('/status')
def status():
    """현재 노래 수집 상태 전달"""
    return jsonify({"status": song_status})

@app.route('/recommend', methods=['POST'])
def recommend():
    """감정 기반 추천"""
    data = request.get_json()
    user_emotion = data.get("emotion", "UNKNOWN").upper()
    result = recommend_song(user_emotion, song_status)
    return jsonify(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
