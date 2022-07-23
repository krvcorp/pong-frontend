from asyncore import read
from datetime import datetime, timezone
from locale import normalize
from attr import attr
from rest_framework import serializers
from .models import (
    User,
    Post,
    Comment,
    PostReport,
    CommentVote,
    PostVote,
    DirectConversation,
    DirectMessage,
    Poll,
    PollOption,
    PollVote,
    PostSave,
)
from rest_framework.authtoken.models import Token
from django.core.validators import validate_email
from django.core.exceptions import ValidationError
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate


class UserSerializer(serializers.ModelSerializer):
    posts = serializers.SerializerMethodField(read_only=True)
    comments = serializers.SerializerMethodField(read_only=True)

    def get_posts(self, obj):
        return PostSerializer(obj.get_posts(), many=True).data

    def get_comments(self, obj):
        return CommentSerializer(obj.get_comments(), many=True).data

    class Meta:
        model = User
        fields = (
            "id",
            "email",
            "posts",
            "comments",
            "in_timeout",
            "phone",
            "comment_karma",
            "post_karma",
            "total_karma",
        )


# class UserSerializerWithoutTimeout(serializers.ModelSerializer):
#     posts = serializers.SerializerMethodField(read_only=True)
#     comments = serializers.SerializerMethodField(read_only=True)

#     def get_posts(self, obj):
#         return PostSerializer(obj.get_posts(), many=True).data

#     def get_comments(self, obj):
#         return CommentSerializer(obj.get_comments(), many=True).data

#     class Meta:
#         model = User
#         fields = ("id", "email", "posts", "comments", "phone")


class UserSerializerLeaderboard(serializers.ModelSerializer):
    score = serializers.SerializerMethodField(read_only=True)

    def get_score(self, obj):
        return obj.total_score()

    class Meta:
        model = User
        fields = ("id", "score")


class UserSerializerProfile(serializers.ModelSerializer):
    posts = serializers.SerializerMethodField(read_only=True)
    comments = serializers.SerializerMethodField(read_only=True)
    upvoted_posts = serializers.SerializerMethodField(read_only=True)

    def get_posts(self, obj):
        return PostSerializer(obj.get_posts(), many=True).data

    def get_comments(self, obj):
        return CommentSerializer(obj.get_comments(), many=True).data

    def get_upvoted_posts(self, obj):
        return PostSerializer(obj.get_upvoted_posts(), many=True).data

    class Meta:
        model = User
        fields = (
            "id",
            "email",
            "posts",
            "comments",
            "in_timeout",
            "phone",
            "comment_karma",
            "post_karma",
            "total_karma",
            "upvoted_posts",
        )


class PostSerializer(serializers.ModelSerializer):
    num_comments = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()
    score = serializers.SerializerMethodField()
    time_since_posted = serializers.SerializerMethodField()

    def get_num_comments(self, obj):
        return obj.num_comments()

    def get_score(self, obj):
        return obj.score

    def get_comments(self, obj):
        comments = obj.get_comments()
        comments = sorted(comments, key=lambda x: x.score, reverse=True)
        return CommentSerializer(comments, many=True).data

    def get_time_since_posted(self, obj):
        time = datetime.now(timezone.utc) - obj.created_at

        seconds = time.total_seconds()
        minutes = seconds // 60
        hours = minutes // 60
        days = hours // 24
        weeks = days // 7
        months = weeks // 4
        years = months // 12

        years = round(years)
        months = round(months % 12)
        weeks = round(weeks % 4)
        days = round(days % 7)
        hours = round(hours % 24)
        minutes = round(minutes % 60)
        seconds = round(seconds % 60)

        if years > 0:
            return str(years) + "y"
        if months > 0:
            return str(months) + "m"
        if weeks > 0:
            return str(weeks) + "w"
        if days > 0:
            return str(days) + "d"
        if hours > 0:
            return str(hours) + "h"
        if minutes > 0:
            return str(minutes) + "m"
        if seconds > 0:
            return str(seconds) + "s"
        return "0s"

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
            "time_since_posted",
        )


class CommentSerializer(serializers.ModelSerializer):
    score = serializers.SerializerMethodField()
    time_since_posted = serializers.SerializerMethodField()

    def get_score(self, obj):
        return obj.score

    def get_time_since_posted(self, obj):
        time = datetime.now(timezone.utc) - obj.created_at

        seconds = time.total_seconds()
        minutes = seconds // 60
        hours = minutes // 60
        days = hours // 24
        weeks = days // 7
        months = weeks // 4
        years = months // 12

        years = round(years)
        months = round(months % 12)
        weeks = round(weeks % 4)
        days = round(days % 7)
        hours = round(hours % 24)
        minutes = round(minutes % 60)
        seconds = round(seconds % 60)

        if years > 0:
            return str(years) + "y"
        if months > 0:
            return str(months) + "m"
        if weeks > 0:
            return str(weeks) + "w"
        if days > 0:
            return str(days) + "d"
        if hours > 0:
            return str(hours) + "h"
        if minutes > 0:
            return str(minutes) + "m"
        if seconds > 0:
            return str(seconds) + "s"
        return "0s"

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
            "time_since_posted",
        )


class PostReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = PostReport
        fields = ("id", "post", "user", "created_at", "updated_at")


class PostVoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = PostVote
        fields = ("id", "post", "user", "vote", "created_at", "updated_at")
        read_only_fields = ("post", "user")
        extra_kwargs = {
            "vote": {"required": False},
        }

    def create(self, validated_data):
        user = self.context["request"].user
        vote = self.context["request"].data["vote"]
        post = Post.objects.get(id=self.context["request"].data["post_id"])
        if PostVote.objects.filter(post=post, user=user).exists():
            raise ValidationError("You have already voted on this post")
        return PostVote.objects.create(post=post, user=user, vote=vote)


class CommentVoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = CommentVote
        fields = ("id", "comment", "user", "vote", "created_at", "updated_at")
        read_only_fields = ("post", "user")
        extra_kwargs = {
            "vote": {"required": False},
        }

    def create(self, validated_data):
        user = self.context["request"].user
        vote = self.context["request"].data["vote"]
        post = Post.objects.get(id=self.context["request"].data["post_id"])
        if CommentVote.objects.filter(post=post, user=user).exists():
            raise ValidationError("You have already voted on this comment")
        return CommentVote.objects.create(post=post, user=user, vote=vote)


class DirectMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = DirectMessage
        fields = (
            "id",
            "sender",
            "receiver",
            "message",
            "created_at",
            "updated_at",
        )


class PollSerializer(serializers.ModelSerializer):
    options = serializers.SerializerMethodField()

    def get_options(self, obj):
        return PollOptionSerializer(obj.get_options(), many=True).data

    class Meta:
        model = Poll
        fields = ("id", "user", "title", "created_at", "updated_at", "options")


class PollOptionSerializer(serializers.ModelSerializer):
    votes = serializers.SerializerMethodField()

    def get_votes(self, obj):
        return obj.num_votes()

    class Meta:
        model = PollOption
        fields = ("id", "title", "votes")


class PostSaveSerializer(serializers.ModelSerializer):
    class Meta:
        model = PostSave
        fields = ("id", "post", "user", "created_at", "updated_at")
        read_only_fields = ("post", "user")

    def create(self, validated_data):
        user = self.context["request"].user
        post = Post.objects.get(id=self.context["request"].data["post_id"])
        if PostSave.objects.filter(post=post, user=user).exists():
            raise ValidationError("You have already saved this post")
        return PostSave.objects.create(post=post, user=user)


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
