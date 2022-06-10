from rest_framework import serializers
from base.models import User, Post, Comment, PostReport


class UserSerializer(serializers.ModelSerializer):
    posts = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()

    def get_posts(self, obj):
        return PostSerializer(obj.get_posts(), many=True).data

    def get_comments(self, obj):
        return CommentSerializer(obj.get_comments(), many=True).data

    class Meta:
        model = User
        fields = (
            "id",
            "username",
            # "name",
            "email",
            "profile_picture",
            "created_at",
            "updated_at",
            "posts",
            "comments",
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
