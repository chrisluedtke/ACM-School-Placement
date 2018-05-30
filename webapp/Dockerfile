FROM rocker/r-base

RUN apt-get update && apt-get install -y \

    software-properties-common \

    python3-minimal \

    python3-pip \

    python3-distutils \

    && rm -rf /var/lib/apt/lists/*

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

RUN pip3 install -r requirements.txt

RUN pip3 install gunicorn

# RUN Rscript install_packages.R

CMD [ "python3", "manage.py", "runserver", "0.0.0.0:8000" ]