from ast import IsNot
import datetime
import os
import operator
import re
from tempfile import TemporaryFile
from typing import List
from django.shortcuts import render, redirect
from django.shortcuts import redirect
from django.contrib.auth.decorators import login_required
from django.http import JsonResponse
from pytz import timezone
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
    PhoneLoginCode,
    BlockedUser,
)
from .serializers import (
    PollSerializer,
    PostCommentsSerializer,
    UserSerializer,
    UserSerializerLeaderboard,
    PostSerializer,
    CommentSerializer,
    PostReportSerializer,
    CommentVoteSerializer,
    PostVoteSerializer,
    PhoneLoginTokenSerializer,
    UserSerializerProfile,
    PostSaveSerializer,
    PostCommentsSerializer,
)
from .permissions import IsAdmin, IsOwnerOrReadOnly, IsNotInTimeout
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.generics import (
    RetrieveUpdateDestroyAPIView,
    ListCreateAPIView,
    ListAPIView,
)
from rest_framework.parsers import JSONParser, MultiPartParser, FormParser
from rest_framework.renderers import JSONRenderer
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from twilio.rest import Client
from google.oauth2 import id_token
from google.auth.transport import requests


class RetrieveUpdateDestroyUserAPIView(RetrieveUpdateDestroyAPIView):
    lookup_field = "id"
    serializer_class = UserSerializer
    queryset = User.objects.all()
    permission_classes = (IsAuthenticated & IsOwnerOrReadOnly | IsAdminUser,)


class RetrieveUpdateDestroyPostAPIView(RetrieveUpdateDestroyAPIView):
    lookup_field = "id"
    serializer_class = PostSerializer
    queryset = Post.objects.all()
    permission_classes = (IsAuthenticated & IsOwnerOrReadOnly | IsAdminUser,)


class RetrieveUpdateDestroyCommentAPIView(RetrieveUpdateDestroyAPIView):
    lookup_field = "id"
    serializer_class = CommentSerializer
    queryset = Comment.objects.all()
    permission_classes = (IsAuthenticated & IsOwnerOrReadOnly | IsAdminUser,)


class RetrieveUpdateDestroyCommentVoteAPIView(RetrieveUpdateDestroyAPIView):
    lookup_field = "id"
    serializer_class = CommentVoteSerializer
    queryset = CommentVote.objects.all()
    permission_classes = (IsAuthenticated & IsOwnerOrReadOnly | IsAdminUser,)


class RetrieveUpdateDestroyPostVoteAPIView(RetrieveUpdateDestroyAPIView):
    lookup_field = "id"
    serializer_class = PostVoteSerializer
    queryset = PostVote.objects.all()
    permission_classes = (IsAuthenticated & IsOwnerOrReadOnly | IsAdminUser,)


class PostSaveAPIView(APIView):
    permission_classes = (IsAuthenticated & IsOwnerOrReadOnly | IsAdminUser,)

    def post(self, request, *args, **kwargs):
        """
        Creates a new PostSave object based off of post_id in the request body.
        """

        post = Post.objects.get(id=request.data.get("post_id"))
        if PostSave.objects.filter(user=request.user, post=post).exists():
            return Response(
                {"error": "post_already_saved"}, status=status.HTTP_400_BAD_REQUEST
            )
        post_save = PostSave.objects.create(post=post, user=request.user)
        post_save.save()
        return Response(status=status.HTTP_201_CREATED)

    def delete(self, request, *args, **kwargs):
        """
        Deletes a PostSave object based off of post_id in the request body.
        """

        post = Post.objects.get(id=request.data.get("post_id"))
        if not PostSave.objects.filter(user=request.user, post=post).exists():
            return Response(
                {"error": "post_not_saved"}, status=status.HTTP_400_BAD_REQUEST
            )
        PostSave.objects.filter(user=request.user, post=post).delete()
        return Response(status=status.HTTP_200_OK)


class ListCreateUserAPIView(ListCreateAPIView):
    permission_classes = (IsAuthenticated,)

    def get_serializer(self, *args, **kwargs):
        sort = self.request.query_params.get("sort", None)
        if sort == "leaderboard":
            return UserSerializerLeaderboard(*args, **kwargs)
        if sort == "profile":
            return UserSerializerProfile(*args, **kwargs)
        return UserSerializer(*args, **kwargs)

    def perform_create(self, serializer):
        serializer.save()

    def get_queryset(self):
        queryset = User.objects.all()
        sort = self.request.query_params.get("sort", None)
        if sort == "leaderboard":
            queryset = list(queryset)
            queryset.sort(key=operator.attrgetter("total_karma"), reverse=True)
            queryset = queryset[:10]
        return queryset


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


class ListCreatePostAPIView(ListCreateAPIView):
    serializer_class = PostSerializer
    permission_classes = (IsAuthenticated & IsNotInTimeout | IsAdminUser,)

    class Meta:
        model = Post
        fields = "__all__"
        read_only_fields = ["time_since_posted"]

    def perform_create(self, serializer):

        # Example Poll Object Input
        # "poll": {
        #     "title": "Sample Poll",
        #     "options": [
        #          "Option 1",
        #          "Option 2",
        #             ...
        #       ]
        # }

        print("creating")
        if "poll" in self.request.data:
            poll_data = self.request.data["poll"]
            Poll.objects.create(user=self.request.user, title=self)
        print(self.request.data)
        serializer.save(user=self.request.user)
        PostVote.objects.create(
            user=self.request.user, post=serializer.instance, vote=1
        )

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
        return Response(status=status.HTTP_201_CREATED)

    def get(self, request, *args, **kwargs):
        """
        Returns a list of comments based off of the post_id sent in the request body.
        """
        post = Post.objects.get(id=request.query_params.get("post_id"))
        queryset = Comment.objects.filter(post=post, parent=None)
        return Response(PostCommentsSerializer(queryset, many=True).data)


class ListCreatePollAPIView(ListCreateAPIView):
    serializer_class = PollSerializer
    queryset = Poll.objects.all()
    permission_classes = (IsAuthenticated & IsNotInTimeout | IsAdminUser,)

    def perform_create(self, serializer):
        return super().perform_create(serializer)


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


class ListCreatePostVoteAPIView(ListCreateAPIView):
    serializer_class = PostVoteSerializer
    queryset = PostVote.objects.all()
    permission_classes = (IsAuthenticated | IsAdminUser,)


class ListCreateCommentVoteAPIView(ListCreateAPIView):
    serializer_class = CommentVoteSerializer
    queryset = CommentVote.objects.all()
    permission_classes = (IsAuthenticated | IsAdminUser,)


class DeleteAccountAPIView(APIView):
    permission_classes = (IsAuthenticated | IsAdminUser,)

    def delete(self, request, *args, **kwargs):
        user = User.objects.get(id=self.request.data["user_id"])
        user.delete()
        return Response(status=status.HTTP_200_OK)


class OTPStart(APIView):
    """
    This method is used to start the OTP process. It creates a new OTP object and sends a text message to the user, based on the phone number in the request.
    """

    def post(self, request):
        context = {}
        context["new_user"] = True  # By default, assume the user is new

        phone = request.data["phone"]
        phone = "".join(filter(lambda x: x.isdigit(), phone))
        user_phone_numbers = User.objects.values_list("phone", flat=True)
        if phone in user_phone_numbers:
            context["new_user"] = False

        if len(phone) != 10:
            return JsonResponse(
                {"error": "number_invalid"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        # Lookup for VoIP number
        # phone_number_carrier = client.lookups.phone_numbers(phone).fetch(type="carrier")
        # if phone_number_carrier.carrier["type"] != "mobile":
        #     return JsonResponse(
        #         {"error": "number_voip"},
        #         status=status.HTTP_400_BAD_REQUEST
        #     )

        user = None
        if context["new_user"]:
            user = User.objects.create_user(phone)
        else:
            user = User.objects.get(phone=phone)
        code = PhoneLoginCode.objects.filter(user=user).order_by("-created_at")
        if code.count() > 0:
            code = code[0]
            time_elapsed = (
                datetime.datetime.now(datetime.timezone.utc) - code.created_at
            )
            if time_elapsed.total_seconds() < 30:
                return JsonResponse(
                    {"error": "code_already_sent"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        code = PhoneLoginCode.objects.create(user=user)

        TWILIO_ACCOUNT_SID = "AC5e7be9e9a0d92520bc1b79a9e4ce7963"
        TWILIO_SECRET_KEY = "b733808ab5bebcc9eccde14f9dcf56dc"

        client = Client(TWILIO_ACCOUNT_SID, TWILIO_SECRET_KEY)

        # Commented out for saving money, check in admin panel if you want to use this
        # message = client.messages.create(
        #     body=code.code,
        #     to=request.data["phone"],
        #     from_="+19283623318",
        # )

        context["phone"] = phone
        return JsonResponse(context)


class OTPVerify(APIView):
    """
    This method is used to verify the OTP code. It checks if the code is correct and unexpired and if it is, then checks if the user has been verified. If the user has been verified, then it returns a token. If the user has not been verified, then it returns 'code_incorrect' as a part of the context. If the code is incorrect or expired, then it returns the respective error message as a part of the context.
    """

    def post(self, request):
        context = {}
        phone = request.data["phone"]
        phone = "".join(filter(lambda x: x.isdigit(), phone))
        user = User.objects.get(phone=phone)
        phone_login_code = PhoneLoginCode.objects.filter(user=user).order_by(
            "-created_at"
        )[0]
        if phone_login_code.code == request.data["code"]:
            if not phone_login_code.is_expired and not phone_login_code.is_used:
                phone_login_code.use()
                if user.has_been_verified:
                    context["token"] = Token.objects.get(user=user).key
                    context["user_id"] = user.id
                else:
                    context["email_unverified"] = True
            else:
                context["code_expired"] = True
        else:
            context["code_incorrect"] = True
        return JsonResponse(context)


class VerifyUser(APIView):
    def post(self, request):
        try:
            # Specify the CLIENT_ID of the app that accesses the backend:
            idinfo = id_token.verify_oauth2_token(
                request.data["id_token"],
                requests.Request(),
                "983201170682-kttqq1l89i4fpgk15fud1u1hf192fq1q.apps.googleusercontent.com",
                # needs to go into environment variable
            )

            phone = request.data["phone"]
            phone = "".join(filter(lambda x: x.isdigit(), phone))

            # ID token is valid. Get the user's Google Account ID from the decoded token.
            context = {}

            domain = re.search("@[\w.]+", idinfo["email"])
            school, _ = School.objects.get_or_create(domain=domain)
            user = User.objects.get(phone=phone)

            user.has_been_verified = True
            user.school = school
            user.email = idinfo["email"]
            user.save()

            context["token"] = Token.objects.get(user=user).key
            context["user"] = UserSerializer(user).data
            return JsonResponse(context)

        except ValueError:
            # Invalid token
            pass
