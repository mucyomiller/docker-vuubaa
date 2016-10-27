FROM python:3

MAINTAINER Mucyo Miller

########################################################################################################
#                                                                                                      #
#        This is temporary image to tackle issue of Django 1.10 MIDDLEWARE_CLASSES                     #
#       we will use official images when Django Auth toolkit updates for Django 1.10 changes         #
#                                                                                                      #
########################################################################################################

EXPOSE 8000

ENV GUNICORN_VERSION=19.6.0
ENV PYTZ_VERSION=2016.6.1

# this will start /usr/django/app/{vuubaa}/wsgi.py
ENV DJANGO_APP=vuubaa

ENV GUNICORN_RELOAD=true
ENV DJANGO_MIGRATE=true
ENV DJANGO_COLLECTSTATIC=true




# create directory which can be a place for generated static content
# volume can be used to serve these files with a webserver
RUN mkdir -p /var/www/static
VOLUME /var/www/static

# copying & installing django authentication toolkit
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/bastbnl/django-oauth-toolkit.git
RUN cd django-oauth-toolkit/ && python setup.py install
# create directory for application source code
# volume can be used for live-reload during development
RUN mkdir -p /usr/django/app
VOLUME /usr/django/app

# add gunicorn config
RUN mkdir -p /etc/gunicorn
COPY gunicorn.conf /etc/gunicorn/

# install gunicorn, django and pytz
RUN pip install gunicorn==$GUNICORN_VERSION
RUN pip install pytz==$PYTZ_VERSION

#add requirements.txt
ADD requirements.txt /usr/django/app/

# install application dependencies
RUN pip install -r /usr/django/app/requirements.txt

# run start.sh on container start
COPY start.sh /usr/django/
WORKDIR /usr/django
CMD bash start.sh
