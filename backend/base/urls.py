from django.urls import path
from base import views

urlpatterns = [
    # General URLS
    path("", views.index, name="index"),
    path("discover/", views.discover, name="discover"),
    path('leaderboard/', views.leaderboard, name='leaderboard'),
    path('chat/', views.message, name='chat'),
    path('message/', views.message, name='message'),

    # Account/User URLS
    path("register/", views.register, name="register"),
    path("login/", views.login, name="login"),
    path("logout/", views.logout, name="logout"),
    path("profile/", views.profile, name="profile"),
    path("profile/<int:user_id>/", views.publicprofile, name="publicprofile"),

    # Create Model URLS
    path('createconversation/', views.createconversation, name='createconversation'),
    path('createmessage/<int:conversation_id>', views.createmessage, name='createmessage'),
    path('createpost/', views.createpost, name='createpost'),
    path('createclassgroup/', views.create_class_group, name='create_class_group'),

    # Delete Model URLS
    path('deletepost/<int:post_id>/', views.delete_post, name='delete_post'),
    path('deletecomment/<int:comment_id>/', views.delete_comment, name='delete_comment'),

    # Indvidual Model URLS
    path('message/<int:conversation_id>/', views.conversation, name='conversation'),
    path('post/<int:post_id>/', views.post, name='post'),
    path("comment/<int:post_id>/", views.comment, name="comment"),

    # Voting URLS
    path("vote_post/<int:post_id>/<str:up_or_down>/", views.vote_post, name="vote_post"),
    path("vote_comment/<int:comment_id>/<str:up_or_down>/", views.vote_comment, name="vote_comment"),

    # Report URLS
    path("report_post/<int:post_id>/", views.report_post, name="report_post"),
    path("reportedposts/", views.reportedposts, name="reportedposts"),
]
