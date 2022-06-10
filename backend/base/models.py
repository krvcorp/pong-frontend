from datetime import date
from django.db import models
from django.contrib.auth.models import (
    AbstractUser,
    BaseUserManager,
    AbstractBaseUser,
    PermissionsMixin,
)
from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver
from rest_framework.authtoken.models import Token


def get_default_avatar():
    return "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y"


# class CustomAccountManager(BaseUserManager):
#     def create_user(self, email, username, password, **extra_fields):
#         if not email:
#             raise ValueError("Users must have an email address")


# class NewUser(AbstractBaseUser, PermissionsMixin):
#     email = models.EmailField(unique=True)
#     username = models.CharField(max_length=255, unique=True)
#     name = models.CharField(max_length=255, blank=True)
#     is_staff = models.BooleanField(default=False)
#     is_active = models.BooleanField(default=True)

#     USERNAME_FIELD = "email"
#     REQUIRED_FIELDS = ["username"]


class User(AbstractUser):
    name = models.CharField(max_length=50)
    email = models.EmailField(unique=True, null=True)
    phone = models.CharField(max_length=50)
    address = models.CharField(max_length=250)
    city = models.CharField(max_length=50)
    state = models.CharField(max_length=50)
    zipcode = models.CharField(max_length=50)
    country = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    password = models.CharField(max_length=50)
    profile_picture = models.ImageField(upload_to="profile_pictures", blank=True)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username", "password"]

    # a function named total_score which computes the sum of the votes of each
    # post and comment a user has made

    # a function named total_score which computes the sum of the votes of each post
    def total_score(self):
        return self.total_post_score() + self.total_comment_score()

    def total_post_score(self):
        total = 0
        for vote in PostVote.objects.all():
            if vote.post.user == self:
                total += vote.vote
        return total

    def total_comment_score(self):
        total = 0
        for vote in CommentVote.objects.all():
            if vote.comment.user == self:
                total += vote.vote
        return total

    # a function named get_posts which returns all the posts a user has made
    # TODO: Maintain a set of posts associated with user id
    def get_posts(self):
        return Post.objects.filter(user=self)

    # a function named get_comments which returns all the comments a user has made
    # TODO: Maintain a set of comments associated with user id
    def get_comments(self):
        return Comment.objects.filter(user=self)

    # a function named get_conversations which returns all the conversations a user has made
    def get_conversations(self):
        return DirectConversation.objects.filter(
            user1=self
        ) | DirectConversation.objects.filter(user2=self)

    # a function named get_upvoted_posts which shows all the posts a user has upvoted
    def get_upvoted_posts(self):
        postvoteobjects = PostVote.objects.filter(user=self, vote=1)
        posts = [
            postvoteobject.post
            for postvoteobject in postvoteobjects
            if postvoteobject.post
        ]
        return posts

    def __str__(self):
        return self.name


# @receiver(post_save, sender=settings.AUTH_USER_MODEL)
# def create_auth_token(sender, instance=None, created=False, **kwargs):
#     if created:
#         Token.objects.create(user=instance)


# Class for the posts a user can make
class Post(models.Model):
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    title = models.TextField()
    image = models.ImageField(upload_to="images/", blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # a function named total_score which computes the sum of the votes of each post
    def total_score(self):
        total = 0
        for vote in PostVote.objects.all():
            if vote.post == self:
                total += vote.vote
        return total

    # a function named get_comments which returns all the comments a post has made
    def get_comments(self):
        return Comment.objects.filter(post=self)

    def num_comments(self):
        return self.get_comments().count()

    def get_reports(self):
        return PostReport.objects.filter(post=self)

    def num_reports(self):
        return self.get_reports().count()

    def __str__(self):
        return str(self.id) + " " + self.title


# Class for the comments that go on a post
class Comment(models.Model):
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    post = models.ForeignKey(Post, on_delete=models.SET_NULL, null=True)
    comment = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def total_score(self):
        total = 0
        for vote in CommentVote.objects.all():
            if vote.comment == self:
                total += vote.vote
        return total

    # function to check if the inputted user has voted for this comment
    def has_voted(self, user):
        return CommentVote.objects.filter(comment=self, user=user).count() > 0

    def __str__(self):
        return str(self.id) + " " + self.comment


# Class for the votes for a post
class PostVote(models.Model):
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    post = models.ForeignKey(Post, on_delete=models.SET_NULL, null=True)
    vote = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return str(self.id) + " " + str(self.vote)


# Class for the votes for a comment
class CommentVote(models.Model):
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    comment = models.ForeignKey(Comment, on_delete=models.SET_NULL, null=True)
    vote = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return str(self.id) + " " + str(self.vote)


# Class for user reports of spam on a post
class PostReport(models.Model):
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    post = models.ForeignKey(Post, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return str(self.id) + " " + str(self.user)


# Class for direct message conversations between users
class DirectConversation(models.Model):
    # User1 is the initiator of the conversation
    user1 = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, related_name="user1"
    )
    user2 = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, related_name="user2"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # a function named get_messages which returns all the messages in a conversation sorted by date
    def get_messages(self):
        return DirectMessage.objects.filter(conversation=self).order_by("created_at")

    # a function named get_most_recent_message which returns the most recent message in a conversation
    def get_most_recent_message(self):
        return self.get_messages().last()

    def __str__(self):
        return str(self.id)


# Class for messages in a direct conversation
class DirectMessage(models.Model):
    conversation = models.ForeignKey(
        DirectConversation, on_delete=models.SET_NULL, null=True
    )
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return str(self.message)


class ClassGroup(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    creator = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

    def get_members(self):
        pass
