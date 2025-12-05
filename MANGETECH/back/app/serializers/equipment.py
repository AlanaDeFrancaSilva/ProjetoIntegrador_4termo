from rest_framework import serializers
from ..models import Equipment, Category, Environment
from .category import CategorySerializer
from .environment import EnvironmentSerializer


class EquipmentSerializer(serializers.ModelSerializer):
    # GET → mantém os nomes ANTIGOS que seu frontend usa
    category_FK = CategorySerializer(read_only=True)
    environment_FK = EnvironmentSerializer(read_only=True)

    # POST/PUT → recebe IDs nos nomes novos
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(),
        source='category_FK',
        write_only=True
    )

    environment_id = serializers.PrimaryKeyRelatedField(
        queryset=Environment.objects.all(),
        source='environment_FK',
        write_only=True
    )

    class Meta:
        model = Equipment
        fields = [
            "id",
            "name",
            "code",
            "description",
            "creation_date",
            "category_FK",
            "environment_FK",
            "category_id",
            "environment_id",
        ]
        read_only_fields = ["id", "creation_date"]
