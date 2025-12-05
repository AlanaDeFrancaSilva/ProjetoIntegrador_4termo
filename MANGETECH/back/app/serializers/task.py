from rest_framework import serializers
from ..models import Task, TaskStatus
from .custom_user import CustomUserSerializer
from .equipment import EquipmentSerializer
from .task_status import TaskStatusSerializer


# ============================
#   SERIALIZER DE LEITURA
# ============================
class TaskReadSerializer(serializers.ModelSerializer):
    creator_FK = CustomUserSerializer()
    equipments_FK = EquipmentSerializer(many=True)
    responsibles_FK = CustomUserSerializer(many=True)
    urgency_level_label = serializers.CharField(source='get_urgency_level_display')

    TaskStatus_task_FK = TaskStatusSerializer(many=True, read_only=True)

    class Meta:
        model = Task
        fields = '__all__'


# ============================
#   SERIALIZER DE ESCRITA
# ============================
class TaskWriteSerializer(serializers.ModelSerializer):
    status = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = Task
        fields = '__all__'
        extra_kwargs = {
            "name": {"required": False},
            "description": {"required": False},
            "equipments_FK": {"required": False},
            "responsibles_FK": {"required": False},
        }

    # -----------------------------
    # CRIAÇÃO DO CHAMADO
    # -----------------------------
    def create(self, validated_data):
        status_value = self.initial_data.get("status", "OPEN")
        validated_data.pop("status", None)

        task = super().create(validated_data)

        TaskStatus.objects.create(
            task_FK=task,
            status=status_value
        )
        return task

    # -----------------------------
    # ATUALIZAÇÃO (UPDATE)
    # -----------------------------
    def update(self, instance, validated_data):
        status_value = self.initial_data.get("status", None)

        # retira status do update padrão
        validated_data.pop("status", None)

        # Se o front enviou um novo status → criar histórico
        if status_value:
            TaskStatus.objects.create(
                task_FK=instance,
                status=status_value
            )

        return super().update(instance, validated_data)
