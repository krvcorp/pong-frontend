from rest_framework import serializers
from base.models import (
    User,
    Post,
    Comment,
    PostReport,
    CommentVote,
    PostVote,
    DirectConversation,
    DirectMessage,
)
from rest_framework.authtoken.models import Token
from django.core.validators import validate_email
from django.core.exceptions import ValidationError
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate


class UserSerializer(serializers.ModelSerializer):
    posts = serializers.SerializerMethodField(read_only=True)
    comments = serializers.SerializerMethodField(read_only=True)
    is_in_timeout = serializers.SerializerMethodField(read_only=True)

    def get_posts(self, obj):
        return PostSerializer(obj.get_posts(), many=True).data

    def get_comments(self, obj):
        return CommentSerializer(obj.get_comments(), many=True).data

    def get_is_in_timeout(self, obj):
        return obj.in_timeout

    class Meta:
        model = User
        fields = (
            "id",
            "email",
            "posts",
            "comments",
            "is_in_timeout",
            "phone",
        )


class UserSerializerWithoutTimeout(serializers.ModelSerializer):
    posts = serializers.SerializerMethodField(read_only=True)
    comments = serializers.SerializerMethodField(read_only=True)

    def get_posts(self, obj):
        return PostSerializer(obj.get_posts(), many=True).data

    def get_comments(self, obj):
        return CommentSerializer(obj.get_comments(), many=True).data

    class Meta:
        model = User
        fields = ("id", "email", "posts", "comments", "phone")


class PostSerializer(serializers.ModelSerializer):
    num_comments = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()
    score = serializers.SerializerMethodField()

    def get_num_comments(self, obj):
        return obj.num_comments()

    def get_score(self, obj):
        return obj.score

    def get_comments(self, obj):
        comments = obj.get_comments()
        comments = sorted(comments, key=lambda x: x.score, reverse=True)
        return CommentSerializer(comments, many=True).data

    class Meta:
        model = Post
        fields = (
            "id",
            "user",
            "title",
            "created_at",
            "updated_at",
            "image",
            "num_comments",
            "comments",
            "score",
        )


class CommentSerializer(serializers.ModelSerializer):
    score = serializers.SerializerMethodField()

    def get_score(self, obj):
        return obj.score

    class Meta:
        model = Comment
        fields = (
            "id",
            "post",
            "user",
            "comment",
            "created_at",
            "updated_at",
            "score",
        )


class PostReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = PostReport
        fields = ("id", "post", "user", "created_at", "updated_at")


class PostVoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = PostVote
        fields = ("id", "post", "user", "vote", "created_at", "updated_at")


class CommentVoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = CommentVote
        fields = ("id", "comment", "user", "vote", "created_at", "updated_at")


class AuthCustomTokenSerializer(serializers.Serializer):
    email = serializers.CharField()
    password = serializers.CharField()

    def validate(self, attrs):
        email = attrs.get("email")
        password = attrs.get("password")

        if email and password:
            if validate_email(email):
                user_request = get_object_or_404(
                    User,
                    email=email,
                )

                email = user_request.username

            user = authenticate(username=email, password=password)

            if user:
                if not user.is_active:
                    return "User account is disabled."
            else:
                return "Unable to log in with provided credentials."
        else:
            return 'Must include "email" and "password"'

        attrs["user"] = user
        return attrs


class PhoneLoginTokenSerializer(serializers.Serializer):
    code = serializers.CharField()
    phone = serializers.CharField()

    def validate(self, attrs):
        code = attrs.get("code")
        phone = attrs.get("phone")
        user = None
        if code:
            user = authenticate(code=code, phone=phone)
            if user:
                if not user.is_active:
                    return "User account is disabled."
            else:
                return "Unable to log in with provided credentials."
        else:
            return "Please enter a valid verification code."

        attrs["user"] = user
        return attrs
