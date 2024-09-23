#!/bin/bash

# Variables
tenant_id="ENTER_HERE_TENANT_ID"
client_id="ENTER_HERE_CLIENT_ID"
client_secret="ENTER_HERE_CLIENT_SECRET_VALUE"
login_endpoint="login.microsoftonline.com"
graph_api_endpoint="https://graph.microsoft.com"
recurrence="1M"
eps_throttle="5000"
log_source_type="Microsoft 365 Defender"
protocol_type="Microsoft Graph Security API"
alerts_endpoint="/alerts"
output_file="defender_logs.json"

# Function to fetch access token
fetch_access_token() {
    response=$(curl -X POST \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "client_id=$client_id" \
        -d "scope=https://graph.microsoft.com/.default" \
        -d "client_secret=$client_secret" \
        -d "grant_type=client_credentials" \
        "https://$login_endpoint/$tenant_id/oauth2/v2.0/token")

    echo $(echo $response | jq -r '.access_token')
}

# Function to fetch Defender logs
fetch_defender_logs() {
    access_token=$1
    response=$(curl -X GET \
        -H "Authorization: Bearer $access_token" \
        -H "Content-Type: application/json" \
        "$graph_api_endpoint/v1.0/security/$alerts_endpoint")

    echo $response
}

# Main script execution
access_token=$(fetch_access_token)
if [ -z "$access_token" ]; then
    echo "Failed to acquire access token"
    exit 1
fi

defender_logs=$(fetch_defender_logs $access_token)
if [ -z "$defender_logs" ]; then
    echo "Failed to fetch Defender logs"
    exit 1
fi

# Append logs to the output file
echo $defender_logs >> $output_file
echo "Defender logs have been appended to $output_file"