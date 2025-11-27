<template>
  <div class="modal-overlay" @click.self="close">
    <div class="modal">
      <div class="modal-header">
        <h2>Novo Chamado</h2>
        <button class="close-btn" @click="close">✕</button>
      </div>

      <form @submit.prevent="submitForm" class="modal-body">

        <!-- Nome -->
        <label>Nome</label>
        <input v-model="form.name" type="text" required />

        <!-- Descrição -->
        <label>Descrição</label>
        <textarea v-model="form.description" rows="3" required></textarea>

        <!-- Urgência -->
        <label>Urgência</label>
        <select v-model="form.urgency_level" required>
          <option disabled value="">Selecione a urgência</option>
          <option
            v-for="level in formattedUrgencyOptions"
            :key="level.value"
            :value="level.value"
          >
            {{ level.label }}
          </option>
        </select>

        <!-- 🔹 Status -->
        <label>Status</label>
        <select v-model="form.task_status" required>
          <option disabled value="">Selecione o status</option>
          <option
            v-for="opt in statusOptions"
            :key="opt.value"
            :value="opt.value"
          >
            {{ opt.label }}
          </option>
        </select>

        <!-- Responsáveis -->
        <label>Responsáveis</label>
        <select v-model="form.responsibles_FK" multiple>
          <option
            v-for="user in props.usersList"
            :key="user.id"
            :value="user.id"
          >
            {{ user.name }}
          </option>
        </select>

        <!-- Equipamentos -->
        <label>Equipamentos relacionados</label>
        <select v-model="form.equipments_FK" multiple>
          <option
            v-for="eq in props.equipmentList"
            :key="eq.id"
            :value="eq.id"
          >
            {{ eq.name }}
          </option>
        </select>

        <!-- Data de criação -->
        <label>Data de Criação</label>
        <input v-model="form.creation_date" type="text" disabled />

        <!-- Botões -->
        <div class="modal-footer">
          <button type="button" class="btn-cancel" @click="close">
            Cancelar
          </button>
          <button type="submit" class="btn-save">Salvar</button>
        </div>

      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const emit = defineEmits(['close', 'save'])

const props = defineProps({
  usersList: { type: Array, default: () => [] },
  equipmentList: { type: Array, default: () => [] },
  urgencyOptions: { type: Array, default: () => [] },
})

// 🔹 Opções de Status
const statusOptions = [
  { value: 'ABERTO', label: 'Aberto' },
  { value: 'EM_ANDAMENTO', label: 'Em Andamento' },
  { value: 'CONCLUIDO', label: 'Concluído' },
  { value: 'CANCELADO', label: 'Cancelado' }
]

// 🔹 Formulário completo (SEM duplicação)
const form = ref({
  name: '',
  description: '',
  urgency_level: '',
  task_status: 'ABERTO',
  responsibles_FK: [],
  equipments_FK: [],
  creation_date: new Date().toLocaleDateString(),
})

// 🔹 Converter urgência técnica para label amigável
const formattedUrgencyOptions = computed(() => {
  const labelMap: Record<string, string> = {
    LOW: 'Baixa',
    MEDIUM: 'Média',
    HIGH: 'Alta',
    EXTRA_HIGH: 'Extra Alta',
  }

  return props.urgencyOptions.map((item: any) => ({
    value: item.value,
    label: labelMap[item.value] || item.label,
  }))
})

const close = () => emit('close')

const submitForm = () => {
  emit('save', form.value)
  close()
}
</script>


<style scoped lang="scss">
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal {
  background: white;
  width: 450px;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
  animation: fadeIn 0.3s ease;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.modal-body {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

input,
textarea,
select {
  width: 100%;
  padding: 10px;
  border: 1px solid #1e293b;
  border-radius: 6px;
  font-size: 14px;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 5px;
}

.btn-cancel,
.btn-save {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
}

.btn-cancel {
  background: #e5e7eb;
  color: #374151;
}

.btn-save {
  background: #1e293b;
  color: white;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
