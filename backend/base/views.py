from django.shortcuts import render, redirect
from django.http import HttpResponse, JsonResponse
from django.contrib.auth import authenticate
from django.contrib.auth import login as auth_login
from django.contrib.auth import logout as auth_logout
from django.contrib.auth.decorators import login_required
from .models import (
    User,
    Post,
    Comment,
    PostVote,
    CommentVote,
    DirectConversation,
    DirectMessage,
    PostReport,
)


# base.views holds render-only methods


def index(request):
    return redirect("discover")


def register(request):
    context = {}

    if request.method == "POST":
        username = request.POST.get("username")
        password1 = request.POST.get("password1")
        password2 = request.POST.get("password2")
        email = request.POST.get("email")
        name = request.POST.get("name").strip()

        # Confirm matching passwords
        if password1 == password2:
            user = User.objects.create_user(
                username=username, password=password1, email=email, name=name
            )
            user.save()
            return redirect("login")
        else:
            # TODO: Add error message password mismatch
            return redirect("register")

    if request.method == "GET":
        return render(request, "register.html", context)


def login(request):
    if request.method == "POST":
        user = authenticate(
            username=request.POST.get("email"), password=request.POST.get("password")
        )
        if user is not None:
            auth_login(request, user)
            return redirect("discover")
        else:
            # TODO: Add error message invalid credentials
            return redirect("login")
    return render(request, "login.html")


def logout(request):
    auth_logout(request)
    return redirect("index")


def discover(request):
    context = {"posts": Post.objects.all(), "comments": Comment.objects.all()}
    return render(request, "discover.html", context)


@login_required
def profile(request):
    context = {"user": request.user}
    return render(request, "profile.html", context)


@login_required
def leaderboard(request):
    context = {
        "users": sorted(
            User.objects.all(), key=lambda user: user.total_score(), reverse=True
        )
    }
    return render(request, "leaderboard.html", context)


@login_required
def post(request, post_id):
    post = Post.objects.get(id=post_id)
    comments = Comment.objects.filter(post=post)
    context = {"post": post, "comments": comments}
    return render(request, "post.html", context)


@login_required
def message(request):
    context = {"users": User.objects.exclude(id=request.user.id)}
    return render(request, "message.html", context)


def conversation(request, conversation_id):
    context = {"conversation": DirectConversation.objects.get(id=conversation_id)}
    return render(request, "conversation.html", context)


def publicprofile(request, user_id):
    context = {"user": User.objects.get(id=user_id)}
    return render(request, "publicprofile.html", context)


def reportedposts(request):
    context = {}
    reported_posts = []
    for postreport in PostReport.objects.all():
        if postreport.post not in reported_posts:
            reported_posts.append(postreport.post)
    context["reported_posts"] = reported_posts
    return render(request, "reportedposts.html", context)
