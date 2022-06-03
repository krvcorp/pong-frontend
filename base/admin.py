from django.contrib import admin
from .models import User, Company, Message

admin.site.register(User)
# admin.site.register(Company)
admin.site.register(Message)
