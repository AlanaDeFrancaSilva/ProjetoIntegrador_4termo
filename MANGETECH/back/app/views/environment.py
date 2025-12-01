from rest_framework.viewsets import ModelViewSet
from ..models import *
from ..serializers import *

class EnvironmentView(ModelViewSet):
    queryset = Environment.objects.all()

    def get_serializer_class(self):
        if self.request.method in ['GET']:
            return EnvironmentReadSerializer
        return EnvironmentWriteSerializer