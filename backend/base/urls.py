from django.urls import path
from base import views

urlpatterns = [
    path("", views.index, name="index"),
    path("register/", views.register, name="register"),
    path("login/", views.login, name="login"),
    path("chat/", views.chat, name="chat"),
    path("logout/", views.logout, name="logout"),
    path("profile/", views.profile, name="profile"),
    # Path for comments underneath posts
    path("comment/<int:post_id>/", views.comment, name="comment"),
    # Paths for voting on comments and posts, 1 = upvote, 0 = downvote
    path("vote_post/<int:post_id>/<int:up_or_down>/", views.vote_post, name="vote_post"),
    path("vote_comment/<int:comment_id>/<int:up_or_down>/", views.vote_comment, name="vote_comment"),
]
