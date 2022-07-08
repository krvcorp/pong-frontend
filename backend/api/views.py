import datetime
import os
import operator
import re
from tempfile import TemporaryFile
from django.shortcuts import render, redirect
from django.shortcuts import redirect
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse, JsonResponse
from base.models import (
    User,
    Post,
    Comment,
    PostReport,
    CommentVote,
    PostVote,
    School,
    DirectConversation,
    DirectMessage,
    Token,
    PhoneLoginCode,
)
from .serializers import (
    DirectMessageSerializer,
    UserSerializer,
    UserSerializerLeaderboard,
    UserSerializerWithoutTimeout,
    PostSerializer,
    CommentSerializer,
    PostReportSerializer,
    AuthCustomTokenSerializer,
    CommentVoteSerializer,
    PostVoteSerializer,
    PhoneLoginTokenSerializer,
)
from .permissions import IsOwnerOrReadOnly, IsNotInTimeout
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.generics import RetrieveUpdateDestroyAPIView, ListCreateAPIView
from rest_framework.parsers import JSONParser, MultiPartParser, FormParser
from rest_framework.renderers import JSONRenderer
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from twilio.rest import Client


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


class RetrieveUpdateDestroyPostReportAPIView(RetrieveUpdateDestroyAPIView):
    lookup_field = "id"
    serializer_class = PostReportSerializer
    queryset = PostReport.objects.all()
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


class ListCreateUserAPIView(ListCreateAPIView):
    permission_classes = (IsAuthenticated,)

    def get_serializer(self, *args, **kwargs):
        sort = self.request.query_params.get("sort", None)
        if sort == "leaderboard":
            return UserSerializerLeaderboard(*args, **kwargs)
        if self.request.user.is_staff:
            return UserSerializer(*args, **kwargs)
        else:
            return UserSerializerWithoutTimeout(*args, **kwargs)

    def perform_create(self, serializer):
        serializer.save()

    def get_queryset(self):
        queryset = User.objects.all()
        sort = self.request.query_params.get("sort", None)
        if sort == "leaderboard":
            queryset = list(queryset)
            queryset.sort(key=operator.attrgetter("score"), reverse=True)
            queryset = queryset[:10]
        return queryset


class ListCreatePostAPIView(ListCreateAPIView):
    serializer_class = PostSerializer
    permission_classes = (IsAuthenticated & IsNotInTimeout | IsAdminUser,)

    def perform_create(self, serializer):
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

    def perform_create(self, serializer):
        post = Post.objects.get(id=self.request.data["post_id"])
        serializer.save(user=self.request.user, post=post)
        CommentVote.objects.create(
            user=self.request.user, comment=serializer.instance, vote=1
        )


class ListCreatePostReportAPIView(ListCreateAPIView):
    serializer_class = PostReportSerializer
    queryset = PostReport.objects.all()
    permission_classes = (IsAuthenticated,)

    def perform_create(self, serializer):
        post = Post.objects.get(id=self.request.data["post_id"])
        serializer.save(user=self.request.user, post=post)


class ListCreatePostVoteAPIView(ListCreateAPIView):
    serializer_class = PostVoteSerializer
    queryset = PostVote.objects.all()
    permission_classes = (IsAuthenticated | IsAdminUser,)

    def create_perform(self, serializer):
        serializer.save(
            user=self.request.user,
            post=Post.objects.get(id=self.request.data["post_id"]),
        )


class ListCreateCommentVoteAPIView(ListCreateAPIView):
    serializer_class = CommentVoteSerializer
    queryset = CommentVote.objects.all()
    permission_classes = (IsAuthenticated | IsAdminUser,)

    def perform_create(self, serializer):
        serializer.save(
            user=self.request.user,
            comment=Comment.objects.get(id=self.request.data["comment_id"]),
        )


# This is the method to create a new DirectMessage
class ListCreateMessage(ListCreateAPIView):
    """
    List all messages or create a new message.
    """

    def get_queryset(self):
        return DirectMessage.objects.all()

    def get_serializer_class(self):
        return DirectMessageSerializer

    def perform_create(self, serializer):
        conversation = DirectConversation.objects.get(
            id=self.request.data["conversation_id"]
        )
        serializer.save(
            user=self.request.user,
            conversation=conversation,
            message=self.request.data["message"],
        )


class OTPStart(APIView):
    """
    This method is used to start the OTP process. It creates a new OTP object and sends a text message to the user, based on the phone number in the request.
    """

    def post(self, request):
        context = {}
        user, created = User.objects.get_or_create(phone=request.data["phone"])
        phone_login_code = PhoneLoginCode.objects.create(user=user)
        generated_code = phone_login_code.code

        # Local
        TWILIO_ACCOUNT_SID = "AC5e7be9e9a0d92520bc1b79a9e4ce7963"
        TWILIO_SECRET_KEY = "b733808ab5bebcc9eccde14f9dcf56dc"

        # Prod
        # TWILIO_ACCOUNT_SID = os.environ.get("TWILIO_ACCOUNT_SID")
        # TWILIO_SECRET_KEY = os.environ.get("TWILIO_AUTH_TOKEN")
        # TWILIO_NUMBER = os.environ.get("TWILIO_NUMBER")

        client = Client(TWILIO_ACCOUNT_SID, TWILIO_SECRET_KEY)

        # Local
        message = client.messages.create(
            body=generated_code,
            to=request.data["phone"],
            from_="+19283623318",
        )

        # Prod
        # message = client.messages.create(
        #     body=generated_code,
        #     to=request.data["phone"],
        #     from_=TWILIO_NUMBER,
        # )

        context["new_user"] = created
        context["phone"] = request.data["phone"]

        return JsonResponse(context)


class OTPVerify(APIView):
    """
    This method is used to verify the OTP code. It checks if the code is correct and unexpired and if it is, then checks if the user has been verified. If the user has been verified, then it returns a token. If the user has not been verified, then it returns 'code_incorrect' as a part of the context. If the code is incorrect or expired, then it returns the respective error message as a part of the context.
    """

    def post(self, request):
        context = {}
        user = User.objects.get(phone=request.data["phone"])
        phone_login_code = PhoneLoginCode.objects.filter(user=user).order_by(
            "-created_at"
        )[0]
        if phone_login_code.code == request.data["code"]:
            if not phone_login_code.is_expired and not phone_login_code.is_used:
                phone_login_code.use()
                if user.has_been_verified:
                    context["token"] = Token.objects.get(user=user).key
                else:
                    context["email_unverified"] = True
            else:
                context["code_expired"] = True
        else:
            context["code_incorrect"] = True
        return JsonResponse(context)


class VerifyUser(APIView):
    def post(self, request):
        context = {}

        domain = re.search("@[\w.]+", request.POST.get("email"))
        school, _ = School.objects.get_or_create(domain=domain)
        user = User.objects.get(phone=request.POST.get("phone"))

        user.has_been_verified = True
        user.school = school
        user.email = request.POST.get("email")
        user.save()

        context["token"] = Token.objects.get(user=user).key
        return JsonResponse(context)


# Login Method
class ObtainAuthToken(APIView):
    throttle_classes = ()
    permission_classes = ()
    parser_classes = (
        FormParser,
        MultiPartParser,
        JSONParser,
    )
    renderer_classes = (JSONRenderer,)

    def post(self, request):
        if "code" in request.data:
            serializer = PhoneLoginTokenSerializer(data=request.data)
        else:
            serializer = AuthCustomTokenSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data["user"]
        token, _ = Token.objects.get_or_create(user=user)

        return Response(
            {
                "token": token.key,
            }
        )
