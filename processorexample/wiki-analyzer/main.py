from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from openai import OpenAI
import requests
from bs4 import BeautifulSoup
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Wikipedia Analyzer", description="Analyze Wikipedia pages using OpenAI")

class AnalyzeRequest(BaseModel):
    url: str
    question: str

# OpenAI client with OpenRouter
client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=os.getenv("OPENROUTER_API_KEY", "TU_API_KEY_DE_OPENROUTER_AQUI")  # Usar variable de entorno
)

def fetch_wikipedia_content(url):
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        raise HTTPException(status_code=400, detail="Failed to fetch Wikipedia page")
    soup = BeautifulSoup(response.content, 'html.parser')
    # Extract text from paragraphs
    paragraphs = soup.find_all('p')
    text = ' '.join([p.get_text() for p in paragraphs])
    return text[:1000]  # Limit for API

@app.post("/analyze")
async def analyze_wikipedia(request: AnalyzeRequest):
    try:
        content = fetch_wikipedia_content(request.url)
        print(f"Content length: {len(content)}")
        response = client.chat.completions.create(
            model="meta-llama/llama-3.2-3b-instruct:free",
            messages=[
                {"role": "user", "content": f"Responde a la pregunta: '{request.question}' basada en el contenido de la página de Wikipedia: {content}. Responde en español."}
            ],
            max_tokens=150
        )
        summary = response.choices[0].message.content
        return {"summary": summary}
    except Exception as e:
        print(f"Error: {type(e)} {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"message": "Wikipedia Analyzer is running with OpenAI. Use POST /analyze with {'url': 'wikipedia_url', 'question': 'your question'}"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)