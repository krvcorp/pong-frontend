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

@api_view(['POST'])
def createPost(request):
    if request.method == 'POST':
        user = User.objects.get(id=request.data['user_id'])
        post = Post.objects.create(user=user, title=request.data['title'], image=request.data['image'])
        serializer = PostSerializer(post)
        return Response(serializer.data)

@api_view(['POST'])
def createComment(request):
    if request.method == 'POST':
        user = User.objects.get(id=request.data['user_id'])
        post = Post.objects.get(id=request.data['post_id'])
        comment = Comment.objects.create(user=user, post=post, comment=request.data['comment'])
        serializer = CommentSerializer(comment)
        return Response(serializer.data)

@api_view(['POST'])
def createPostReport(request):
    if request.method == 'POST':
        user = User.objects.get(id=request.data['user_id'])
        post = Post.objects.get(id=request.data['post_id'])
        post_report = PostReport.objects.create(user=user, post=post)
        serializer = PostReportSerializer(post_report)
        return Response(serializer.data)

@api_view(['PUT'])
def updatePost(request, post_id):
    if request.method == 'PUT':
        post = Post.objects.get(id=post_id)
        post.title = request.data['title'] if 'title' in request.data else post.title
        post.image = request.data['image'] if 'image' in request.data else post.image
        post.save()
        serializer = PostSerializer(post)
        return Response(serializer.data)