# Generated by Django 3.2 on 2022-07-03 19:47

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('base', '0005_auto_20220703_0334'),
    ]

    operations = [
        migrations.AddField(
            model_name='phonelogincode',
            name='used',
            field=models.BooleanField(default=False),
        ),
    ]
