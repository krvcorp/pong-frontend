from django.contrib import admin
from .models import User, Post, Comment, PostVote, CommentVote, PostReport

admin.site.register(User)
admin.site.register(Post)
admin.site.register(Comment)
admin.site.register(PostVote)
admin.site.register(CommentVote)
admin.site.register(PostReport)