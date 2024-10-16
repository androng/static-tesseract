# Dockerfile to build tesseract with static linking so that it can run on Firebase functions. 
# Works on Firebase Functions (Google Cloud Functions)
# Use a base image that matches Firebase Functions environment more closely
FROM debian:buster-slim

# Install build dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    curl \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libicu-dev \
    libpango1.0-dev \
    libcairo2-dev \
    libleptonica-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libtiff5-dev \
    zlib1g-dev

# Download and build Leptonica statically
RUN wget http://www.leptonica.org/source/leptonica-1.80.0.tar.gz && \
    tar -xzvf leptonica-1.80.0.tar.gz && \
    cd leptonica-1.80.0 && \
    ./configure --enable-static --disable-shared && \
    make && \
    make install

# Download Tesseract source
ADD https://github.com/tesseract-ocr/tesseract/archive/4.1.0.tar.gz /
RUN tar -xf 4.1.0.tar.gz

# Build Tesseract with static linking
WORKDIR /tesseract-4.1.0
RUN ./autogen.sh && \
    LIBLEPT_HEADERSDIR=/usr/local/include ./configure \
    --enable-static \
    --disable-shared \
    --with-extra-libraries=/usr/local/lib && \
    LDFLAGS="-static" make && \
    make install

# Copy the built binary and necessary data
RUN mkdir -p /app/bin /app/share && \
    cp /usr/local/bin/tesseract /app/bin/tesseract && \
    cp -r /usr/local/share/tessdata /app/share/

# Use a minimal base image for the final stage
FROM scratch
COPY --from=0 /app /app

# Set up environment variables
ENV TESSDATA_PREFIX=/app/share/tessdata

# This ensures the container never stops
CMD ["sleep", "infinity"]
