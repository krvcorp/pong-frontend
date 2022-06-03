from django.shortcuts import render, redirect
from django.contrib.auth import authenticate
from django.contrib.auth import login as auth_login
from django.contrib.auth import logout as auth_logout
from django.contrib.auth.decorators import login_required
from .models import User, Message


def index(request):
    return render(request, "index.html")


def register(request):
    context = {}

    if request.method == "POST":
        username = request.POST.get("username")
        password1 = request.POST.get("password1")
        password2 = request.POST.get("password2")
        email = request.POST.get("email")
        name = (
            request.POST.get("first_name").strip()
            + " "
            + request.POST.get("last_name").strip()
        )

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
        print("login post")
        email = request.POST.get("email")
        password = request.POST.get("password")
        print(email + password)
        user = authenticate(username=email, password=password)
        print(user)
        if user is not None:
            auth_login(request, user)
            return redirect("chat")
        else:
            # TODO: Add error message invalid credentials
            return redirect("login")
    return render(request, "login.html")


def chat(request):
    if request.method == "POST":
        message = request.POST.get("message")
        user = request.user
        new_message_object = Message.objects.create(user=user, message=message)
        new_message_object.save()
        return redirect("chat")

    if request.method == "GET":
        messages = Message.objects.all()
        context = {"messages": messages}
        return render(request, "chat.html", context)


def logout(request):
    auth_logout(request)
    return redirect("index")


# Update a user's profile with new information that they submitted in the form in the profile page.
@login_required
def profile(request):
    if request.method == "POST":
        # get new information from the form
        name = (
            request.POST.get("first_name").strip()
            + " "
            + request.POST.get("last_name").strip()
        )
        phone = request.POST.get("phone")
        email = request.POST.get("email")
        phone = request.POST.get("phone")
        address = request.POST.get("address")
        city = request.POST.get("city")
        state = request.POST.get("state")
        zipcode = request.POST.get("zipcode")
        country = request.POST.get("country")
        # update the user's profile with the new information
        user = request.user

        return redirect("profile")
    if request.method == "GET":
        return render(request, "profile.html")
