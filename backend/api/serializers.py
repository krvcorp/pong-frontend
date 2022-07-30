from asyncore import read
from datetime import datetime, timezone
from locale import normalize
from attr import attr
from rest_framework import serializers
from .utils import (
    name_file,
    code_generate,
    phone_validator,
    clean_phone_number,
    time_since_posted,
)
from .models import (
    BlockedUser,
    User,
    Post,
    Comment,
    PostReport,
    CommentVote,
    PostVote,
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
    saved_posts = serializers.SerializerMethodField(read_only=True)

    def get_posts(self, obj):
        posts = Post.objects.filter(user=obj).order_by("-created_at")
        return PostSerializer(posts, many=True).data

    def get_comments(self, obj):
        return CommentSerializer(obj.get_comments(), many=True).data

    def get_saved_posts(self, obj):
        return PostSerializer(obj.get_saved_posts(), many=True).data

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
            "saved_posts",
        )


class UserSerializerLeaderboard(serializers.ModelSerializer):
    score = serializers.SerializerMethodField(read_only=True)
    place = serializers.SerializerMethodField(read_only=True)

    def get_score(self, obj):
        return obj.total_karma

    def get_place(self, obj):
        return "1"

    class Meta:
        model = User
        fields = ("score", "place")


class UserSerializerProfile(serializers.ModelSerializer):
    posts = serializers.SerializerMethodField(read_only=True)
    comments = serializers.SerializerMethodField(read_only=True)
    upvoted_posts = serializers.SerializerMethodField(read_only=True)
    saved_posts = serializers.SerializerMethodField(read_only=True)

    def get_posts(self, obj):
        return PostSerializer(obj.get_posts(), many=True).data

    def get_comments(self, obj):
        return CommentSerializer(obj.get_comments(), many=True).data

    def get_upvoted_posts(self, obj):
        return PostSerializer(obj.get_upvoted_posts(), many=True).data

    def get_saved_posts(self, obj):
        return PostSerializer(obj.get_saved_posts(), many=True).data

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
            "saved_posts",
        )


class PostSerializer(serializers.ModelSerializer):
    num_comments = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()
    score = serializers.SerializerMethodField()
    time_since_posted = serializers.SerializerMethodField()
    vote_status = serializers.SerializerMethodField()
    saved = serializers.SerializerMethodField()
    blocked = serializers.SerializerMethodField()
    num_upvotes = serializers.SerializerMethodField()
    num_downvotes = serializers.SerializerMethodField()

    def get_num_comments(self, obj):
        return obj.num_comments()

    def get_score(self, obj):
        return obj.score(user=self.context["request"].user)

    def get_num_upvotes(self, obj):
        return obj.num_upvotes()

    def get_num_downvotes(self, obj):
        return obj.num_downvotes()

    def get_comments(self, obj):
        comments = obj.get_comments()
        comments = sorted(comments, key=lambda x: x.score, reverse=True)
        return CommentSerializer(comments, many=True).data

    def get_vote_status(self, obj):
        return self.context["request"].user.vote_status_post(obj)

    def get_saved(self, obj):
        return PostSave.objects.filter(
            post=obj, user=self.context["request"].user
        ).exists()

    def get_blocked(self, obj):
        return self.context["request"].user.check_if_blocked(obj.user)

    def get_time_since_posted(self, obj):
        return time_since_posted(obj)

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
            "vote_status",
            "saved",
            "flagged",
            "blocked",
            "num_upvotes",
            "num_downvotes",
        )


class CommentSerializer(serializers.ModelSerializer):
    score = serializers.SerializerMethodField()
    time_since_posted = serializers.SerializerMethodField()

    def get_score(self, obj):
        return obj.score

    def get_time_since_posted(self, obj):
        return time_since_posted(obj)

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


class PostCommentsSerializer(serializers.ModelSerializer):
    score = serializers.SerializerMethodField()
    time_since_posted = serializers.SerializerMethodField()

    def get_score(self, obj):
        return obj.score

    def get_time_since_posted(self, obj):
        return time_since_posted(obj)

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
            "children",
            "number_on_post",
        )

    def get_fields(self):
        fields = super().get_fields()
        fields["children"] = PostCommentsSerializer(many=True)
        return fields


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
        read_only_fields = ("comment", "user")
        extra_kwargs = {
            "vote": {"required": False},
        }

    def create(self, validated_data):
        user = self.context["request"].user
        vote = self.context["request"].data["vote"]
        comment = Comment.objects.get(id=self.context["request"].data["comment_id"])
        if CommentVote.objects.filter(comment=comment, user=user).exists():
            raise ValidationError("You have already voted on this comment")
        return CommentVote.objects.create(comment=comment, user=user, vote=vote)


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
