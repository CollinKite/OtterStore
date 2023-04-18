#!/bin/sh

# Wait for Kong to start up
until curl -sSf http://kong:8001 > /dev/null; do
    echo "Waiting for Kong to start up..."
    sleep 1
done

# Get the container IP address
ip_address=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(hostname))

# Check if the App service already exists in Kong
if curl -sSf http://kong:8001/services/app > /dev/null; then
    # Add the current instance as a route to the existing service
    curl -i -X POST \
        --url http://kong:8001/services/app/routes \
        --data "hosts[]=$ip_address"
    echo "Added route to existing App service."
else
    # Create a new service with the current instance as a route
    curl -i -X POST \
        --url http://kong:8001/services/ \
        --data "name=app" \
        --data "url=http://$ip_address:5001"

    # Add a route to the service
    curl -i -X POST \
        --url http://kong:8001/services/app/routes \
        --data "hosts[]=$ip_address" \
        --data 'paths=/services/app'

    echo "Created new App service."
fi

# Start the Flask app
exec gunicorn -b 0.0.0.0:5001 app:app
