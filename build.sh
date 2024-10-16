#!/bin/sh
echo 'Deleting tesseract binary from current folder...'
rm ./tesseract

echo 'Building Docker image for x86_64 architecture...'
docker buildx build --platform linux/amd64 -t tesseract-static-builder .

echo 'Creating temporary container...'
docker create --name temp tesseract-static-builder

echo 'Copying Built Tesseract Binary...'
docker cp temp:/app/bin/tesseract ./tesseract

echo 'Removing temporary container...'
docker rm temp

echo 'Done building static Tesseract binary!'
echo 'The "tesseract" executable is now in the current folder.'
