import os
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
    ClassGroup,
    DirectConversation,
    DirectMessage,
    Token,
    PhoneLoginCode,
)
from .serializers import (
    UserSerializer,
    PostSerializer,
    CommentSerializer,
    PostReportSerializer,
    AuthCustomTokenSerializer,
    CommentVoteSerializer,
    PostVoteSerializer,
    PhoneLoginTokenSerializer,
)
from .permissions import IsOwnerOrReadOnly, IsInTimeout
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
    serializer_class = UserSerializer
    queryset = User.objects.all()
    permission_classes = ((IsAuthenticated & IsOwnerOrReadOnly) | IsAdminUser,)


class RetrieveUpdateDestroyPostAPIView(RetrieveUpdateDestroyAPIView):
    serializer_class = PostSerializer
    queryset = Post.objects.all()
    permission_classes = ((IsAuthenticated & IsOwnerOrReadOnly) | IsAdminUser,)


class RetrieveUpdateDestroyCommentAPIView(RetrieveUpdateDestroyAPIView):
    serializer_class = CommentSerializer
    queryset = Comment.objects.all()
    permission_classes = ((IsAuthenticated & IsOwnerOrReadOnly) | IsAdminUser,)


class RetrieveUpdateDestroyPostReportAPIView(RetrieveUpdateDestroyAPIView):
    serializer_class = PostReportSerializer
    queryset = PostReport.objects.all()
    permission_classes = ((IsAuthenticated & IsOwnerOrReadOnly) | IsAdminUser,)


class RetrieveUpdateDestroyCommentVoteAPIView(RetrieveUpdateDestroyAPIView):
    serializer_class = CommentVoteSerializer
    queryset = CommentVote.objects.all()
    permission_classes = ((IsAuthenticated & IsOwnerOrReadOnly) | IsAdminUser,)


class RetrieveUpdateDestroyPostVoteAPIView(RetrieveUpdateDestroyAPIView):
    serializer_class = PostVoteSerializer
    queryset = PostVote.objects.all()
    permission_classes = ((IsAuthenticated & IsOwnerOrReadOnly) | IsAdminUser,)


class ListCreateUserAPIView(ListCreateAPIView):
    serializer_class = UserSerializer
    queryset = User.objects.all()
    permission_classes = (IsAuthenticated,)

    def perform_create(self, serializer):
        serializer.save()


class ListCreatePostAPIView(ListCreateAPIView):
    serializer_class = PostSerializer
    permission_classes = (IsAuthenticated & IsInTimeout | IsAdminUser,)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def get_queryset(self):
        queryset = Post.objects.all()
        if self.request.query_params.get("recent"):
            queryset = queryset.order_by("-created_at")
        if self.request.query_params.get("top"):
            queryset = queryset.order_by("-total_score")
        if self.request.query_params.get("old"):
            queryset = queryset.order_by("created_at")
        return queryset


class ListCreateCommentAPIView(ListCreateAPIView):
    serializer_class = CommentSerializer
    queryset = Comment.objects.all()
    permission_classes = ((IsAuthenticated & IsInTimeout,) | IsAdminUser,)

    def perform_create(self, serializer):
        print(self.request.user)
        post = Post.objects.get(id=self.request.data["post_id"])
        serializer.save(user=self.request.user, post=post)


class ListCreatePostReportAPIView(ListCreateAPIView):
    serializer_class = PostReportSerializer
    queryset = PostReport.objects.all()
    permission_classes = (IsAuthenticated,)

    def perform_create(self, serializer):
        post = Post.objects.get(id=self.request.data["post_id"])
        serializer.save(user=self.request.user, post=post)


class ListCreateCommentVoteAPIView(ListCreateAPIView):
    serializer_class = CommentVoteSerializer
    queryset = CommentVote.objects.all()
    permission_classes = (IsAuthenticated | IsAdminUser,)

    def perform_create(self, serializer):
        comment = Comment.objects.get(id=self.request.data["comment_id"])
        serializer.save(user=self.request.user, comment=comment)


class ListCreatePostVoteAPIView(ListCreateAPIView):
    serializer_class = PostVoteSerializer
    queryset = PostVote.objects.all()
    permission_classes = (IsAuthenticated | IsAdminUser,)

    def perform_create(self, serializer):
        post = Post.objects.get(id=self.request.data["post_id"])
        serializer.save(user=self.request.user, post=post)


class PhoneLoginAPIView(APIView):
    def post(self, request):
        user = User.objects.get(phone=request.data["phone"])
        phone_login_code = PhoneLoginCode.objects.create(user=user)
        generated_code = phone_login_code.code

        TWILIO_ACCOUNT_SID = "AC5e7be9e9a0d92520bc1b79a9e4ce7963"
        TWILIO_SECRET_KEY = "b733808ab5bebcc9eccde14f9dcf56dc"

        account_sid = os.environ.get("TWILIO_ACCOUNT_SID")
        auth_token = os.environ.get("TWILIO_AUTH_TOKEN")

        # client = Client(account_sid, auth_token)
        client = Client(TWILIO_ACCOUNT_SID, TWILIO_SECRET_KEY)
        "+19283623318"

        message = client.messages.create(
            body=generated_code,
            to="+17039090098",
            from_="+19283623318",
        )

        # message = client.messages.create(
        #     body=generated_code,
        #     to=request.data["phone"],
        #     from_=os.environ.get("TWILIO_PHONE_NUMBER"),
        # )

        return JsonResponse({"code": generated_code})


# This is the method to create a new DirectConversation
@api_view(["POST"])
def createConversation(request):
    if DirectConversation.objects.filter(
        user1=request.user, user2=User.objects.get(id=request.POST.get("user_id"))
    ).exists():
        return redirect(
            "conversation",
            conversation_id=DirectConversation.objects.get(
                user1=request.user,
                user2=User.objects.get(id=request.POST.get("user_id")),
            ).id,
        )
    if DirectConversation.objects.filter(
        user2=request.user, user1=User.objects.get(id=request.POST.get("user_id"))
    ).exists():
        return redirect(
            "conversation",
            conversation_id=DirectConversation.objects.get(
                user2=request.user,
                user1=User.objects.get(id=request.POST.get("user_id")),
            ).id,
        )
    if request.user.id == int(request.POST.get("user_id")):
        # TODO: Add error message for same user
        return HttpResponse("failure")
    conversation = DirectConversation(
        user1=request.user, user2=User.objects.get(id=request.POST.get("user_id"))
    )
    conversation.save()
    return JsonResponse({"success": True, "conversation_id": conversation.id})


# This is the method to create a new DirectMessage
def createMessage(request, conversation_id):
    # Create a new direct message object with the current user ID, the conversation ID, and the message
    message = DirectMessage(
        user=request.user,
        conversation=DirectConversation.objects.get(id=conversation_id),
        message=request.POST.get("message"),
    )
    message.save()
    return JsonResponse({"success": True})


@api_view(["GET"])
def getLeaderboard(request):
    users = sorted(
        User.objects.all(), key=lambda user: user.total_score(), reverse=True
    )
    serializer = UserSerializer(users, many=True)
    return JsonResponse(serializer.data, safe=False)


@api_view(["POST"])
def register(request):
    context = {}
    if request.method == "POST":
        user = User.objects.create_user(
            email=request.POST.get("email"),
            password=request.POST.get("password"),
        )
        user.save()
        token = Token.objects.get(user=user).key
        context["token"] = token
        return JsonResponse(context)
    else:
        return Response(status=status.HTTP_400_BAD_REQUEST)


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
        token, created = Token.objects.get_or_create(user=user)

        return Response(
            {
                "token": token.key,
            }
        )
