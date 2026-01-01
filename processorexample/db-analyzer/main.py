from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from openai import OpenAI
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Database Analyzer", description="Analyze database tables using OpenAI")

class QueryRequest(BaseModel):
    question: str

# OpenAI client with OpenRouter
client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=os.getenv("OPENROUTER_API_KEY", "TU_API_KEY_DE_OPENROUTER_AQUI")
)

def get_db_connection():
    return psycopg2.connect(
        host="postgres",
        database="nifi_db",
        user="nifi",
        password="nifi123"
    )

def extract_table(question):
    import re
    # Look for "tabla <name>"
    match = re.search(r'tabla\s+(\w+)', question.lower())
    if match:
        return match.group(1)
    # Fallback to known tables
    known_tables = ['users', 'orders', 'flink_results', 'products']
    for t in known_tables:
        if t in question.lower():
            return t
    return None

def query_table(table_name):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(f"SELECT COUNT(*) FROM {table_name}")
    count = cur.fetchone()[0]
    cur.execute(f"SELECT * FROM {table_name} LIMIT 10")
    rows = cur.fetchall()
    columns = [desc[0] for desc in cur.description]
    cur.close()
    conn.close()
    return count, rows, columns

def query_columns(table_name):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name = %s AND table_schema = 'public' ORDER BY ordinal_position", (table_name,))
    columns = [row[0] for row in cur.fetchall()]
    cur.close()
    conn.close()
    return columns

@app.post("/query")
async def query_database(request: QueryRequest):
    try:
        question = request.question.lower()
        table = None
        if "flink_results" in question or "flink_result" in question or "flink" in question:
            table = "flink_results"
        elif "orders" in question or "orden" in question:
            table = "orders"
        elif "users" in question or "usuario" in question:
            table = "users"
        if table is None:
            if "producto" in question or "productos" in question:
                table = "orders"
            else:
                raise HTTPException(status_code=400, detail="Question must mention users, orders, flink_results, or products")
        
        data = query_table(table)
        count, rows, columns = data

        # Convert data to text
        data_text = f"Total filas: {count}, Datos de muestra: {str(rows)}"

        # Answer with AI
        response = client.chat.completions.create(
            model="meta-llama/llama-3.2-3b-instruct:free",
            messages=[
                {"role": "user", "content": f"Responde a la pregunta: '{request.question}' basada en estos datos de la tabla {table}: {data_text}. Responde en español."}
            ],
            max_tokens=200
        )
        answer = response.choices[0].message.content
        return {"table": table, "answer": answer, "sample_data": rows[:5]}
    except Exception as e:
        print(f"Error: {type(e)} {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"message": "Database Analyzer is running. Use POST /query with {'question': 'describe users table'}"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)