
from flask import Flask
from datetime import datetime
import os

app = Flask(__name__)

@app.route('/')
def home():
    """Muestra la hora actual del servidor."""
    now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    return f'<h1>La hora actual del servidor es: {now}</h1>'

if __name__ == "__main__":
    # El puerto es definido por la variable de entorno PORT, o 8080 si no está definida.
    # Escucha en 0.0.0.0 para ser accesible desde fuera del contenedor.
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
