from rest_framework import serializers
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
from rest_framework.authtoken.models import Token
from django.core.validators import validate_email
from django.core.exceptions import ValidationError
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate


class UserSerializer(serializers.ModelSerializer):
    posts = serializers.SerializerMethodField(read_only=True)
    comments = serializers.SerializerMethodField(read_only=True)
    token = serializers.SerializerMethodField(read_only=True)

    def get_posts(self, obj):
        return PostSerializer(obj.get_posts(), many=True).data

    def get_comments(self, obj):
        return CommentSerializer(obj.get_comments(), many=True).data

    def get_token(self, obj):
        return Token.objects.get(user=obj).key

    class Meta:
        model = User
        fields = (
            "id",
            "email",
            "profile_picture",
            "posts",
            "comments",
            "token",
        )


class PostSerializer(serializers.ModelSerializer):
    num_comments = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()
    total_score = serializers.SerializerMethodField()

    def get_num_comments(self, obj):
        return obj.num_comments()

    def get_total_score(self, obj):
        return obj.total_score()

    def get_comments(self, obj):
        return CommentSerializer(obj.get_comments(), many=True).data

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
            "total_score",
        )


class CommentSerializer(serializers.ModelSerializer):
    total_score = serializers.SerializerMethodField()

    def get_total_score(self, obj):
        return obj.total_score()

    class Meta:
        model = Comment
        fields = (
            "id",
            "post",
            "user",
            "comment",
            "created_at",
            "updated_at",
            "total_score",
        )


class PostReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = PostReport
        fields = ("id", "post", "user", "reason", "created_at", "updated_at")


class PostVoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = PostVote
        fields = ("id", "post", "user", "vote", "created_at", "updated_at")


class CommentVoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = CommentVote
        fields = ("id", "comment", "user", "vote", "created_at", "updated_at")


class AuthCustomTokenSerializer(serializers.Serializer):
    email_or_username = serializers.CharField()
    password = serializers.CharField()

    def validate(self, attrs):
        print(attrs)
        email_or_username = attrs.get("email_or_username")
        password = attrs.get("password")

        if email_or_username and password:
            if validate_email(email_or_username):
                user_request = get_object_or_404(
                    User,
                    email=email_or_username,
                )

                email_or_username = user_request.username

            user = authenticate(username=email_or_username, password=password)

            if user:
                if not user.is_active:
                    msg = "User account is disabled."
                    return msg
            else:
                msg = "Unable to log in with provided credentials."
                return msg
        else:
            msg = 'Must include "email or username" and "password"'
            return msg

        attrs["user"] = user
        return attrs
