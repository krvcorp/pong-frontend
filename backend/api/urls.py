from django.urls import path
from rest_framework.authtoken.views import obtain_auth_token
from . import views

urlpatterns = [
    # Get URLS
    path(
        "user/<int:pk>/",
        views.RetrieveUpdateDestroyUserAPIView.as_view(),
        name="get_delete_update_user",
    ),
    path("user/", views.create_user, name="create_user"),
    path(
        "post/<int:pk>/",
        views.RetrieveUpdateDestroyPostAPIView.as_view(),
        name="get_delete_update_post",
    ),
    path(
        "comment/<int:pk>/",
        views.RetrieveUpdateDestroyCommentAPIView.as_view(),
        name="get_delete_update_comment",
    ),
    path("post/", views.ListCreatePostAPIView.as_view(), name="getPosts"),
    # Create URLS
    path("create-comment/<int:post_id>", views.create_comment, name="createComment"),
    path(
        "create-post-report/<int:post_id>",
        views.createPostReport,
        name="createPostReport",
    ),
    # Create-Vote URLS
    path(
        "create-post-vote/<int:post_id>/<str:up_or_down>/",
        views.createPostVote,
        name="createPostVote",
    ),
    path(
        "create-comment-vote/<int:comment_id>/<str:up_or_down>/",
        views.createCommentVote,
        name="createCommentVote",
    ),
    path("create-class-group/", views.createClassGroup, name="createClassGroup"),
    # Create Model URLS
    path("create-conversation/", views.createConversation, name="createConversation"),
    path(
        "create-message/<int:conversation_id>",
        views.createMessage,
        name="createMessage",
    ),
    # Account URLS
    path("register/", views.register, name="register"),
    path("login/", views.ObtainAuthToken.as_view(), name="login"),
    path(
        "upload-profile-picture/",
        views.upload_profile_picture,
        name="upload-profile-picture",
    ),
]
