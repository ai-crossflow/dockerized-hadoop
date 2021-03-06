FROM openjdk:11.0-jre-slim

ENV HADOOP_VERSION=3.3.1 \
    HADOOP_PREFIX=/opt/hadoop \
    HADOOP_HOME=/opt/hadoop \
    HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop \
    PATH=$PATH:/opt/hadoop/bin \
    MULTIHOMED_NETWORK=1 \
    CLUSTER_NAME=hadoop \
    HDFS_CONF_dfs_namenode_name_dir=file:///dfs/name \
    HDFS_CONF_dfs_datanode_data_dir=file:///dfs/data \
    USER=hdfs
  
RUN apt-get update && apt-get install -y curl procps && rm -rf /var/lib/apt/lists/* \
    && \
    if [ "$(uname -m)" = "aarch64" ]; then \
        curl -SL https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION-aarch64.tar.gz | tar xz -C /opt ; \
    else \
        curl -SL https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz | tar xz -C /opt ; \
    fi \
    && ln -s /opt/hadoop-$HADOOP_VERSION /opt/hadoop \
    && rm -r /opt/hadoop/share/doc \
    && \
    if [ ! -f $HADOOP_CONF_DIR/mapred-site.xml ]; then \
      cp $HADOOP_CONF_DIR/mapred-site.xml.template $HADOOP_CONF_DIR/mapred-site.xml; \
    fi \
    && groupadd -g 114 -r hadoop \
    && useradd --comment "Hadoop HDFS" -u 201 --shell /bin/bash -M -r --groups hadoop --home /var/lib/hadoop/hdfs hdfs \
    && mkdir -p /dfs \
    && mkdir -p /opt/hadoop/logs \
    && chown -R hdfs:hadoop /dfs \
    && chown -LR hdfs:hadoop /opt/hadoop
COPY entrypoint.sh /entrypoint.sh

USER hdfs
WORKDIR /opt/hadoop

VOLUME /dfs

EXPOSE 8020 

# HDFS 2.x web interface
EXPOSE 50070

# HDFS 3.x web interface
EXPOSE 9870

ENTRYPOINT ["/entrypoint.sh"]
