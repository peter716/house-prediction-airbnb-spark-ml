FROM python:3.9.1

# Set the working directory in the container
WORKDIR /usr/src/app

# Install Java (required for Spark)
RUN apt-get update && \
    apt-get install -y openjdk-11-jre-headless && \
    apt-get clean;

# Set JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

# Download and install Spark
ENV SPARK_VERSION=3.5.1
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/spark

RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL --retry 3 "https://downloads.apache.org/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz" \
    | gunzip \
    | tar x -C / && \
    mv /spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION $SPARK_HOME && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add Spark to path so the `spark-submit` and other scripts are found
ENV PATH $PATH:$SPARK_HOME/bin

# Install Python libraries
RUN pip install pyspark xgboost pandas sklearn

# Copy the current directory contents into the container at /app
COPY . /usr/src/app

RUN mkdir -p /usr/src/app/data && \
    unzip -o /usr/src/app/data/sf-airbnb-clean-100p.parquet.zip -d /usr/src/app/data/

# Run Python script on container startup
ENTRYPOINT ["python", "spark_machine_learning.py"]
