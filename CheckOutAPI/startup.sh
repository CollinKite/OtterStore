#!/bin/sh

# Wait for Kong to start up
until curl -sSf http://kong:8001 > /dev/null; do
    echo "Waiting for Kong to start up..."
    sleep 1
done

# Get the container IP address from the eth0 adapter
ip_address=$(ip addr show eth0 | grep inet | awk '{ print $2 }' | cut -d '/' -f 1)

# Check if the Checkout service already exists in Kong
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://kong:8001/services/checkout)
echo "Response: $RESPONSE"
if [ $RESPONSE -eq 404 ]; then
    echo "Checkout Service does not exist. Creating service and upstream..."

        # Create a new service with the current instance as a route
    curl -i -X POST \
        --url http://kong:8001/services/ \
        --data "name=checkout-service" \
        --data "url=http://$ip_address:5002"
    echo "Created new Checkout service."

    # Add a route to the service
    curl -i -X POST \
        --url http://kong:8001/services/checkout-service/routes \
        --data 'paths[]=/checkout' \
        --data name=checkout-route \
        --data 'methods[]=GET' \
        --data 'methods[]=POST' \
        --data 'methods[]=DELETE'
    echo "Created Checkout route."

  # Create an upstream for the service
    curl -i -X POST \
        --url http://kong:8001/upstreams/ \
        --data "name=checkout-upstream"
    echo "Created new Checkout upstream."

    # Update the Kong Service to use the created upstream
    curl -i -X PATCH http://kong:8001/services/checkout-service \
        --data host=checkout-upstream
    echo "Updated Checkout service to use the upstream."
else
    echo "Checkout Service/Upstream already exists. Skipping Creating ..."
fi
    # Add the instance to the upstream
    curl -i -X POST \
        --url http://kong:8001/upstreams/checkout-upstream/targets \
        --data "target=$ip_address:5002"
    echo "Added this instance to upstream."


# Start the Flask app
exec python app.py
# exec gunicorn -b 0.0.0.0:5002 app:app
