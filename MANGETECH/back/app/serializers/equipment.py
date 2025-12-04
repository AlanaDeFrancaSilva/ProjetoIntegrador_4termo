from rest_framework import serializers
from ..models import Equipment, Category, Environment
from .category import CategorySerializer
from .environment import EnvironmentSerializer


class EquipmentSerializer(serializers.ModelSerializer):
    # Retorna o OBJETO COMPLETO (id + name)
    category_FK = CategorySerializer(read_only=True)
    environment_FK = EnvironmentSerializer(read_only=True)

    # Permite enviar apenas o ID no POST/PUT
    category_FK_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(),
        source="category_FK",
        write_only=True
    )

    environment_FK_id = serializers.PrimaryKeyRelatedField(
        queryset=Environment.objects.all(),
        source="environment_FK",
        write_only=True
    )

    class Meta:
        model = Equipment
        fields = "__all__"
