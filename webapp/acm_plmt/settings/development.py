from .common import *

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/2.0/howto/deployment/checklist/

ALLOWED_HOSTS = []

SECRET_KEY = 'k6x^i8u5!q2o*dtiz!n0sm@i-7r&4x=psnt)pc)lb8q2(uzw+h'

DEBUG = True

MIDDLEWARE =  [
    'django.middleware.security.SecurityMiddleware',
] + MIDDLEWARE

STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
