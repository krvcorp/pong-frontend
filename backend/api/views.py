import datetime
import operator
from django.http import JsonResponse
from .models import (
    CommentReport,
    Poll,
    PostSave,
    User,
    Post,
    Comment,
    PostReport,
    CommentVote,
    PostVote,
    School,
    Token,
    BlockedUser,
)
from .serializers import (
    PostCommentsSerializer,
    UserSerializer,
    UserSerializerLeaderboard,
    PostSerializer,
    CommentSerializer,
    PostReportSerializer,
    CommentVoteSerializer,
    PostVoteSerializer,
    UserSerializerProfile,
    PostSaveSerializer,
    PostCommentsSerializer,
)
from .permissions import (
    IsOwner,
    IsOwnerOrReadOnly,
    IsNotInTimeout,
    IsAuthenticatedAndOwnerOrAdmin,
)
from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.generics import (
    RetrieveUpdateDestroyAPIView,
    ListCreateAPIView,
    ListAPIView,
    CreateAPIView,
    DestroyAPIView,
    RetrieveAPIView,
)
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from twilio.rest import Client

"""
User API Views
Admins can list all users.
User can retrieve their own profile. They don't need to update or delete their profile. 
Deletion of profile is handled in a different view (DeleteAccountAPIView).
"""


class ListUserAPIView(ListAPIView):
    serializer_class = UserSerializer
    permission_classes = (IsAdminUser,)
    queryset = User.objects.all()


class RetrieveUserAPIView(RetrieveAPIView):
    lookup_field = "id"
    permission_classes = (IsAuthenticatedAndOwnerOrAdmin,)

    def get_serializer_class(self):
        sort = self.request.query_params.get("sort", None)
        if sort == "profile":
            return UserSerializerProfile
        # In the app, only the above serializer is ever returned. The below is left in for Postman testing.
        if self.request.user.is_admin:
            return UserSerializer
        return UserSerializerProfile

    def get_queryset(self):
        return User.objects.filter(id=self.kwargs["id"])


"""
Post API Views
"""


class RetrieveUpdateDestroyPostAPIView(RetrieveUpdateDestroyAPIView):
    lookup_field = "id"
    serializer_class = PostSerializer
    queryset = Post.objects.all()
    permission_classes = (IsAuthenticated & IsOwnerOrReadOnly | IsAdminUser,)


class ListCreatePostAPIView(ListCreateAPIView):
    serializer_class = PostSerializer
    permission_classes = (IsAuthenticated & IsNotInTimeout | IsAdminUser,)

    class Meta:
        model = Post
        fields = "__all__"
        read_only_fields = ["time_since_posted"]

    def perform_create(self, serializer):
        posts = Post.objects.filter(user=self.request.user)
        if posts.count() > 0:
            most_recent_post = posts[0]
            time_elapsed = (
                datetime.datetime.now(datetime.timezone.utc)
                - most_recent_post.created_at
            )
            if time_elapsed.total_seconds() < 30:
                return JsonResponse(
                    {"error": "post_too_soon"}, status=status.HTTP_400_BAD_REQUEST
                )

        if "poll" in self.request.data:
            poll_data = self.request.data["poll"]
            Poll.objects.create(user=self.request.user, title=self)

        serializer.save(user=self.request.user)

    def get_queryset(self):
        queryset = Post.objects.all()
        sort = self.request.query_params.get("sort", None)
        if sort == "new":
            queryset = queryset.order_by("-created_at")
        elif sort == "top":
            range = self.request.query_params.get("range", None)
            if range == "day":
                queryset = queryset.filter(
                    created_at__gt=datetime.datetime.now() - datetime.timedelta(days=1)
                )
            elif range == "week":
                queryset = queryset.filter(
                    created_at__gt=datetime.now() - datetime.timedelta(days=7)
                )
            elif range == "month":
                queryset = queryset.filter(
                    created_at__gt=datetime.now() - datetime.timedelta(days=30)
                )
            elif range == "all":
                queryset = queryset
            queryset = list(queryset)
            queryset.sort(key=operator.attrgetter("score"), reverse=True)
        elif sort == "old":
            queryset = queryset.order_by("created_at")
        return queryset


"""
Comment API Views
"""


class ListCreateCommentAPIView(ListCreateAPIView):
    serializer_class = CommentSerializer
    queryset = Comment.objects.all()
    permission_classes = (IsAuthenticated & IsNotInTimeout | IsAdminUser,)

    def post(self, request, *args, **kwargs):
        """
        Creates a comment based off of the post_id sent in the request body.
        """
        post = Post.objects.get(id=request.data.get("post_id"))
        parent = (
            Comment.objects.get(id=request.data.get("parent_id"))
            if request.data.get("parent_id")
            else None
        )
        n_o_p = None
        if Comment.objects.filter(user=request.user, post=post).exists():
            n_o_p = (
                Comment.objects.filter(user=request.user, post=post)
                .order_by("-number_on_post")[0]
                .number_on_post
            )
        else:
            n_o_p = (
                Comment.objects.filter(post=post)
                .order_by("-number_on_post")
                .first()
                .number_on_post
                + 1
                if Comment.objects.filter(post=post).exists()
                else 0
            )
        comment = Comment.objects.create(
            user=request.user,
            post=post,
            comment=request.data.get("comment"),
            parent=parent,
            number_on_post=n_o_p,
        )
        CommentVote.objects.create(user=self.request.user, comment=comment, vote=1)
        return Response(
            PostCommentsSerializer(comment).data, status=status.HTTP_201_CREATED
        )

    def get(self, request, *args, **kwargs):
        """
        Returns a list of comments based off of the post_id sent in the request body.
        """
        post = Post.objects.get(id=request.query_params.get("post_id"))
        queryset = Comment.objects.filter(post=post, parent=None)
        return Response(PostCommentsSerializer(queryset, many=True).data)


class RetrieveUpdateDestroyCommentAPIView(RetrieveUpdateDestroyAPIView):
    lookup_field = "id"
    serializer_class = CommentSerializer
    queryset = Comment.objects.all()
    permission_classes = (IsAuthenticated & IsOwnerOrReadOnly | IsAdminUser,)


"""
Vote API Views
"""


class RetrieveUpdateDestroyPostVoteAPIView(RetrieveUpdateDestroyAPIView):
    lookup_field = "id"
    serializer_class = PostVoteSerializer
    queryset = PostVote.objects.all()
    permission_classes = (IsAuthenticated & IsOwnerOrReadOnly | IsAdminUser,)


class RetrieveUpdateDestroyCommentVoteAPIView(RetrieveUpdateDestroyAPIView):
    lookup_field = "id"
    serializer_class = CommentVoteSerializer
    queryset = CommentVote.objects.all()
    permission_classes = (IsAuthenticated & IsOwnerOrReadOnly | IsAdminUser,)


class ListCreatePostVoteAPIView(ListCreateAPIView):
    serializer_class = PostVoteSerializer
    queryset = PostVote.objects.all()
    permission_classes = (IsAuthenticated | IsAdminUser,)


class ListCreateCommentVoteAPIView(ListCreateAPIView):
    serializer_class = CommentVoteSerializer
    queryset = CommentVote.objects.all()
    permission_classes = (IsAuthenticated | IsAdminUser,)


"""
PostSave API Views
"""


class PostSaveAPIView(CreateAPIView, DestroyAPIView, ListAPIView):
    permission_classes = IsAuthenticatedAndOwnerOrAdmin
    serializer_class = PostSaveSerializer
    queryset = PostSave.objects.all()

    def create(self, request, *args, **kwargs):
        post = Post.objects.get(id=self.request.data.get("post_id"))
        if PostSave.objects.filter(user=self.request.user, post=post).exists():
            return Response(
                {"error": "post_already_saved"}, status=status.HTTP_400_BAD_REQUEST
            )
        return super().create(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        post = Post.objects.get(id=request.data.get("post_id"))
        if not PostSave.objects.filter(user=request.user, post=post).exists():
            return Response(
                {"error": "post_not_saved"}, status=status.HTTP_400_BAD_REQUEST
            )
        PostSave.objects.filter(user=request.user, post=post).delete()
        return Response(status=status.HTTP_200_OK)


"""
Report API Views
"""


class PostReportAPIView(APIView):
    permission_classes = (IsAuthenticated | IsOwnerOrReadOnly,)

    def post(self, request, *args, **kwargs):
        post = Post.objects.get(id=self.request.data["post_id"])
        post_report = PostReport.objects.create(user=request.user, post=post)
        post_report.save()

        if post.num_reports() > 5:
            post.flagged = True
            post.save()

        return Response(status=status.HTTP_200_OK)

    def delete(self, request, *args, **kwargs):
        post = Post.objects.get(id=self.request.data["post_id"])
        post_report = PostReport.objects.get(user=request.user, post=post)
        post_report.delete()
        return Response(status=status.HTTP_200_OK)


class CommentReportAPIView(APIView):
    permission_classes = (IsAuthenticated | IsOwnerOrReadOnly,)

    def post(self, request, *args, **kwargs):
        comment = Comment.objects.get(id=self.request.data["comment_id"])
        comment_report = CommentReport.objects.create(
            user=request.user, comment=comment
        )
        comment_report.save()

        if comment.num_reports() > 5:
            comment.flagged = True
            comment.save()

        return Response(status=status.HTTP_200_OK)

    def delete(self, request, *args, **kwargs):
        comment = Comment.objects.get(id=self.request.data["comment_id"])
        comment_report = CommentReport.objects.get(user=request.user, comment=comment)
        comment_report.delete()
        return Response(status=status.HTTP_200_OK)


"""
Utility API Views
"""


class DeleteAccountAPIView(APIView):
    permission_classes = (IsAuthenticated | IsAdminUser,)

    def delete(self, request, *args, **kwargs):
        user = User.objects.get(id=self.request.data["user_id"])
        user.delete()
        return Response(status=status.HTTP_200_OK)


class LeaderboardAPIView(ListAPIView):
    serializer_class = UserSerializerLeaderboard
    permission_classes = (IsAuthenticated,)

    def get_queryset(self):
        queryset = User.objects.all()
        queryset = list(queryset)
        queryset.sort(key=operator.attrgetter("total_karma"), reverse=True)
        queryset = queryset[:10]
        return queryset


class BlockUserAPIView(APIView):
    permission_classes = (IsAuthenticated,)

    def post(self, request, *args, **kwargs):
        """
        Blocks a user based off of the ID of the post_id sent in the request
        """
        user = Post.objects.get(id=request.data["post_id"]).user
        blocked_user = BlockedUser(blockee=user, blocker=request.user)
        blocked_user.save()
        return Response(status=status.HTTP_200_OK)

    def delete(self, request, *args, **kwargs):
        """
        Unblocks a user based off of the ID of the post_id sent in the request
        """
        user = Post.objects.get(id=request.data["post_id"]).user
        blocked_user = BlockedUser.objects.get(blocker=request.user, blockee=user)

        if user == request.user:
            return JsonResponse(
                {"error": "You cannot block yourself"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        blocked_user.delete()
        return Response(status=status.HTTP_200_OK)
