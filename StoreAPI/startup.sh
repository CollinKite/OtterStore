#!/bin/sh

# Wait for Kong to start up
until curl -sSf http://kong:8001 > /dev/null; do
    echo "Waiting for Kong to start up..."
    sleep 1
done

# Get the container IP address from the eth0 adapter
ip_address=$(ip addr show eth0 | grep inet | awk '{ print $2 }' | cut -d '/' -f 1)

# Check if the store service already exists in Kong
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://kong:8001/services/store)
echo "Response: $RESPONSE"
if [ $RESPONSE -eq 404 ]; then
    echo "store Service does not exist. Creating service and upstream..."

        # Create a new service with the current instance as a route
    curl -i -X POST \
        --url http://kong:8001/services/ \
        --data "name=store-service" \
        --data "url=http://$ip_address:5001"
    echo "Created new store service."

    # Add a route to the service
    curl -i -X POST \
        --url http://kong:8001/services/store-service/routes \
        --data 'paths[]=/store' \
        --data name=store-route \
        --data 'methods[]=GET' \
        --data 'methods[]=POST' \
        --data 'methods[]=DELETE'
    echo "Created store route."

  # Create an upstream for the service
    curl -i -X POST \
        --url http://kong:8001/upstreams/ \
        --data "name=store-upstream"
    echo "Created new store upstream."

    # Update the Kong Service to use the created upstream
    curl -i -X PATCH http://kong:8001/services/store-service \
        --data host=store-upstream
    echo "Updated store service to use the upstream."
else
    echo "store Service/Upstream already exists. Skipping Creating ..."
fi
    # Add the instance to the upstream
    curl -i -X POST \
        --url http://kong:8001/upstreams/store-upstream/targets \
        --data "target=$ip_address:5001"
    echo "Added this instance to upstream."


# Start the Flask store
exec python app.py
# exec gunicorn -b 0.0.0.0:1 store:store
