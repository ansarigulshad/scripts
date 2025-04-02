#!/bin/bash

# -- HADOOP ENVIRONMENT VARIABLES -- #
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME=/usr/local/hdroot/hadoop
export HBASE_HOME=/usr/local/hdroot/hbase

export PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HBASE_HOME/bin

export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"
export HADOOP_CLASSPATH="$(${HBASE_HOME}/bin/hbase classpath):$(${HBASE_HOME}/bin/hbase mapredcp)"

# Function to check and start services
check_and_start() {
    local component="$1"
    local expected_count="$2"
    local process_pattern="$3"
    local start_command="$4"
    local max_retries=5
    local delay=5
    local attempt=0

    echo "Checking whether $component processes are running..."

    while true; do
        local running_count
        running_count=$(sudo jps | grep -E "$process_pattern" | grep -v Jps | wc -l)

        if [[ $running_count -eq $expected_count ]]; then
            echo "$component processes are running: $(jps | grep -E "$process_pattern" | grep -v Jps | awk '{print $2}' | tr '\n' ', ')"
            break
        fi

        if [[ $attempt -ge $max_retries ]]; then
            echo "❌ $component services failed to start after $max_retries attempts."
            break
        fi

        echo "Starting $component services... Attempt $((attempt+1))"
        eval "$start_command"
        sleep $delay
        ((attempt++))
    done
}

check_and_start "HDFS" 3 "NameNode|DataNode|SecondaryNameNode" "start-dfs.sh"
check_and_start "YARN" 2 "ResourceManager|NodeManager" "start-yarn.sh"
check_and_start "HBase" 4 "HMaster|HRegionServer|HQuorumPeer|RESTServer" "start-hbase.sh && nohup hbase rest start -p 8081 </dev/null >/dev/null 2>&1 &"

