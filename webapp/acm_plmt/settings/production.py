from .common import *

# CHANGE THESE
# change SECRET_KEY to environment variable or load from file
SECRET_KEY = 'k6x^i8u5!q2o*dtiz!n0sm@i-7r&4x=psnt)pc)lb8q2(uzw+h'
DEBUG = False
ALLOWED_HOSTS = ['127.0.0.1', 'acmplacement.azurewebsites.net']

# Added when configurig whitenoise
MIDDLEWARE =  [
    # 'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware'
] + MIDDLEWARE

STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATIC_URL = '/static/'

# Extra places for collectstatic to find static files.
STATICFILES_DIRS = (
    os.path.join(BASE_DIR, 'procedure/static'),
)

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
