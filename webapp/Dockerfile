FROM rocker/r-base

## nginx stuff
# RUN apt-get update && apt-get install sudo
# RUN sudo apt-get install nginx -y

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

RUN pip3 install -r requirements_production.txt

# RUN Rscript install_packages.R

EXPOSE 8000

## development
# CMD [ "python3", "manage.py", "runserver", "0.0.0.0:8000" ]

RUN python3 manage.py collectstatic

CMD [ "gunicorn", "acm_plmt.wsgi", "--bind=0.0.0.0:8000" ]
