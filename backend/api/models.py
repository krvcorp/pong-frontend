import uuid
from .utils import name_file, phone_validator, code_generate
from datetime import date
from typing_extensions import Required
from django.db import models
from django.contrib.auth.models import (
    AbstractUser,
    UserManager,
    AbstractBaseUser,
    PermissionsMixin,
)
from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone
from django.core.validators import RegexValidator
from rest_framework.authtoken.models import Token


class UserManager(UserManager):
    def _create_user(self, phone, password, **extra_fields):
        """
        Create and save a User with the provided phone and password.
        """
        if len(phone) == 0:
            raise ValueError("Users must have a phone number.")
        phone = "".join(filter(lambda x: x.isdigit(), phone))
        if len(phone) != 10:
            raise ValueError("Users must have a valid phone number.")

        user = self.model(phone=phone, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_user(self, phone=None, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", False)
        extra_fields.setdefault("is_superuser", False)
        return self._create_user(phone, password, **extra_fields)

    # create staff user

    def create_superuser(self, phone, password, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")

        return self._create_user(phone, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(null=True, blank=True, unique=True)
    phone = models.CharField(max_length=20, unique=True)
    name = models.CharField(max_length=200, blank=True, default="")
    timeout = models.DateTimeField(blank=True, null=True)
    has_been_verified = models.BooleanField(default=False)
    banned = models.BooleanField(default=False)
    school_attending = models.ForeignKey(
        "api.School", on_delete=models.SET_NULL, null=True, blank=True
    )
    chat_notifications = models.BooleanField(default=True)
    trending_post_notifications = models.BooleanField(default=True)
    activity_notifications = models.BooleanField(default=True)

    # Django Required Fields
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)
    last_login = models.DateTimeField(blank=True, null=True)
    date_joined = models.DateTimeField(default=timezone.now)

    objects = UserManager()

    USERNAME_FIELD = "phone"
    EMAIL_FIELD = "phone"
    REQUIRED_FIELDS = []

    class Meta:
        verbose_name = "User"
        verbose_name_plural = "Users"

    @property
    def in_timeout(self):
        if self.timeout is None:
            return False
        return self.timeout > timezone.now()

    @property
    def is_verified(self):
        return self.has_been_verified

    @property
    def total_karma(self):
        return self.total_post_score() + self.total_comment_score()

    @property
    def post_karma(self):
        return self.total_post_score()

    @property
    def comment_karma(self):
        return self.total_comment_score()

    def verify(self):
        self.has_been_verified = True
        self.save()

    def get_full_name(self):
        return self.name

    def get_short_name(self):
        if self.name is not None:
            return self.name
        else:
            return ""

    def total_post_score(self):
        relevant_votes = PostVote.objects.filter(post__user=self)
        total = 0
        for vote in relevant_votes:
            total += vote.vote
        return total

    def total_comment_score(self):
        relevant_votes = CommentVote.objects.filter(comment__user=self)
        total = 0
        for vote in relevant_votes:
            total += vote.vote
        return total

    def get_posts(self):
        return Post.objects.filter(user=self)

    def get_comments(self):
        return Comment.objects.filter(user=self)

    def get_conversations(self):
        return DirectConversation.objects.filter(
            user1=self
        ) | DirectConversation.objects.filter(user2=self)

    def get_upvoted_posts(self):
        postvoteobjects = PostVote.objects.filter(user=self, vote=1)
        posts = [
            postvoteobject.post
            for postvoteobject in postvoteobjects
            if postvoteobject.post
        ]
        return posts

    def __str__(self):
        return self.phone

    @receiver(post_save, sender=settings.AUTH_USER_MODEL)
    def create_auth_token(sender, instance=None, created=False, **kwargs):
        # if user has_been_verified is True and the user doesn't already have a token, create one
        if (
            instance.has_been_verified
            and not Token.objects.filter(user=instance).exists()
        ):
            Token.objects.create(user=instance)


class PhoneLoginCode(models.Model):
    uuid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    code = models.CharField(max_length=6, default=code_generate)
    created_at = models.DateTimeField(default=timezone.now)
    used = models.BooleanField(default=False)

    @property
    def is_expired(self):
        return self.created_at + timezone.timedelta(minutes=30) < timezone.now()

    @property
    def is_used(self):
        return self.used

    def use(self):
        self.used = True
        self.save()

    def __str__(self):
        return self.code


class Post(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)

    title = models.TextField(default="")
    image = models.ImageField(upload_to="images/", blank=True)
    poll = models.ForeignKey(
        "api.Poll", on_delete=models.SET_NULL, null=True, blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Post"
        verbose_name_plural = "Posts"
        # constraint that ensures that a post does not have both a poll and an image
        constraints = [
            models.CheckConstraint(
                check=models.Q(poll=None) | models.Q(image=None),
                name="post_poll_or_image_check",
            )
        ]

    @property
    def score(self):
        total = 0
        for vote in PostVote.objects.all():
            if vote.post == self:
                total += vote.vote
        return total

    def get_comments(self):
        return Comment.objects.filter(post=self)

    def num_comments(self):
        return self.get_comments().count()

    def get_reports(self):
        return PostReport.objects.filter(post=self)

    def num_reports(self):
        return self.get_reports().count()

    def __str__(self):
        return str(self.id)


class Poll(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    title = models.TextField(default="")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def get_options(self):
        return PollOption.objects.filter(poll=self)

    def num_options(self):
        return self.get_options().count()

    def get_votes(self):
        return PollVote.objects.filter(poll=self)

    def num_votes(self):
        return self.get_votes().count()

    def __str__(self):
        return str(self.id)


class PollOption(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)
    title = models.TextField(default="")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def get_votes(self):
        return PollVote.objects.filter(option=self)

    def num_votes(self):
        return self.get_votes().count()

    def __str__(self):
        return str(self.id)


class PollVote(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)
    option = models.ForeignKey(PollOption, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return str(self.id)


class Comment(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    post = models.ForeignKey(Post, on_delete=models.SET_NULL, null=True)
    comment = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    @property
    def score(self):
        total = 0
        for vote in CommentVote.objects.all():
            if vote.comment == self:
                total += vote.vote
        return total

    def has_voted(self, user):
        return CommentVote.objects.filter(comment=self, user=user).count() > 0

    def __str__(self):
        return str(self.id) + " " + self.comment


class PostVote(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    post = models.ForeignKey(Post, on_delete=models.SET_NULL, null=True)
    vote = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ("user", "post")

    def __str__(self):
        return str(self.id) + " " + str(self.vote)


# a class for a user saving a post
class PostSave(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    post = models.ForeignKey(Post, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ("user", "post")

    def __str__(self):
        return str(self.id)


class CommentVote(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    comment = models.ForeignKey(Comment, on_delete=models.SET_NULL, null=True)
    vote = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ("user", "comment")

    def __str__(self):
        return str(self.id) + " " + str(self.vote)


class PostReport(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    post = models.ForeignKey(Post, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ("user", "post")

    def __str__(self):
        return str(self.id) + " " + str(self.user)


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

    def get_messages(self):
        return DirectMessage.objects.filter(conversation=self).order_by("created_at")

    def get_most_recent_message(self):
        return self.get_messages().last()

    def __str__(self):
        return str(self.id)


class DirectMessage(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation = models.ForeignKey(
        DirectConversation, on_delete=models.SET_NULL, null=True
    )
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return str(self.message)


class School(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    domain = models.CharField(max_length=100, unique=True)
    description = models.TextField()
    creator = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

    def get_members(self):
        return User.objects.filter(school=self)


class BlockedUser(models.Model):
    blocker = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, related_name="blocker"
    )
    blockee = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, related_name="blockee"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    unique_together = ("blocker", "blockee")

    def __str__(self):
        return str(self.blocker) + " " + str(self.blockee)
