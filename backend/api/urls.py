from django.urls import path
from rest_framework.authtoken.views import obtain_auth_token
from . import views

urlpatterns = [
    # User
    path(
        "user/<str:id>/",
        views.RetrieveUpdateDestroyUserAPIView.as_view(),
        name="get_delete_update_user",
    ),
    path("user/", views.ListCreateUserAPIView.as_view(), name="user"),
    # Post
    path(
        "post/<str:id>/",
        views.RetrieveUpdateDestroyPostAPIView.as_view(),
        name="get_delete_update_post",
    ),
    path("post/", views.ListCreatePostAPIView.as_view(), name="post"),
    # Comment
    path(
        "comment/<str:id>/",
        views.RetrieveUpdateDestroyCommentAPIView.as_view(),
        name="get_delete_update_comment",
    ),
    path("comment/", views.ListCreateCommentAPIView.as_view(), name="comment"),
    # Post Report
    path(
        "postreport/<str:id>",
        views.RetrieveUpdateDestroyPostReportAPIView.as_view(),
        name="get_delete_update_postreport",
    ),
    path("postreport/", views.ListCreatePostReportAPIView.as_view(), name="postreport"),
    # PostVote
    path(
        "postvote/<str:id>",
        views.RetrieveUpdateDestroyPostVoteAPIView.as_view(),
        name="get_delete_update_postvote",
    ),
    path("postvote/", views.ListCreatePostVoteAPIView.as_view(), name="postvote"),
    # CommentVote
    path(
        "commentvote/<str:id>",
        views.RetrieveUpdateDestroyCommentVoteAPIView.as_view(),
        name="get_delete_update_commentvote",
    ),
    path(
        "commentvote/", views.ListCreateCommentVoteAPIView.as_view(), name="commentvote"
    ),
    path("otp-start/", views.OTPStart.as_view(), name="otp-start"),
    path("otp-verify/", views.OTPVerify.as_view(), name="otp-verify"),
    path("verify-user/", views.VerifyUser.as_view(), name="verify-user"),
    # Create Model URLS
    path("create-conversation/", views.createConversation, name="createConversation"),
    path(
        "create-message/<int:conversation_id>",
        views.createMessage,
        name="createMessage",
    ),
    # Account URLS
    # path("login/", views.ObtainAuthToken.as_view(), name="login"),
]
