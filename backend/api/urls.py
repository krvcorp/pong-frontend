from django.urls import path
from . import views

urlpatterns = [
  path('getUser/<int:user_id>/', views.getUser, name='getUser'),
  path('getPost/<int:post_id>/', views.getPost, name='getPost'),
  path('getComment/<int:comment_id>/', views.getComment, name='getComment'),
]