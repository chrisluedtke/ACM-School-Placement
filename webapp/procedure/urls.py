from django.urls import path
from . import views

urlpatterns = [
    path('', views.welcome, name='welcome'),
    path('step1/', views.step1, name='step1'),
    path('step2/', views.step2, name='step2'),
    path('step3/', views.step3, name='step3'),
    path('wait/', views.wait, name='wait'),
    path('dash/', views.dash, name='dash'),
    # path('dashboard/', views.dashboard, name='dashboard'),
]
