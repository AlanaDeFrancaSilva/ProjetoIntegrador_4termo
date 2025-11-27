from rest_framework.viewsets import ModelViewSet
from ..models import *
from ..serializers import *
from ..filters import TaskFilter
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.permissions import IsAuthenticated
from ..utils import is_Admin
from rest_framework.views import APIView
from rest_framework.response import Response
from ..models import URGENCY_LEVELS

class UrgencyLevelList(APIView):
    def get(self, request):
        return Response([
            {"value": level[0], "label": level[1]}
            for level in URGENCY_LEVELS.choices
        ])
class TaskView(ReadWriteSerializer, ModelViewSet):
    queryset = Task.objects.all() #Inicialmente tem acesso a toda(all) tabela(class)
    read_serializer_class = TaskReadSerializer
    write_serializer_class = TaskWriteSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_class = TaskFilter #puxa a classe de filtro 
    permission_classes = [IsAuthenticated] #Só os usuários autenticados podem chamar esse endpoint 

    def perform_create(self, serializer):
        """Ao criar a task, define automaticamente o usuário logado como criador"""
        serializer.save(creator_FK=self.request.user)
    def get_queryset(self):
        user = self.request.user

        if not user.is_authenticated:
            return Task.objects.none()

        # ADMIN vê tudo
        if is_Admin(user.id):
            return Task.objects.all()

        # Técnico → tasks onde é responsável
        if user.groups.filter(name='Técnico').exists():
            return Task.objects.filter(responsibles_FK=user.id)

        # Cliente → tasks que ele criou
        if user.groups.filter(name='Cliente').exists():
            return Task.objects.filter(creator_FK=user.id)

        # fallback (sem grupo definido)
        return Task.objects.none()
