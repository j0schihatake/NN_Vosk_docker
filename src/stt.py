import vosk
import asyncio
import json
import io

model = vosk.Model("model")
recognizer = None


async def initialize():
    global recognizer
    recognizer = vosk.KaldiRecognizer(model, 16000)


async def transcribe(audio_bytes):
    await initialize()

    audio_stream = io.BytesIO(audio_bytes)
    while True:
        data = audio_stream.read(4000)
        if len(data) == 0:
            break
        if recognizer.AcceptWaveform(data):
            result = recognizer.Result()
            text = json.loads(result)["text"]
            return text

    result = recognizer.FinalResult()
    text = json.loads(result)["text"]
    print("Transcribt text: " + text)
    return text
