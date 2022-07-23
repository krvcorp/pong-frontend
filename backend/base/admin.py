from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
import sys

sys.path.append("..")
from api.models import (
    User,
    Post,
    Comment,
    PostVote,
    CommentVote,
    PostReport,
    DirectConversation,
    DirectMessage,
    PhoneLoginCode,
    PostSave,
)


admin.site.register(User)
admin.site.register(Post)
admin.site.register(Comment)
admin.site.register(PostVote)
admin.site.register(CommentVote)
admin.site.register(PostReport)
admin.site.register(DirectConversation)
admin.site.register(DirectMessage)
admin.site.register(PhoneLoginCode)
admin.site.register(PostSave)
# admin.site.register(DirectMessage)
