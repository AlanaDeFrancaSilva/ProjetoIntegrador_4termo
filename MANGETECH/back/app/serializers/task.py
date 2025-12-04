from rest_framework import serializers
from ..models import *
from .custom_user import CustomUserSerializer
from .equipment import EquipmentSerializer
from .task_status import TaskStatusSerializer   # IMPORTANTE

class TaskReadSerializer(serializers.ModelSerializer):
    creator_FK = CustomUserSerializer()
    equipments_FK = EquipmentSerializer(many=True)
    responsibles_FK = CustomUserSerializer(many=True)
    urgency_level_label = serializers.CharField(source='get_urgency_level_display')

    # 🔹 Adicionando histórico de status
    TaskStatus_task_FK = TaskStatusSerializer(many=True, read_only=True)

    class Meta:
        model = Task
        fields = '__all__'


class TaskWriteSerializer(serializers.ModelSerializer):
    # Permite status apenas na criação, não na atualização
    status = serializers.CharField(write_only=True, required=False)

    def create(self, validated_data):
        status_value = self.initial_data.get('status', 'ABERTO')  # Alterado de OPEN para ABERTO
        validated_data.pop('status', None)

        task = super().create(validated_data)

        TaskStatus.objects.create(
            task_FK=task,
            status=status_value
        )
        return task

    def update(self, instance, validated_data):
        
        validated_data.pop('status', None)
        return super().update(instance, validated_data)

    class Meta:
        model = Task
        fields = '__all__'
