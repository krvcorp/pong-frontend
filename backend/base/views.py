from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.contrib.auth import authenticate
from django.contrib.auth import login as auth_login
from django.contrib.auth import logout as auth_logout
from django.contrib.auth.decorators import login_required
from .models import User, Post, Comment, PostVote, CommentVote, DirectConversation, DirectMessage
from .forms import *


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
        email = request.POST.get("email")
        password = request.POST.get("password")
        user = authenticate(username=email, password=password)
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

def comment(request, post_id):
    if request.method == "POST":
        comment_form = CommentForm(request.POST)
        if comment_form.is_valid():
            comment = comment_form.save(commit=False)
            comment.user = request.user
            comment.post = Post.objects.get(id=post_id)
            comment.save()

            # TODO: Return JSON instead of redirect, use AJAX to add comment
            # to page directly
            return redirect("discover")

    if request.method == "GET":
        return redirect("discover")

def discover(request):
    if request.method == "POST":
        post_form = PostForm(request.POST, request.FILES)
        if post_form.is_valid():
            post = post_form.save(commit=False)
            post.user = request.user
            post.save()
            return redirect("discover")

    if request.method == "GET":
        form = PostForm()
        posts = Post.objects.all()
        comments = Comment.objects.all()
        context = {"form": form, "posts": posts, "comments": comments}
        return render(request, "discover.html", context)



# Returns user's profile page
# Can update profile in POST
# TODO: Separate editing profile from viewing profile
@login_required
def profile(request):
    if request.method == "POST":
        # get new information from the form
        user = request.user
        user.name = request.POST.get("name").strip()
        user.phone = request.POST.get("phone")
        user.email = request.POST.get("email")
        user.save()
        return redirect("profile")
    if request.method == "GET":
        context = {"user": request.user}
        return render(request, "profile.html", context)

@login_required
def leaderboard(request):
    if request.method == "POST":
        return redirect("leaderboard")
    if request.method == "GET":
        # Get all users and sort them by their total score, which is the sum of their post and comment votes
        users = User.objects.all()
        users = sorted(users, key=lambda user: user.total_score(), reverse=True) 
        context = {"users": users}
        return render(request, "leaderboard.html", context)

@login_required
def post(request, post_id):
    if request.method == "POST":
       return redirect("post")
    if request.method == "GET":
        post = Post.objects.get(id=post_id)
        comments = Comment.objects.filter(post=post)
        context = {"post": post, "comments": comments}
        return render(request, "post.html", context)

def vote_comment(request, comment_id, up_or_down):
    if request.method == "POST":
        comment_vote = CommentVote(comment=Comment.objects.get(id=comment_id), vote=up_or_down)
        comment_vote.save()
        return HttpResponse("success")
    return HttpResponse("failure")

def vote_post(request, post_id, up_or_down):
    if request.method == "POST":
        post_vote = PostVote(post=Post.objects.get(id=post_id), vote=up_or_down)
        post_vote.save()
        return HttpResponse("success")
    return HttpResponse("failure")


# This is the main message page from which all conversations can be accessed
@login_required
def message(request):
    if request.method == "POST":
        return redirect("message")
    if request.method == "GET":
        # Get all users except the current user
        context = {"users": User.objects.exclude(id=request.user.id)}
        return render(request, "message.html", context)


# This is the method to create a new DirectConversation
def createconversation(request):
    if request.method == "POST":
        if DirectConversation.objects.filter(user1=request.user, user2=User.objects.get(id=request.POST.get("user_id"))).exists():
            return redirect("conversation", conversation_id=DirectConversation.objects.get(user1=request.user, user2=User.objects.get(id=request.POST.get("user_id"))).id)
        if request.user.id == int(request.POST.get("user_id")):
            print('you cannot create a conversation with yourself')
            # TODO: Add error message for same user
            return HttpResponse("failure")
        conversation = DirectConversation(user1=request.user, user2=User.objects.get(id=request.POST.get("user_id")))
        conversation.save()

        # TODO: Ajax to add message to page, no reload
        return redirect("message")
    if request.method == "GET":
        return redirect("chat")

# This is the method to create a new DirectMessage
def createmessage(request, conversation_id):
    if request.method == "POST":
        # Create a new direct message object with the current user ID, the conversation ID, and the message
        message = DirectMessage(user=request.user, conversation=DirectConversation.objects.get(id=conversation_id), message=request.POST.get("message"))
        message.save()

        # TODO: Ajax to add message to page, no reload
        return redirect("message")
    if request.method == "GET":
        return redirect("chat")

# This is the method to render a singular conversation view
def conversation(request, conversation_id):
    if request.method == "POST":
        return redirect("conversation")
    if request.method == "GET":
        context = {"conversation": DirectConversation.objects.get(id=conversation_id)}
        return render(request, "conversation.html", context)


# Method to render a publicly facing profile page for each user
def publicprofile(request, user_id):
    if request.method == "POST":
        return redirect("publicprofile")
    if request.method == "GET":
        context = {"user": User.objects.get(id=user_id)}
        return render(request, "publicprofile.html", context)