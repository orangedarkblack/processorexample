# Instrucciones rápidas para ejecutar la aplicación Flink

Sigue estos pasos para ejecutar manualmente el job SQL de Flink en este proyecto.

1) Verificar que la pila esté arriba

   - Lista los servicios:
     `docker-compose -f docker-compose-full.yml ps`

2) Comprobar recursos en Flink (TaskManagers / slots)

   - Consultar TaskManagers y freeSlots:
     `curl -s http://localhost:8081/taskmanagers`

3) Enviar los scripts SQL (desde el contenedor `flink-sql-client`)

   **Opción A: Procesar datos en tiempo real desde Kafka → PostgreSQL**
   
   - Envío interactivo/normal:
     `docker-compose -f docker-compose-full.yml exec -T flink-sql-client /opt/flink/bin/sql-client.sh -f /opt/flink/scripts/kafta-to-postgres.sql`

   - One-shot (ejecuta y sale):
     `docker-compose -f docker-compose-full.yml run --rm flink-sql-client /opt/flink/bin/sql-client.sh -f /opt/flink/scripts/kafta-to-postgres.sql`

   **Opción B: Procesar datos históricos desde PostgreSQL → PostgreSQL**
   
   - Envío interactivo/normal:
     `docker-compose -f docker-compose-full.yml exec -T flink-sql-client /opt/flink/bin/sql-client.sh -f /opt/flink/scripts/postgres-to-postgres.sql`

   - One-shot (ejecuta y sale):
     `docker-compose -f docker-compose-full.yml run --rm flink-sql-client /opt/flink/bin/sql-client.sh -f /opt/flink/scripts/postgres-to-postgres.sql`

4) Verificar jobs desplegados

   - Lista jobs:
     `curl -s http://localhost:8081/jobs`

   - Ver detalles de un job:
     `curl -s http://localhost:8081/jobs/<JOB_ID>`

5) Logs y diagnóstico

   - JobManager logs:
     `docker-compose -f docker-compose-full.yml logs -f flink-jobmanager`

   - TaskManager logs:
     `docker-compose -f docker-compose-full.yml logs -f flink-taskmanager`

6) Subir y ejecutar un JAR (si tu job está empaquetado como JAR)

   - Subir JAR:
     `curl -v -X POST -F "jarfile=@/path/to/your-job.jar" http://localhost:8081/jars/upload`

   - Ejecutar JAR (suponiendo que recibes jarId en la respuesta):
     `curl -X POST "http://localhost:8081/jars/<jarId>/run" -H 'Content-Type: application/json' -d '{}'`

7) Problemas comunes y soluciones rápidas

   - `freeSlots` = 0: asegúrate que hay TaskManagers con slots libres. Revisa `taskmanagers` y reinicia TaskManagers si es necesario.
   - Missing TableFactory / connector errors: comprueba que los JARs necesarios (Kafka, JDBC, connector-jdbc) están en `/opt/flink/lib` dentro de las imágenes `flink-jobmanager` / `flink-taskmanager` / `flink-sql-client`.
   - Checkpoint/permiso: si Flink no puede crear checkpoints, asegúrate que el directorio de checkpoints montado tiene permisos para el usuario `flink`.
   - Kafka bootstrap: en los scripts usamos `kafka:29092` (service name). Si ejecutas fuera de Docker ajusta `properties.bootstrap.servers` a `localhost:9092`.
   - Offsets: si obtienes `NoOffsetForPartitionException`, configura `'scan.startup.mode' = 'earliest-offset'` o establece `properties.auto.offset.reset = 'earliest'` en las fuentes Kafka.

8) Recomendación para automatizar (opcional)

   - Añade un service one-shot en `docker-compose` que espere a que JobManager tenga slots libres y posteriormente ejecute el `sql-client.sh -f ...`. Esto evita condiciones de carrera al iniciar la pila.

---

## Scripts disponibles

- **`kafta-to-postgres.sql`**: Procesa eventos en TIEMPO REAL desde Kafka (users-topic y orders-topic) y escribe los resultados en PostgreSQL (flink_results). Ideal para monitoreo y dashboards en tiempo real.

- **`postgres-to-postgres.sql`**: Procesa datos HISTÓRICOS almacenados en PostgreSQL (tablas users y orders) y escribe los resultados en PostgreSQL (flink_results). Ideal para reportes y análisis batch.

---

Si quieres, puedo ahora ejecutar alguno de los scripts SQL por ti (paso 3) o añadir un servicio one-shot para que se ejecute automáticamente al levantar la pila.  
