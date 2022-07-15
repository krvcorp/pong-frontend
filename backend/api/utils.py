import random
from django.core.validators import RegexValidator


def name_file(instance, filename):
    return "/".join(["profile_pictures", str(instance.id), filename])


def code_generate():
    return "".join(random.choices("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", k=6))


phone_validator = RegexValidator(
    r"^(\+?\d{0,4})?\s?-?\s?(\(?\d{3}\)?)\s?-?\s?(\(?\d{3}\)?)\s?-?\s?(\(?\d{4}\)?)?$",
    "The phone number provided is invalid",
)


def clean_phone_number(phone_number):
    return "".join(filter(lambda x: x.isdigit(), phone_number))
