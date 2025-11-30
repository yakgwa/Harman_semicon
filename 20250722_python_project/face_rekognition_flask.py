# face_rekognition_flask.py

import boto3
import cv2
import numpy as np
import mediapipe as mp

# AWS Rekognition client (IAM 역할 기반 인증)
rekognition = boto3.client("rekognition", region_name="us-west-2")

# Mediapipe 초기화
mp_face_mesh = mp.solutions.face_mesh
face_mesh = mp_face_mesh.FaceMesh(static_image_mode=True, refine_landmarks=True)

def euclidean(p1, p2):
    import numpy as np
    return np.linalg.norm(np.array(p1) - np.array(p2))

def get_eye_open_ratio(landmarks):
    left_eye_top = landmarks[159]
    left_eye_bottom = landmarks[145]
    right_eye_top = landmarks[386]
    right_eye_bottom = landmarks[374]
    face_width = euclidean(landmarks[127], landmarks[356])
    return (euclidean(left_eye_top, left_eye_bottom) +
            euclidean(right_eye_top, right_eye_bottom)) / (2 * face_width)

def analyze_emotion(image_bytes: bytes) -> str:
    """이미지 바이트를 받아 감정 레이블 반환"""
    # Rekognition 감정 분석
    rekog_response = rekognition.detect_faces(
        Image={'Bytes': image_bytes},
        Attributes=['ALL']
    )

    # Mediapipe 눈 감김 분석
    np_arr = np.frombuffer(image_bytes, np.uint8)
    frame = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = face_mesh.process(frame_rgb)

    eye_open_ratio = None
    if results.multi_face_landmarks:
        landmarks = [(lm.x, lm.y) for lm in results.multi_face_landmarks[0].landmark]
        eye_open_ratio = get_eye_open_ratio(landmarks)

    # 감정 결정
    if rekog_response["FaceDetails"]:
        emotions = rekog_response["FaceDetails"][0]["Emotions"]
        top_emotion = max(emotions, key=lambda x: x["Confidence"])
        label = f"{top_emotion['Type']} ({top_emotion['Confidence']:.1f}%)"

        # 눈 감김 비율로 Tired 보정
        if top_emotion['Type'] == 'CALM' and eye_open_ratio and eye_open_ratio < 0.032:
            label = f"Tired (eye_open {eye_open_ratio:.3f})"
    else:
        label = "No Face Detected"

    return label
# 최종 반환 감정 HAPPY, SAD, ANGRY, CONFUSED, DISGUSTED, SURPRISED, CALM, FEAR, UNKNOWN, Tired
