from django.forms import ModelForm
from .models import Creator


class CreatorCreationForm(ModelForm):
    class Meta:
        model = Creator
        fields = ["name", "email", "password"]
