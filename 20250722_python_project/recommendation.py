import json
import os
import random
import urllib.parse

SONG_FILE = "songs.json"

emotion_opposite = {
    "HAPPY": ["발라드 / 가요", "블루스/포크 / 가요", "R&B/소울 / 가요"],
    "SAD": ["댄스 / 가요", "일렉트로니카 / 가요", "인디 / 가요"],
    "ANGRY": ["발라드 / 가요", "블루스/포크 / 가요", "R&B/소울 / 가요"],
    "CALM": ["댄스 / 가요", "락 / 가요", "랩/힙합 / 가요", "일렉트로니카 / 가요"],
    "TIRED": ["댄스 / 가요", "락 / 가요", "일렉트로니카 / 가요", "랩/힙합 / 가요"],
    "FEAR": ["발라드 / 가요", "블루스/포크 / 가요", "R&B/소울 / 가요"],
    "SURPRISED": ["발라드 / 가요", "블루스/포크 / 가요"],
    "DISGUSTED": ["댄스 / 가요", "일렉트로니카 / 가요", "락 / 가요", "인디 / 가요"],
    "CONFUSED": ["인디 / 가요", "블루스/포크 / 가요", "발라드 / 가요"],
    "UNKNOWN": ["댄스 / 가요", "인디 / 가요", "일렉트로니카 / 가요", "랩/힙합 / 가요"]
}

def recommend_song(emotion: str, status: str):
    """감정 기반 상쇄 효과 추천 (상태 변수 직접 전달)"""
    if status != "노래로딩완료" or not os.path.exists(SONG_FILE):
        return {"message": "노래 리스트 없음"}

    with open(SONG_FILE, "r", encoding="utf-8") as f:
        songs = json.load(f)

    target_genres = emotion_opposite.get(emotion, ["댄스 / 가요"])
    filtered = [s for s in songs if s["genre"] in target_genres]

    if not filtered:
        return {"message": "추천할 곡이 없습니다."}

    rec = random.choice(filtered)

    # 유튜브 검색 쿼리 생성
    query = f"{rec['artists']} - {rec['title']}"
    youtube_search_url = "https://www.youtube.com/results?search_query=" + urllib.parse.quote(query)

    return {
        "message": f"{emotion} 기분을 상쇄할 추천곡입니다!",
        "title": rec["title"],
        "artist": rec["artists"],
        "genre": rec["genre"],
        "youtube_search_url": youtube_search_url
    }
