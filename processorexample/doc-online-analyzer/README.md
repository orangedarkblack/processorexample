# Dropbox Document Analyzer

Este servicio analiza documentos desde enlaces compartidos de Dropbox usando OpenRouter (sin descargar los archivos localmente, sin Qdrant).

## Uso

1. Ejecuta el servicio: `docker-compose up dropbox-analyzer`

2. Envía una solicitud POST a `http://localhost:8003/analyze` con JSON: `{"url": "https://www.dropbox.com/s/example/file.pdf?dl=0", "question": "¿Cuál es el resumen del documento?"}`

3. Recibe una respuesta basada en el contenido del documento.

## Modelo

Usa `meta-llama/llama-3.2-3b-instruct:free` vía OpenRouter, el mismo que db-analyzer.

## Formatos soportados

- PDF
- DOCX
- TXT