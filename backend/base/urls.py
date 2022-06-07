from django.urls import path
from base import views

urlpatterns = [
    path("", views.index, name="index"),
    path("register/", views.register, name="register"),
    path("login/", views.login, name="login"),
    path("discover/", views.discover, name="discover"),
    path("logout/", views.logout, name="logout"),
    path("profile/", views.profile, name="profile"),
    path("profile/<int:user_id>/", views.publicprofile, name="publicprofile"),
    path('leaderboard/', views.leaderboard, name='leaderboard'),
    path('chat/', views.message, name='chat'),
    path('message/', views.message, name='message'),
    path('createconversation/', views.createconversation, name='createconversation'),
    path('createmessage/<int:conversation_id>', views.createmessage, name='createmessage'),
    path('message/<int:conversation_id>/', views.conversation, name='conversation'),
    path('post/<int:post_id>/', views.post, name='post'),
    # Path for comments underneath posts
    path("comment/<int:post_id>/", views.comment, name="comment"),
    # Paths for voting on comments and posts, 1 = upvote, 0 = downvote
    path("vote_post/<int:post_id>/<str:up_or_down>/", views.vote_post, name="vote_post"),
    path("vote_comment/<int:comment_id>/<str:up_or_down>/", views.vote_comment, name="vote_comment"),
    path("report_post/<int:post_id>/", views.report_post, name="report_post"),
]
