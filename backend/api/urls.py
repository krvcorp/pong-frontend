from django.urls import path
from . import views

urlpatterns = [
    # Get URLS
    path("getUser/<int:user_id>/", views.getUser, name="getUser"),
    path("getPost/<int:post_id>/", views.getPost, name="getPost"),
    path("getComment/<int:comment_id>/", views.getComment, name="getComment"),
    path("getPosts/", views.getPosts, name="getPosts"),
    path(
        "getCommentsOfPost/<int:post_id>/",
        views.getCommentsOfPost,
        name="getCommentsOfPost",
    ),
    path("getPostVotes/<int:post_id>/", views.getPostVotes, name="getPostVotes"),
    path(
        "getCommentVotes/<int:comment_id>/",
        views.getCommentVotes,
        name="getCommentVotes",
    ),
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
    # Update URLS
    path("updatePost/", views.updatePost, name="updatePost"),
    path("updateProfile/", views.updateProfile, name="updateProfile"),
    # Delete Model URLS
    path("deletepost/<int:post_id>/", views.deletePost, name="deletePost"),
    path("deletecomment/<int:comment_id>/", views.deleteComment, name="deleteComment"),
]
