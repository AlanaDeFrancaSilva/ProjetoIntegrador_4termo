from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import *
from .views.task import UrgencyLevelList

router = DefaultRouter()
router.register(r'category',CategoryView)
router.register(r'custom-user',CustomUserView)
router.register(r'environment',EnvironmentView)
router.register(r'equipment',EquipmentView)
router.register(r'notification',NotificationView)
router.register(r'task-status',TaskStatusView)
router.register(r'task-status-image',TaskStatusImageView)
router.register(r'task',TaskView)

urlpatterns = router.urls + [
    path('urgency-levels/', UrgencyLevelList.as_view(), name='urgency-levels')
]

