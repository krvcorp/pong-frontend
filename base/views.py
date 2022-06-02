from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from .models import Creator
from .forms import CreatorCreationForm


def index(request):
    return render(request, "index.html")


def register(request):
    form = CreatorCreationForm(request.POST or None)
    if request.method == "POST":
        if form.is_valid():
            user = form.save(commit=False)
            user.username = user.username.lower()
            user.save()
            login(request, user)
            return render(request, "index.html")

    if request.method == "GET":
        return render(request, "register.html", {"form": form})


def login(request):
    return render(request, "login.html")
