# Remove unused containers, networks, images, and build cache
docker system prune

# More aggressive cleanup (includes unused volumes)
docker system prune --volumes

# Remove all unused images not just dangling ones
docker image prune -a
