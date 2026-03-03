const startBtn = document.getElementById('start-btn');
const fetchSongBtn = document.getElementById('fetch-song-btn');
const video = document.getElementById('video');
const emotionResult = document.getElementById('emotion-result');

const manualEmotionBtn = document.getElementById('manual-emotion-btn');
const manualEmotionInput = document.getElementById('manual-emotion-input');

const validEmotions = ["HAPPY", "SAD", "ANGRY", "CALM", "TIRED", "FEAR", "SURPRISED", "DISGUSTED", "CONFUSED", "UNKNOWN"];

// 노래 수집 버튼
fetchSongBtn.onclick = async () => {
    emotionResult.textContent = "노래 수집 상태: 노래 로딩중...";
    fetchSongBtn.disabled = true;

    try {
        await fetch('/fetch-song');

        const interval = setInterval(async () => {
            const res = await fetch('/status');
            const data = await res.json();

            if (data.status === "노래로딩완료") {
                clearInterval(interval);
                emotionResult.textContent = "노래 수집 상태: 노래 로딩완료";
            } else if (data.status === "노래 리스트 없음") {
                clearInterval(interval);
                emotionResult.textContent = "노래 수집 상태: 노래 리스트 없음 ";
            } else {
                emotionResult.textContent = "노래 수집 상태: " + data.status;
            }
        }, 3000);

    } catch (e) {
        emotionResult.textContent = "오류 발생: " + e.message;
        console.error(e);
    } finally {
        fetchSongBtn.disabled = false;
    }
};

// 자동 감정 분석 + 추천곡
startBtn.onclick = async () => {
    emotionResult.textContent = "카메라를 켜고 있습니다...";
    video.style.display = "none";

    try {
        const stream = await navigator.mediaDevices.getUserMedia({ video: true });
        video.srcObject = stream;
        video.style.display = "block";
        startBtn.disabled = true;
        emotionResult.textContent = "카메라가 켜졌습니다. 3초 후 사진을 찍습니다.";

        await new Promise(res => setTimeout(res, 3000));

        const canvas = document.createElement('canvas');
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

        stream.getTracks().forEach(track => track.stop());
        video.style.display = "none";

        const base64Image = canvas.toDataURL('image/jpeg');
        emotionResult.textContent = "감정을 분석 중입니다...";

        const res = await fetch('/analyze', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ image: base64Image })
        });

        if (!res.ok) throw new Error(`서버 응답 오류: ${res.status}`);
        const data = await res.json();
        const rawEmotion = (data.emotion || "UNKNOWN").split(" ")[0].toUpperCase();

        emotionResult.innerHTML =
            `<div>감지된 감정: <strong>${rawEmotion}</strong></div>`;

        const recommendRes = await fetch('/recommend', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ emotion: rawEmotion })
        });

        const recommendData = await recommendRes.json();

        if (recommendData.title) {
            emotionResult.innerHTML +=
                `<div>🎵 추천곡: ${recommendData.title} - ${recommendData.artist} [${recommendData.genre}] ` +
                `<a href="${recommendData.youtube_search_url}" target="_blank" style="color: blue; text-decoration: underline;">🎬 유튜브 보기</a></div>`;
        } else {
            emotionResult.innerHTML += `<div>⚠️ ${recommendData.message}</div>`;
        }

        startBtn.disabled = false;

    } catch (e) {
        emotionResult.textContent = "오류 발생: " + e.message;
        startBtn.disabled = false;
        console.error(e);
    }
};

// 수동 감정 입력 + 추천곡
manualEmotionBtn.onclick = async () => {
    const inputEmotion = manualEmotionInput.value.trim().toUpperCase();

    if (!inputEmotion) {
        alert("감정을 입력해주세요.");
        return;
    }

    if (!validEmotions.includes(inputEmotion)) {
        alert("지정된 감정 중 하나를 입력해주세요:\n" + validEmotions.join(", "));
        return;
    }

    emotionResult.innerHTML = `<div>선택된 감정: <strong>${inputEmotion}</strong></div>` +
        `<div>추천 음악을 불러오는 중...</div>`;

    try {
        const recommendRes = await fetch('/recommend', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ emotion: inputEmotion })
        });

        if (!recommendRes.ok) {
            throw new Error("추천 요청 실패");
        }

        const recommendData = await recommendRes.json();

        if (recommendData.title) {
            emotionResult.innerHTML =
                `<div>선택된 감정: <strong>${inputEmotion}</strong></div>` +
                `<div>🎵 추천곡: ${recommendData.title} - ${recommendData.artist} [${recommendData.genre}] ` +
                `<a href="${recommendData.youtube_search_url}" target="_blank" style="color: blue; text-decoration: underline;">🎬 유튜브 보기</a></div>`;
        } else {
            emotionResult.innerHTML = `<div>⚠️ ${recommendData.message}</div>`;
        }

    } catch (e) {
        emotionResult.textContent = "오류 발생: " + e.message;
        console.error(e);
    }
};
