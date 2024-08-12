# Use a base image that suits your application's needs
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy application code
COPY src/ .

# Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Expose the port your app runs on
EXPOSE 5000

# Define the command to run the application
CMD ["python", "main.py"]
