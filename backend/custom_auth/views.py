import datetime
import re
from django.http import JsonResponse
from api.models import (
    User,
    School,
    Token,
)
from .models import PhoneLoginCode
from api.serializers import UserSerializer
from rest_framework import status
from rest_framework.views import APIView
from twilio.rest import Client
from google.oauth2 import id_token
from google.auth.transport import requests


class OTPStart(APIView):
    """
    This method is used to start the OTP process. It creates a new OTP object and sends a text message to the user, based on the phone number in the request.
    """

    def post(self, request):
        context = {}
        context["new_user"] = True  # By default, assume the user is new

        phone = request.data["phone"]
        phone = "".join(filter(lambda x: x.isdigit(), phone))
        user_phone_numbers = User.objects.values_list("phone", flat=True)
        if phone in user_phone_numbers:
            context["new_user"] = False

        if len(phone) != 10:
            return JsonResponse(
                {"error": "number_invalid"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        # Lookup for VoIP number
        # phone_number_carrier = client.lookups.phone_numbers(phone).fetch(type="carrier")
        # if phone_number_carrier.carrier["type"] != "mobile":
        #     return JsonResponse(
        #         {"error": "number_voip"},
        #         status=status.HTTP_400_BAD_REQUEST
        #     )

        user = None
        if context["new_user"]:
            user = User.objects.create_user(phone)
        else:
            user = User.objects.get(phone=phone)
        code = PhoneLoginCode.objects.filter(user=user).order_by("-created_at")
        if code.count() > 0:
            code = code[0]
            time_elapsed = (
                datetime.datetime.now(datetime.timezone.utc) - code.created_at
            )
            if time_elapsed.total_seconds() < 30:
                return JsonResponse(
                    {"error": "code_already_sent"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        code = PhoneLoginCode.objects.create(user=user)

        TWILIO_ACCOUNT_SID = "AC5e7be9e9a0d92520bc1b79a9e4ce7963"
        TWILIO_SECRET_KEY = "b733808ab5bebcc9eccde14f9dcf56dc"

        client = Client(TWILIO_ACCOUNT_SID, TWILIO_SECRET_KEY)

        # Commented out for saving money, check in admin panel if you want to use this
        # message = client.messages.create(
        #     body=code.code,
        #     to=request.data["phone"],
        #     from_="+19283623318",
        # )

        context["phone"] = phone
        return JsonResponse(context)


class OTPVerify(APIView):
    """
    This method is used to verify the OTP code. It checks if the code is correct and unexpired and if it is, then checks if the user has been verified. If the user has been verified, then it returns a token. If the user has not been verified, then it returns 'code_incorrect' as a part of the context. If the code is incorrect or expired, then it returns the respective error message as a part of the context.
    """

    def post(self, request):
        context = {}
        phone = request.data["phone"]
        phone = "".join(filter(lambda x: x.isdigit(), phone))
        user = User.objects.get(phone=phone)
        phone_login_code = PhoneLoginCode.objects.filter(user=user).order_by(
            "-created_at"
        )[0]
        if phone_login_code.code == request.data["code"]:
            if not phone_login_code.is_expired and not phone_login_code.is_used:
                phone_login_code.use()
                if user.has_been_verified:
                    context["token"] = Token.objects.get(user=user).key
                    context["user_id"] = user.id
                else:
                    context["email_unverified"] = True
            else:
                context["code_expired"] = True
        else:
            context["code_incorrect"] = True
        return JsonResponse(context)


class VerifyUser(APIView):
    def post(self, request):
        try:
            # Specify the CLIENT_ID of the app that accesses the backend:
            idinfo = id_token.verify_oauth2_token(
                request.data["id_token"],
                requests.Request(),
                "983201170682-kttqq1l89i4fpgk15fud1u1hf192fq1q.apps.googleusercontent.com",
                # needs to go into environment variable
            )

            phone = request.data["phone"]
            phone = "".join(filter(lambda x: x.isdigit(), phone))

            # ID token is valid. Get the user's Google Account ID from the decoded token.
            context = {}

            domain = re.search("@[\w.]+", idinfo["email"])
            school, _ = School.objects.get_or_create(domain=domain)
            user = User.objects.get(phone=phone)

            user.has_been_verified = True
            user.school = school
            user.email = idinfo["email"]
            user.save()

            context["token"] = Token.objects.get(user=user).key
            context["user"] = UserSerializer(user).data
            return JsonResponse(context)

        except ValueError:
            # Invalid token
            pass
