from rest_framework import serializers
from base.models import User, Post, Comment, PostReport

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'first_name', 'last_name', 'email')

class PostSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = ('id', 'user', 'title', 'content', 'created_at', 'updated_at')

class CommentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comment
        fields = ('id', 'post', 'user', 'comment', 'created_at', 'updated_at')

class PostReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = PostReport
        fields = ('id', 'post', 'user', 'reason', 'created_at', 'updated_at')

