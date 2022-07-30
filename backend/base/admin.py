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
    PostSave,
    BlockedUser,
)

from custom_auth.models import PhoneLoginCode


admin.site.register(User)
admin.site.register(Post)
admin.site.register(Comment)
admin.site.register(PostVote)
admin.site.register(CommentVote)
admin.site.register(PostReport)
admin.site.register(PhoneLoginCode)
admin.site.register(PostSave)
admin.site.register(BlockedUser)
# admin.site.register(DirectMessage)
