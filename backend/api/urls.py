from django.urls import path
from rest_framework.authtoken.views import obtain_auth_token
from . import views

urlpatterns = [
    # User
    path(
        "user/<int:pk>/",
        views.RetrieveUpdateDestroyUserAPIView.as_view(),
        name="get_delete_update_user",
    ),
    path("user/", views.ListCreateUserAPIView.as_view(), name="user"),
    # Post
    path(
        "post/<int:pk>/",
        views.RetrieveUpdateDestroyPostAPIView.as_view(),
        name="get_delete_update_post",
    ),
    path("post/", views.ListCreatePostAPIView.as_view(), name="post"),
    # Comment
    path(
        "comment/<int:pk>/",
        views.RetrieveUpdateDestroyCommentAPIView.as_view(),
        name="get_delete_update_comment",
    ),
    path("comment/", views.ListCreateCommentAPIView.as_view(), name="comment"),
    # Post Report
    path(
        "postreport/<int:pk>",
        views.RetrieveUpdateDestroyPostReportAPIView.as_view(),
        name="get_delete_update_postreport",
    ),
    path("postreport/", views.ListCreatePostReportAPIView.as_view(), name="postreport"),
    # PostVote
    path(
        "postvote/<int:pk>",
        views.RetrieveUpdateDestroyPostVoteAPIView.as_view(),
        name="get_delete_update_postvote",
    ),
    path("postvote/", views.ListCreatePostVoteAPIView.as_view(), name="postvote"),
    # CommentVote
    path(
        "commentvote/<int:pk>",
        views.RetrieveUpdateDestroyCommentVoteAPIView.as_view(),
        name="get_delete_update_commentvote",
    ),
    path(
        "commentvote/", views.ListCreateCommentVoteAPIView.as_view(), name="commentvote"
    ),
    path("phonelogin/", views.PhoneLoginAPIView.as_view(), name="phonelogin"),
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
]
