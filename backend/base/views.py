from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.contrib.auth import authenticate
from django.contrib.auth import login as auth_login
from django.contrib.auth import logout as auth_logout
from django.contrib.auth.decorators import login_required
from .models import User, Post, Comment, PostVote, CommentVote
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
        post_votes =  PostVote.objects.all()
        comment_votes = CommentVote.objects.all()

        # Create dictionary of each post ID to its summed votes and populate it
        post_votes_dict = {}
        for post_vote in post_votes:
            if post_vote.post.id in post_votes_dict:
                post_votes_dict[post_vote.post.id] += post_vote.vote
            else:
                post_votes_dict[post_vote.post.id] = post_vote.vote
        
        # Create dictionary of each comment ID to its summed votes and populate it
        comment_votes_dict = {}
        for comment_vote in comment_votes:
            if comment_vote.comment.id in comment_votes_dict:
                comment_votes_dict[comment_vote.comment.id] += comment_vote.vote
            else:
                comment_votes_dict[comment_vote.comment.id] = comment_vote.vote
        

        # fill context with all the data at once
        context = {"form": form, "posts": posts, "comments": comments, "post_votes": post_votes_dict, 
        "comment_votes": comment_votes_dict}
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


