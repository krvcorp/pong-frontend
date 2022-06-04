from django.db import models
from django.contrib.auth.models import AbstractUser


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
        print("Total post score: " + str(total))
        return total

    def total_comment_score(self):
        total = 0
        for vote in CommentVote.objects.all():
            if vote.comment.user == self:
                total += vote.vote
        print("Total comment score: " + str(total))
        return total

    # a function named get_posts which returns all the posts a user has made
    def get_posts(self):
        return Post.objects.filter(user=self)
    
    # a function named get_comments which returns all the comments a user has made
    def get_comments(self):
        return Comment.objects.filter(user=self)

    def __str__(self):
        return str(self.id) + " " + self.email


# Class for the posts a user can make
class Post(models.Model):
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    title = models.TextField()
    image = models.ImageField(upload_to='images/', blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # TODO: Fix vote summation, something's not working but I'm way 
    # too fucking lazy to figure out what it is
    
    # a function named total_score which computes the sum of the votes of each post
    def total_score(self):
        total = 0
        for vote in PostVote.objects.all():
            if vote.post == self:
                total += vote.vote
        return total

    def __str__(self):
        return str(self.id) + " " + self.title

# Class for the comments that go on a post
class Comment(models.Model):
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    post = models.ForeignKey(Post, on_delete=models.SET_NULL, null=True)
    comment = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # a function named total_score which computes the sum of the votes of each comment
    def total_score(self):
        total = 0
        # get all votes and iterate through them summing their votes
        for vote in CommentVote.objects.all():
            if vote.comment == self:
                total += vote.vote
        return total

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

