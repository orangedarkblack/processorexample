
curl -X POST http://localhost:8002/query -H "Content-Type: application/json" -d '{"question": "cuántos pedidos se completaron en mi tabla orders"}'


curl -X POST http://localhost:8002/query -H "Content-Type: application/json" -d '{"question": "hay pedidos de teclados que se hallan completado en mi tabla orders"}'

curl -X POST http://localhost:8002/query -H "Content-Type: application/json" -d '{"question": "que productos hay en  pedidos completados en mi tabla orders"}'

curl -X POST http://localhost:8002/query -H "Content-Type: application/json" -d '{"question": "que hay en mi db orders"}'

