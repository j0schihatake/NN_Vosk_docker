from fastapi import FastAPI, File, UploadFile, Response
from pydantic import BaseModel
from stt import transcribe

app = FastAPI()


class TranscribeRequest(BaseModel):
    audio: bytes


class TTSRequest(BaseModel):
    text: str
    speaker: str


@app.get("/")
async def hello():
    return {"hello": "from vosk"}


@app.post("/vosk")
async def transcribes(request: TranscribeRequest):
    audio = request.audio
    text = await transcribe(audio)
    return {"text": text}
