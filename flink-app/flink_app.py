from pyflink.common.serialization import SimpleStringSchema
from pyflink.common.typeinfo import Types
from pyflink.datastream import StreamExecutionEnvironment
# from pyflink.datastream.connectors import FlinkKafkaConsumer
import firebase_admin
from firebase_admin import credentials, storage


# def read_from_kafka():
#     """
#     A simple Flink job that reads from a Kafka topic and prints the messages to the console.
#     """
#     env = StreamExecutionEnvironment.get_execution_environment()

#     # Define the Kafka consumer properties
#     kafka_props = {
#         # Use host.docker.internal to connect to Kafka running on the host machine
#         'bootstrap.servers': 'host.docker.internal:9092',
#         'group.id': 'my-flink-consumer-group'
#     }

#     # Define the Kafka topic to read from
#     kafka_topic = 'my-topic'  # Replace with your Kafka topic

#     # Create a Flink Kafka consumer
#     kafka_consumer = FlinkKafkaConsumer(
#         topics=kafka_topic,
#         deserialization_schema=SimpleStringSchema(),
#         properties=kafka_props
#     )

#     # Add the Kafka consumer as a data source
#     data_stream = env.add_source(kafka_consumer)

#     # Print the received messages to the console
#     data_stream.print()

#     # Execute the Flink job
#     env.execute("Kafka to Console")

def read_from_firebase_storage():
    """
    A simple Flink job that reads from Firebase Storage and prints the messages to the console.
    """
    # IMPORTANT: Replace "path/to/your/serviceAccountKey.json" with the actual path to your Firebase service account key file.
    # You can download this file from your Firebase project settings.
    # Make sure to add the `google-cloud-storage` and `firebase-admin` to your requirements.txt
    try:
        cred = credentials.Certificate("credentials.json")
        firebase_admin.initialize_app(cred, {
            'storageBucket': 'studio-2832030918-44b44.firebasestorage.app' # Replace with your Firebase Storage bucket name
        })
    except Exception as e:
        print("Failed to initialize Firebase Admin SDK. Please check your credentials.", e)
        return


    env = StreamExecutionEnvironment.get_execution_environment()

    # Get a reference to the storage bucket
    bucket = storage.bucket()

    # List all files in the bucket
    blobs = bucket.list_blobs()

    file_contents = []
    for blob in blobs:
        try:
            file_contents.append(blob.download_as_string().decode('utf-8'))
        except Exception as e:
            print(f"Failed to download and decode blob {blob.name}", e)


    # Create a Flink data stream from the file contents
    if file_contents:
        data_stream = env.from_collection(file_contents)
        # Print the received messages to the console
        data_stream.print()
        # Execute the Flink job
        env.execute("Firebase Storage to Console")
    else:
        print("No files found in the bucket.")


if __name__ == '__main__':
    # read_from_kafka()
    read_from_firebase_storage()