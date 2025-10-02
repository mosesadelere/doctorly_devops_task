# Note:
For simplicity, this project does not generate any artifacts

# Project requirements
The following must be available for the project to run locally
- Git
- python
- pip
- Docker

#project structure
doctorly_devops_task/
├── app.py              # Main Flask application
├── Dockerfile          # Docker configuration
├── .github/workflows   #
└── README3.md           # This file

#1
clone the project to your local machine
git clone https://github.com/mosesadelere/doctorly_devops_task.git
cd doctorly_devops_task

#2
Build docker image
docker build -t devops-project .

#3
if #2 is successfull, run the container
docker run -d -p 3000:3000 --name devops-app devops-project

#4
Access the application in your local browser of choice
https://localhost:3000

#5
stop and remove the container when done
docker stop devops-app
docker rm devops-app