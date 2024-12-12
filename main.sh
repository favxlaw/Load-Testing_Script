#!/bin/bash

# Validating Input

validate_inputs() {
    local url=$1
    local concurrent=$2
    local duration=$3

    if [[ ! $url =~ ^https?:// ]]; then
        echo "Error: Invalid URL format. Must start with http:// or https://"
        exit 1
    fi

    if ! [[ "$concurrent" =~ ^[0-9]+$ ]] || [ "$concurrent" -lt 1 ]; then
        echo "Error: Concurrent requests must be a positive number"
        exit 1
    fi

    if ! [[ "$duration" =~ ^[0-9]+$ ]] || [ "$duration" -lt 1 ]; then
        echo "Error: Duration must be a positive number"
        exit 1
    fi
}


#Logging Setup

setup_logging() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local results_dir="load_test_results"
    mkdir -p "$results_dir"
    echo "${results_dir}/load_test_${timestamp}.json"
}

#Load test fun

run_load_test() {
    local url=$1
    local concurrent=$2
    local duration=$3
    local log_file=$4

    echo "Starting load test for $url"
    echo "Concurrent requests: $concurrent"
    echo "Duration: $duration seconds"
    
# Run Apache Benchmark and capture output
    ab -n $((concurrent * duration)) -c "$concurrent" -t "$duration" \
       -e "${log_file%.json}_distribution.csv" \
       "$url" > "${log_file%.json}_raw.txt"

    local total_requests=$(grep "Complete requests:" "${log_file%.json}_raw.txt" | awk '{print $3}')
    local failed_requests=$(grep "Failed requests:" "${log_file%.json}_raw.txt" | awk '{print $3}')
    local mean_time=$(grep "Mean:" "${log_file%.json}_raw.txt" | awk '{print $4}')
    local max_time=$(grep "Max:" "${log_file%.json}_raw.txt" | awk '{print $4}')

    cat > "$log_file" << EOF
{
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "url": "$url",
    "configuration": {
        "concurrent_requests": $concurrent,
        "duration": $duration
    },
    "results": {
        "total_requests": $total_requests,
        "failed_requests": $failed_requests,
        "success_rate": $(echo "scale=2; ($total_requests-$failed_requests)/$total_requests*100" | bc),
        "mean_response_time": $mean_time,
        "max_response_time": $max_time
    }
}
EOF
}


main() {
    if [ $# -ne 3 ]; then
        echo "Usage: $0 <url> <concurrent_requests> <duration_seconds>"
        exit 1
    fi

    local url=$1
    local concurrent=$2
    local duration=$3

    validate_inputs "$url" "$concurrent" "$duration"
    local log_file=$(setup_logging)
    run_load_test "$url" "$concurrent" "$duration" "$log_file"

    echo "Load test completed. Results saved to: $log_file"
}

main "$@"
