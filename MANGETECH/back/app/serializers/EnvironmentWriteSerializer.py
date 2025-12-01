from rest_framework import serializers
from ..models import Environment

class EnvironmentWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Environment
        fields = '__all__'
