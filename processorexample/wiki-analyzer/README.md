# Wikipedia Analyzer

Este servicio analiza páginas de Wikipedia usando modelos de Hugging Face en línea (sin descargar modelos localmente).

## Uso

1. Ejecuta el servicio: `docker-compose up wiki-analyzer`

2. Envía una solicitud POST a `http://localhost:8001/analyze` con JSON: `{"url": "https://en.wikipedia.org/wiki/Example"}`

3. Recibe un resumen del contenido.

## Modelo

Usa `facebook/bart-large-cnn` vía API de Hugging Face, todo en línea.