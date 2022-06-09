from django.urls import path
from . import views

urlpatterns = [
    # Get URLS
    path("user/<int:user_id>/", views.user, name="user"),
    path("post/<int:post_id>/", views.post, name="post"),
    path("comment/<int:comment_id>/", views.comment, name="comment"),
    path("getPosts/", views.getPosts, name="getPosts"),
    # Create URLS
    path("createPost/", views.createPost, name="createPost"),
    path("createComment/<int:post_id>", views.createComment, name="createComment"),
    path(
        "createPostReport/<int:post_id>",
        views.createPostReport,
        name="createPostReport",
    ),
    # Create-Vote URLS
    path(
        "createPostVote/<int:post_id>/<str:up_or_down>/",
        views.createPostVote,
        name="createPostVote",
    ),
    path(
        "createCommentVote/<int:comment_id>/<str:up_or_down>/",
        views.createCommentVote,
        name="createCommentVote",
    ),
    path("createClassGroup/", views.createClassGroup, name="createClassGroup"),
    # Create Model URLS
    path("createConversation/", views.createConversation, name="createConversation"),
    path(
        "createMessage/<int:conversation_id>", views.createMessage, name="createMessage"
    ),
]
