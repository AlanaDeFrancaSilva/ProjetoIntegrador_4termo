from rest_framework import serializers
from django.contrib.auth.models import Group
from ..models import CustomUser, Task


class CustomUserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False)

    # Retorna os grupos do usuário como nomes
    groups = serializers.SlugRelatedField(
        many=True,
        read_only=True,
        slug_field='name'
    )

    # Campo opcional para definir grupo ao criar/editar
    group = serializers.CharField(write_only=True, required=False)

    tasks_created = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = [
            'id',
            'name',
            'email',
            'nif',
            'phone',
            'is_active',
            'password',
            'groups',
            'group',
            'tasks_created',
        ]

    def get_tasks_created(self, obj):
        return Task.objects.filter(creator_FK=obj.id).count()

    # ===========================================
    # 🔥 CRIAÇÃO DO USUÁRIO COM GRUPO
    # ===========================================
    def create(self, validated_data):
        password = validated_data.pop('password', None)
        group_name = validated_data.pop('group', None)

        if 'nif' not in validated_data:
            raise serializers.ValidationError({"nif": "NIF é obrigatório"})

        user = CustomUser.objects.create_user(
            email=validated_data['email'],
            password=password,
            nif=validated_data['nif'],
            name=validated_data.get('name', ''),
            phone=validated_data.get('phone')
        )

        # 🔥 Se o front enviou "group": "Técnico"
        if group_name:
            group, _ = Group.objects.get_or_create(name=group_name)
            user.groups.add(group)

        return user

    # ===========================================
    # 🔥 ATUALIZAÇÃO DO USUÁRIO (INCLUINDO GRUPO)
    # ===========================================
    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        group_name = validated_data.pop('group', None)

        # Atualização de campos normais
        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        # Atualiza senha se enviada
        if password:
            instance.set_password(password)

        instance.save()

        # 🔥 Atualiza grupo do usuário
        if group_name:
            instance.groups.clear()  # Remove grupos antigos
            group, _ = Group.objects.get_or_create(name=group_name)
            instance.groups.add(group)

        return instance
