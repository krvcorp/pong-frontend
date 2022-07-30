from django.urls import path
from . import views

urlpatterns = [
    path("otp-start/", views.OTPStart.as_view(), name="otp-start"),
    path("otp-verify/", views.OTPVerify.as_view(), name="otp-verify"),
    path("verify-user/", views.VerifyUser.as_view(), name="verify-user"),
]
