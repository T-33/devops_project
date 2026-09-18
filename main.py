from fastapi import FastAPI
import uvicorn

app = FastAPI()

@app.get("/")
def index():
    return "Some main page"

def add(a: float, b: float) -> float:
    return a + b

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8080, reload=True)