from django.urls import path
from . import views

urlpatterns = [
  path('getUser/<int:user_id>/', views.getUser, name='getUser'),
  path('getPost/<int:post_id>/', views.getPost, name='getPost'),
  path('getComment/<int:comment_id>/', views.getComment, name='getComment'),
  path('createPost/', views.createPost, name='createPost'),
  path('createComment/', views.createComment, name='createComment'),
  path('createPostReport/', views.createPostReport, name='createPostReport'),
  path('updatePost/', views.updatePost, name='updatePost'),
]