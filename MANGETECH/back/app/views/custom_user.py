from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.viewsets import ModelViewSet
from ..models import CustomUser
from ..serializers import CustomUserSerializer


class CustomUserView(ModelViewSet):
    queryset = CustomUser.objects.all()
    serializer_class = CustomUserSerializer

    def get_permissions(self):
        role = self.request.query_params.get("role")

        # 🔥 Se a rota pedir técnicos → liberar SEM autenticação
        # (para o front conseguir carregar lista no modal)
        if role and role.lower() == "tecnico":
            return [AllowAny()]

        # 🔥 Para outras operações → exige autenticação normalmente
        return [IsAuthenticated()]

    def get_queryset(self):
        user = self.request.user
        role = self.request.query_params.get("role")
        queryset = super().get_queryset()

        if role and role.lower() == "tecnico":
            return queryset.filter(groups__name__iexact="Técnico")

        if user.is_authenticated and user.groups.filter(name__iexact="ADMIN").exists():
            return queryset

        return queryset.none()
