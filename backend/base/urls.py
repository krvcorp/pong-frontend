from django.urls import path
from base import views
from rest_framework.authtoken.views import obtain_auth_token

urlpatterns = [
    # General URLS
    path("", views.index, name="index"),
]
