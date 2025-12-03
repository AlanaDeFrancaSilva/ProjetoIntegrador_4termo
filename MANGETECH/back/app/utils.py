from .models import CustomUser

def check_group(group_name, user_id) -> bool:
    try:
        user = CustomUser.objects.get(id=user_id)
        return user.groups.filter(name=group_name).exists()
    except CustomUser.DoesNotExist:
        return False

def is_Admin(user_id) -> bool:
    return check_group("ADMIN", user_id)

def is_Tecnico(user_id) -> bool:
    return check_group("Técnico", user_id)

def is_Cliente(user_id) -> bool:
    return check_group("Cliente", user_id)
