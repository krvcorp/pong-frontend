from rest_framework.response import Response
from rest_framework.decorators import api_view
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
)
from .serializers import (
    UserSerializer,
    PostSerializer,
    CommentSerializer,
    PostReportSerializer,
)


@api_view(["GET"])
def getUser(request, user_id):
    if request.method == "GET":
        user = User.objects.get(id=user_id)
        serializer = UserSerializer(user)
        return Response(serializer.data)


@api_view(["GET"])
def getPost(request, post_id):
    if request.method == "GET":
        post = Post.objects.get(id=post_id)
        serializer = PostSerializer(post)
        return Response(serializer.data)


@api_view(["GET"])
def getPosts(request):
    if request.method == "GET":
        posts = Post.objects.all()
        serializer = PostSerializer(posts, many=True)
        return Response(serializer.data)


@api_view(["GET"])
def getComment(request, comment_id):
    if request.method == "GET":
        comment = Comment.objects.get(id=comment_id)
        serializer = CommentSerializer(comment)
        return Response(serializer.data)


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
def updatePost(request, post_id):
    if request.method == "POST":
        post = Post.objects.get(id=post_id)
        post.title = request.data["title"] if "title" in request.data else post.title
        post.image = request.data["image"] if "image" in request.data else post.image
        post.save()
        serializer = PostSerializer(post)
        return Response(serializer.data)


@api_view(["POST"])
def updateProfile(request):
    if request.method == "POST":
        user = request.user
        user.name = (
            request.data["name"].strip() if "name" in request.data else user.name
        )
        user.email = (
            request.data["email"].strip() if "email" in request.data else user.email
        )
        user.profile_picture = (
            request.FILES["profile_picture"]
            if "profile_picture" in request.FILES
            else user.profile_picture
        )
        user.save()
        serializer = UserSerializer(user)
        return Response(serializer.data)


@api_view(["DELETE"])
def deletePost(request, post_id):
    if request.method == "DELETE":
        post = Post.objects.get(id=post_id)
        post.delete()
        return Response("Post deleted")


@api_view(["DELETE"])
def deleteComment(request, comment_id):
    if request.method == "DELETE":
        comment = Comment.objects.get(id=comment_id)
        comment.delete()
        return Response("Comment deleted")


@login_required
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


@login_required
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
