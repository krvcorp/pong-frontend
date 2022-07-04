from django.urls import path
from base import views
from rest_framework.authtoken.views import obtain_auth_token

urlpatterns = [
    # General URLS
    path("", views.index, name="index"),
    path("leaderboard/", views.leaderboard, name="leaderboard"),
    path("chat/", views.message, name="chat"),
    path("message/", views.message, name="message"),
    # Account/User URLS
    path("register/", views.register, name="register"),
    path("login/", views.login, name="login"),
    path("logout/", views.logout, name="logout"),
    path("profile/", views.profile, name="profile"),
    path("profile/<int:user_id>/", views.publicprofile, name="publicprofile"),
    # Indvidual Model URLS
    path("message/<int:conversation_id>/", views.conversation, name="conversation"),
    # path("post/<int:post_id>/", views.singular_post, name="singular_post"),
    # Report URLS
    path("reportedposts/", views.reportedposts, name="reportedposts"),
]
