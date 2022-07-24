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
from .models import (
    Poll,
    PostSave,
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
    PollSerializer,
    UserSerializer,
    UserSerializerLeaderboard,
    PostSerializer,
    CommentSerializer,
    PostReportSerializer,
    AuthCustomTokenSerializer,
    CommentVoteSerializer,
    PostVoteSerializer,
    PhoneLoginTokenSerializer,
    UserSerializerProfile,
    PostSaveSerializer,
)
from .permissions import IsAdmin, IsOwnerOrReadOnly, IsNotInTimeout
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


# Retrieve Update Destroy PostSave  APIView
class RetrieveUpdateDestroyPostSaveAPIView(RetrieveUpdateDestroyAPIView):
    lookup_field = "id"
    serializer_class = PostSaveSerializer
    queryset = PostSave.objects.all()
    permission_classes = (IsAuthenticated & IsOwnerOrReadOnly | IsAdminUser,)


class ListCreatePostSaveAPIView(ListCreateAPIView):
    serializer_class = PostSaveSerializer
    queryset = PostSave.objects.all()
    permission_classes = (IsAuthenticated & IsNotInTimeout | IsAdminUser,)


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
            queryset.sort(key=operator.attrgetter("score"), reverse=True)
            queryset = queryset[:10]
        return queryset


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

    def perform_create(self, serializer):
        post = Post.objects.get(id=self.request.data["post_id"])
        serializer.save(user=self.request.user, post=post)
        CommentVote.objects.create(
            user=self.request.user, comment=serializer.instance, vote=1
        )


class ListCreatePollAPIView(ListCreateAPIView):
    serializer_class = PollSerializer
    queryset = Poll.objects.all()
    permission_classes = (IsAuthenticated & IsNotInTimeout | IsAdminUser,)

    def perform_create(self, serializer):
        return super().perform_create(serializer)


class ListCreatePostReportAPIView(ListCreateAPIView):
    serializer_class = PostReportSerializer
    queryset = PostReport.objects.all()
    permission_classes = (IsAuthenticated,)

    def create(self, request, *args, **kwargs):
        # https://stackoverflow.com/questions/33861545/how-can-modify-request-data-in-django-rest-framework
        # https://stackoverflow.com/questions/34661853/django-rest-framework-this-field-is-required-with-required-false-and-unique
        print(request)
        print(request.data)
        request.data._mutable = True
        request.data["user"] = request.user.id
        request.data["post"] = request.data["post_id"]
        return super().create(request, *args, **kwargs)


class ListCreatePostVoteAPIView(ListCreateAPIView):
    serializer_class = PostVoteSerializer
    queryset = PostVote.objects.all()
    permission_classes = (IsAuthenticated | IsAdminUser,)


class ListCreateCommentVoteAPIView(ListCreateAPIView):
    serializer_class = CommentVoteSerializer
    queryset = CommentVote.objects.all()
    permission_classes = (IsAuthenticated | IsAdminUser,)


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
        phone = request.data["phone"]
        user, created = User.objects.get_or_create(phone=phone)
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

        if len(phone) == 0:
            return JsonResponse(
                {"error": "Phone number is required"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        phone = "".join(filter(lambda x: x.isdigit(), phone))
        if len(phone) != 10:
            return JsonResponse(
                {"error": "Phone number is invalid"}, status=status.HTTP_400_BAD_REQUEST
            )

        # Lookup for VoIP number
        # phone_number_carrier = client.lookups.phone_numbers(phone).fetch(type="carrier")

        # if phone_number_carrier.carrier["type"] != "mobile":
        #     return JsonResponse(
        #         {"error": "Phone number can't be VoIP."}, status=status.HTTP_400_BAD_REQUEST
        #     )

        # Commented out for saving money, check in admin panel if you want to use this
        # message = client.messages.create(
        #     body=generated_code,
        #     to=request.data["phone"],
        #     from_="+19283623318",
        # )

        # Prod
        # message = client.messages.create(
        #     body=generated_code,
        #     to=request.data["phone"],
        #     from_=TWILIO_NUMBER,
        # )

        context["new_user"] = created
        context["phone"] = phone

        return JsonResponse(context)


class ResendOTP(APIView):
    """
    This method is used to resend the most recently generated OTP code to the user, based on the phone number in the request.
    """

    def post(self, request):
        context = {}
        phone = request.data["phone"]
        user, created = User.objects.get_or_create(phone=phone)
        if created:
            return JsonResponse(
                {"error": "Phone number does not exist."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            most_recent_code = PhoneLoginCode.objects.filter(user=user).order_by(
                "-created_at"
            )[0]
            generated_code = most_recent_code.code
        except Exception as e:
            return JsonResponse(
                {"error": "User has no OTP codes."}, status=status.HTTP_400_BAD_REQUEST
            )

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

        context["phone"] = phone

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
                    context["user_id"] = user.id
                else:
                    context["email_unverified"] = True
            else:
                context["code_expired"] = True
        else:
            context["code_incorrect"] = True
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
        context = {}
        if "code" in request.data:
            serializer = PhoneLoginTokenSerializer(data=request.data)
        else:
            serializer = AuthCustomTokenSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data["user"]
        token, _ = Token.objects.get_or_create(user=user)

        context["token"] = token.key
        context["user"] = UserSerializer(user).data
        return JsonResponse(context)

# TokenSignIn Method / VerifyUser replacement
from google.oauth2 import id_token
from google.auth.transport import requests

class VerifyUser(APIView):
    def post(self, request):
        try:
            # Specify the CLIENT_ID of the app that accesses the backend:
            idinfo = id_token.verify_oauth2_token(request.data["id_token"], requests.Request(), "983201170682-kttqq1l89i4fpgk15fud1u1hf192fq1q.apps.googleusercontent.com")

            # ID token is valid. Get the user's Google Account ID from the decoded token.
            context = {}

            domain = re.search("@[\w.]+", idinfo['email'])
            school, _ = School.objects.get_or_create(domain=domain)
            user = User.objects.get(phone=request.data["phone"])

            user.has_been_verified = True
            user.school = school
            user.email = idinfo['email']
            user.save()

            context["token"] = Token.objects.get(user=user).key
            context["user"] = UserSerializer(user).data
            print(context)
            return JsonResponse(context)

        except ValueError:
            # Invalid token
            pass
