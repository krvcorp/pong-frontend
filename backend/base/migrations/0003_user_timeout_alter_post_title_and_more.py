# Generated by Django 4.0.4 on 2022-07-02 20:05

import base.utils
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('base', '0002_user_profile_picture'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='timeout',
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='post',
            name='title',
            field=models.TextField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='user',
            name='profile_picture',
            field=models.ImageField(blank=True, null=True, upload_to=base.utils.name_file),
        ),
    ]
