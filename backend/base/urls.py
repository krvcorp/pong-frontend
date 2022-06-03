from django.urls import path
from base import views

urlpatterns = [
    path("", views.index, name="index"),
    path("register/", views.register, name="register"),
    path("login/", views.login, name="login"),
    path("chat/", views.chat, name="chat"),
    path("logout/", views.logout, name="logout"),
    path("profile/", views.profile, name="profile"),
    path("discover/", views.discover, name="discover"),
]
