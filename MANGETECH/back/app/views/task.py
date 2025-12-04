from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q

from rest_framework.views import APIView
from rest_framework.response import Response

from ..models import Task, URGENCY_LEVELS
from ..serializers import TaskReadSerializer, TaskWriteSerializer
from ..filters import TaskFilter


class UrgencyLevelList(APIView):
    def get(self, request):
        return Response([
            {"value": level[0], "label": level[1]}
            for level in URGENCY_LEVELS.choices
        ])


class TaskView(ModelViewSet):
    queryset = Task.objects.all()
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend]
    filterset_class = TaskFilter

    def get_serializer_class(self):
        if self.request.method == "GET":
            return TaskReadSerializer
        return TaskWriteSerializer

    def perform_create(self, serializer):
        serializer.save(creator_FK=self.request.user)

    def get_queryset(self):
        user = self.request.user

        if user.groups.filter(name="ADMIN").exists():
            return Task.objects.all()

        if user.groups.filter(name="Técnico").exists():
            # Técnico vê apenas os atribuídos a ele
            return Task.objects.filter(responsibles_FK=user.id).distinct()

        if user.groups.filter(name="Cliente").exists():
            # Cliente vê somente o que ele criou
            return Task.objects.filter(creator_FK=user.id)

        return Task.objects.none()
