import uuid
from api.utils import code_generate
from django.db import models
from api.models import User
from django.utils import timezone


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
