import random
from datetime import datetime, timezone
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


def time_since_posted(obj):
    time = datetime.now(timezone.utc) - obj.created_at

    seconds = time.total_seconds()
    minutes = seconds // 60
    hours = minutes // 60
    days = hours // 24
    weeks = days // 7
    months = weeks // 4
    years = months // 12

    years = round(years)
    months = round(months % 12)
    weeks = round(weeks % 4)
    days = round(days % 7)
    hours = round(hours % 24)
    minutes = round(minutes % 60)
    seconds = round(seconds % 60)

    if years > 0:
        return str(years) + "y"
    if months > 0:
        return str(months) + "m"
    if weeks > 0:
        return str(weeks) + "w"
    if days > 0:
        return str(days) + "d"
    if hours > 0:
        return str(hours) + "h"
    if minutes > 0:
        return str(minutes) + "m"
    if seconds > 0:
        return str(seconds) + "s"
    return "0s"
