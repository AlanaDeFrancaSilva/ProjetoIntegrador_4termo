from rest_framework import serializers
from ..models import Environment
from .custom_user import CustomUserSerializer

class EnvironmentReadSerializer(serializers.ModelSerializer):
    user_FK = CustomUserSerializer(read_only=True)

    class Meta:
        model = Environment
        fields = '__all__'
