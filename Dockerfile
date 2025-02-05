# Stage 1: Build the app
FROM ubuntu:20.04 AS build-env

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-8-jdk \
    wget

# Create a non-root user
RUN useradd -ms /bin/bash developer
RUN mkdir -p /home/developer/flutter_app
RUN chown -R developer:developer /home/developer

# Configure git for better network handling
RUN git config --global http.postBuffer 524288000 \
    && git config --global http.lowSpeedLimit 1000 \
    && git config --global http.lowSpeedTime 300 \
    && git config --global --add safe.directory '*'

# Download Flutter using tar
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.3-stable.tar.xz \
    && tar xf flutter_linux_3.19.3-stable.tar.xz -C /usr/local/ \
    && rm flutter_linux_3.19.3-stable.tar.xz \
    && chown -R developer:developer /usr/local/flutter

# Switch to non-root user
USER developer

# Add flutter to path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Set working directory
WORKDIR /home/developer/flutter_app

# Verify flutter installation and update
RUN flutter doctor -v
RUN flutter channel stable
RUN flutter upgrade

# Copy the app files
COPY --chown=developer:developer . .

# Get app dependencies
RUN flutter pub get

# Build the app for the web
RUN flutter build web

# Stage 2: Create the run-time image
FROM nginx:1.21-alpine

# Copy the build output to the nginx directory
COPY --from=build-env /home/developer/flutter_app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]