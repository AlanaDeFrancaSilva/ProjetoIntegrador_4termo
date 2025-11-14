from rest_framework import serializers
from ..models import CustomUser, Task

class CustomUserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False)

    groups = serializers.SlugRelatedField(
        many=True,
        read_only=True,
        slug_field='name'
    )

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
            'tasks_created'
        ]

    def get_tasks_created(self, obj):
        return Task.objects.filter(creator_FK=obj.id).count()

    def create(self, validated_data):
        password = validated_data.pop('password', None)

        if 'nif' not in validated_data:
            raise serializers.ValidationError({"nif": "NIF é obrigatório"})

        user = CustomUser.objects.create_user(
            email=validated_data['email'],
            password=password,
            nif=validated_data['nif'],
            name=validated_data.get('name', ''),
            phone=validated_data.get('phone')
        )
        return user

 
    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)

        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        if password:
            instance.set_password(password)

        instance.save()
        return instance
