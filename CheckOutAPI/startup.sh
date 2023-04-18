#!/bin/sh

# Wait for Kong to start up
until curl -sSf http://kong:8001 > /dev/null; do
    echo "Waiting for Kong to start up..."
    sleep 1
done

# Get the container IP address from the eth0 adapter
ip_address=$(ip addr show eth0 | grep inet | awk '{ print $2 }' | cut -d '/' -f 1)

# Check if the Checkout service already exists in Kong
if ! curl -sSf http://kong:8001/services/checkout > /dev/null; then
    # Create a new service with the current instance as a route
    curl -i -X POST \
        --url http://kong:8001/services/ \
        --data "name=checkout" \
        --data "url=http://$ip_address:5002"

    # Add a route to the service
    curl -i -X POST \
        --url http://kong:8001/services/checkout/routes \
        --data "hosts[]=$ip_address" \
        --data 'paths[]=/checkout' \
        --data 'methods[]=GET' \
        --data 'methods[]=POST' \
        --data 'methods[]=DELETE'
        
    echo "Created new Checkout service."
fi

# Check if the upstream for checkout-api already exists
if ! curl -sSf http://kong:8001/upstreams/checkout-api-upstream > /dev/null; then
    curl -i -X POST http://kong:8001/upstreams \
        --data name=checkout-api-upstream

    # Update the Kong Service to use the created upstream
    curl -i -X PATCH http://kong:8001/services/checkout \
        --data host=checkout-api-upstream

    echo "Created checkout-api-upstream."
fi

# Check if the target already exists in the upstream
if ! curl -sSf http://kong:8001/upstreams/checkout-api-upstream/targets | grep -q "$ip_address"; then
    # Register the current instance as a target in the upstream
    curl -i -X POST http://kong:8001/upstreams/checkout-api-upstream/targets \
        --data target=$ip_address:5002

    echo "Added target to checkout-api-upstream."
fi

# Start the Flask app
exec gunicorn -b 0.0.0.0:5002 app:app
