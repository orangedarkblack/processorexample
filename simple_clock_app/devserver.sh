#!/bin/bash

# Navega al directorio del script para que todo se ejecute en el contexto correcto
cd "$(dirname "$0")"

# Activa el entorno virtual (asumiendo que está en la raíz del proyecto general)
source ../.venv/bin/activate

# Instala las dependencias específicas de esta app
pip install -r requirements.txt

# Ejecuta la aplicación de Python
python main.py
