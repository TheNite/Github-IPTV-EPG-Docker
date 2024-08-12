# Use an official Node.js image as the base
FROM node:18

# Add labels for metadata
LABEL maintainer="Helper"
LABEL version="1.0"
LABEL description="This is a Dockerfile for the IPTV EPG Grabber"

# Install Git and cron
RUN apt-get update && \
    apt-get install -y git cron \

# Set the working directory
WORKDIR /app

# Clone the repository
RUN git clone --depth 1 -b master https://github.com/iptv-org/epg.git

# Change to the repository directory
WORKDIR /app/epg

# Install npm dependencies
RUN npm install

# Copy the script into the container
COPY run_grab.sh /app/epg/run_grab.sh

# Make the script executable
RUN chmod +x /app/epg/run_grab.sh

# Run the grab command during the build process
RUN /app/epg/run_grab.sh

# Add the cron job (runs at midnight and silences the output)
RUN echo "0 0 * * * cd /app/epg && npm run grab -- --site=tvpassport.com --maxConnections=5  \
    > /dev/null 2>&1"  \
    > /etc/cron.d/grab-cron

# Apply correct permissions for the cron job file
RUN chmod 0644 /etc/cron.d/grab-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Expose the port that the application will run on
EXPOSE 3000

# Start cron and then the application
CMD cron && npm run serve
