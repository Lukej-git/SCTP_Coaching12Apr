# Using latest base image  from DockerHub
FROM python:latest

#Creating working directory inside container#
WORKDIR /app

#Copy source code into working directory inside container
COPY . /app

#Install flask (dependency) inside container
# "--no-cache-dir" used to prevent pip from storing downloaded packages in cache during install
RUN pip install -r requirements.txt

#Expose container port
EXPOSE 5050

# Define environment variable
ENV FLASK_APP=app.py

# Run the Flask app
CMD ["flask", "run", "--host=0.0.0.0"]
