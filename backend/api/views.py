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
)
from .serializers import (
    UserSerializer,
    PostSerializer,
    CommentSerializer,
    PostReportSerializer,
    AuthCustomTokenSerializer,
)
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.parsers import JSONParser, MultiPartParser, FormParser
from rest_framework.renderers import JSONRenderer


@api_view(["GET", "DELETE", "PUT"])
def user(request, user_id):
    try:
        user = User.objects.get(id=user_id)
    except user.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == "GET":
        serializer = UserSerializer(user)
        return Response(serializer.data)
    elif request.method == "DELETE":
        user.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    elif request.method == "PUT":
        serializer = UserSerializer(user, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET", "DELETE", "PUT"])
def post(request, post_id):
    # Get the post with the given ID
    try:
        post = Post.objects.get(id=post_id)
    except Post.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    if request.method == "GET":
        serializer = PostSerializer(post)
        return Response(serializer.data)
    elif request.method == "DELETE":
        post.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    elif request.method == "PUT":
        serializer = PostSerializer(post, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET"])
def getPosts(request):
    if request.method == "GET":
        posts = Post.objects.all()
        serializer = PostSerializer(posts, many=True)
        return Response(serializer.data)


@api_view(["POST"])
def createUser(request):
    # Create a new user object with the given email and password
    new_user = User.objects.create_user(
        email=request.POST.get("email"), password=request.POST.get("password")
    )
    new_user.save()
    return JsonResponse({"success": True})


@api_view(["GET", "DELETE", "PUT"])
def comment(request, comment_id):
    # Get the comment with the given ID
    try:
        comment = Comment.objects.get(id=comment_id)
    except Comment.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == "GET":
        serializer = CommentSerializer(comment)
        return Response(serializer.data)
    elif request.method == "DELETE":
        comment.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    elif request.method == "PUT":
        serializer = CommentSerializer(comment, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["POST"])
def createPost(request):
    if request.method == "POST":
        post = Post.objects.create(
            user=request.user,
            title=request.data["title"],
            image=(request.FILES["image"] if "image" in request.FILES else None),
        )
        serializer = PostSerializer(post)
        return JsonResponse(serializer.data)


@api_view(["POST"])
def createComment(request, post_id):
    if request.method == "POST":
        comment = Comment.objects.create(
            user=request.user,
            post=Post.objects.get(id=post_id),
            comment=request.data["comment"],
        )
        serializer = CommentSerializer(comment)
        return Response(serializer.data)


@api_view(["POST"])
def createPostReport(request):
    if request.method == "POST":
        user = User.objects.get(id=request.data["user_id"])
        post = Post.objects.get(id=request.data["post_id"])
        post_report = PostReport.objects.create(user=user, post=post)
        serializer = PostReportSerializer(post_report)
        return Response(serializer.data)


@api_view(["POST"])
def createCommentVote(request, comment_id, up_or_down):
    vote = 1 if up_or_down == "up" else -1
    response = {}
    if CommentVote.objects.filter(
        user=request.user, comment=Comment.objects.get(id=comment_id)
    ).exists():
        if (
            CommentVote.objects.get(
                user=request.user, comment=Comment.objects.get(id=comment_id)
            ).vote
            == vote
        ):
            response["action"] = "delete"
            CommentVote.objects.filter(
                user=request.user, comment=Comment.objects.get(id=comment_id)
            ).delete()
        else:
            response["action"] = "update"
            CommentVote.objects.filter(
                user=request.user, comment=Comment.objects.get(id=comment_id)
            ).update(vote=vote)
    else:
        comment_vote = CommentVote(
            user=request.user, comment=Comment.objects.get(id=comment_id), vote=vote
        )
        comment_vote.save()
        response = {"action": "create"}
    response["comment_id"] = comment_id
    response["new_score"] = Comment.objects.get(id=comment_id).total_score()
    return JsonResponse(response)


@api_view(["POST"])
def createPostVote(request, post_id, up_or_down):
    response = {}
    vote = 1 if up_or_down == "up" else -1
    if PostVote.objects.filter(
        user=request.user, post=Post.objects.get(id=post_id)
    ).exists():
        if (
            PostVote.objects.get(
                user=request.user, post=Post.objects.get(id=post_id)
            ).vote
            == vote
        ):
            response["action"] = "delete"
            PostVote.objects.filter(
                user=request.user, post=Post.objects.get(id=post_id)
            ).delete()
        else:
            response["action"] = "update"
            PostVote.objects.filter(
                user=request.user, post=Post.objects.get(id=post_id)
            ).update(vote=vote)
    else:
        post_vote = PostVote(
            user=request.user, post=Post.objects.get(id=post_id), vote=vote
        )
        post_vote.save()
        response = {"action": "create"}
    response["post_id"] = post_id
    response["new_score"] = Post.objects.get(id=post_id).total_score()
    return JsonResponse(response)


@api_view(["POST"])
def createClassGroup(request):
    # TODO: Check if class group already exists
    group = ClassGroup(
        name=request.POST.get("name"),
        description=request.POST.get("description"),
        user=request.user,
    )
    group.save()
    return JsonResponse({"action": "create", "status": "success", "group_id": group.id})


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
    return render(request, "register.html", context)


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
        serializer = AuthCustomTokenSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data["user"]
        token, created = Token.objects.get_or_create(user=user)

        content = {
            "token": token.key,
        }

        return Response(content)
