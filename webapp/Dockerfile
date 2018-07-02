FROM rocker/r-base

## nginx stuff
#RUN apt-get update && apt-get install sudo
#RUN sudo apt-get install nginx -y

RUN apt-get update && apt-get install -y \
    software-properties-common \
    python3-minimal \
    python3-pip \
    python3-distutils \
    && rm -rf /var/lib/apt/lists/*

#RUN sudo apt-get install xz-utils

RUN Rscript -e "install.packages(c('readxl', 'dplyr', 'tidyr', 'data.table'), lib='/usr/local/lib/R/site-library')"

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Attempts to get Rcurl and XML packages to work
#RUN R -e "install.packages('devtools')"
#RUN R -e "install.packages('packages/r-cran-rcurl_1.95-4.10-2.debian.zip', repo=NULL, type='source', lib='/usr/local/lib/R/site-library')"
#RUN R -e "load_all('packages/r-cran-rcurl_1.95-4.10-2.debian/debian')"
#RUN Rscript test.R

RUN pip3 install -r requirements_production.txt

EXPOSE 8000

## development
# CMD [ "python3", "manage.py", "runserver", "0.0.0.0:8000" ]

RUN python3 manage.py collectstatic

CMD [ "gunicorn", "acm_plmt.wsgi", "--bind=0.0.0.0:8000" ]
