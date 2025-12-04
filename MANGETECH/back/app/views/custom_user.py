from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import IsAuthenticated

from ..models import CustomUser
from ..serializers import CustomUserSerializer


class CustomUserView(ModelViewSet):
    queryset = CustomUser.objects.all()
    serializer_class = CustomUserSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        queryset = super().get_queryset()
        role = self.request.query_params.get("role")

        # 🔥 Sem risco: qualquer usuário pode solicitar lista de técnicos
        if role == "tecnico":
            return queryset.filter(groups__name__iexact="Técnico")

        # 🔥 Admin pode ver tudo
        if user.groups.filter(name="ADMIN").exists():
            return queryset

        # ❌ Cliente ou Técnico NÃO podem ver lista geral
        return queryset.none()
