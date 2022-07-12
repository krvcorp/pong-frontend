from django.contrib.auth.backends import BaseBackend
from .models import User, PhoneLoginCode


class PhoneLoginBackend(BaseBackend):
    def authenticate(self, request, code=None, phone=None):
        try:
            user = User.objects.get(phone=phone)
            code_obj = PhoneLoginCode.objects.get(user=user, code=code)
            if code_obj.is_expired:
                return None
            if code_obj.code == code:
                code_obj.use()
                return user
        except:
            return None

    def get_user(self, user_id):
        try:
            return User.objects.get(id=user_id)
        except User.DoesNotExist:
            return None
