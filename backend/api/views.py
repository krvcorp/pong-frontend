from rest_framework.response import Response
from rest_framework.decorators import api_view
from base.models import User, Post, Comment, PostReport, CommentVote, PostVote
from .serializers import UserSerializer, PostSerializer, CommentSerializer, PostReportSerializer

@api_view(['GET'])
def getUser(request, user_id):
    if request.method == 'GET':
        user = User.objects.get(id=user_id)
        serializer = UserSerializer(user)
        return Response(serializer.data)

@api_view(['GET'])
def getPost(request, post_id):
    if request.method == 'GET':
        post = Post.objects.get(id=post_id)
        serializer = PostSerializer(post)
        return Response(serializer.data)

@api_view(['GET'])
def getComment(request, comment_id):
    if request.method == 'GET':
        comment = Comment.objects.get(id=comment_id)
        serializer = CommentSerializer(comment)
        return Response(serializer.data)


