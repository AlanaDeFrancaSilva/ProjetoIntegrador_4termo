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

        <!-- Status -->
        <label>Status</label>
        <select v-model="form.status" required>
          <option v-for="opt in statusOptions" :key="opt.value" :value="opt.value">
            {{ opt.label }}
          </option>
        </select>

        <!-- Responsáveis (somente técnicos) -->
        <label>Responsáveis</label>
        <select v-model="form.responsibles_FK" multiple>
          <option
            v-for="user in technicianUsers"
            :key="user.id"
            :value="user.id"
          >
            {{ user.name }}
          </option>
        </select>

        <!-- Equipamentos -->
        <label>Equipamentos relacionados</label>
        <select v-model="form.equipments_FK" multiple>
          <option v-for="eq in props.equipmentList" :key="eq.id" :value="eq.id">
            {{ eq.name }}
          </option>
        </select>

        <!-- Data -->
        <label>Data de Criação</label>
        <input v-model="form.creation_date" type="text" disabled />

        <!-- Botões -->
        <div class="modal-footer">
          <button type="button" class="btn-cancel" @click="close">
            Cancelar
          </button>

          <button
            type="submit"
            class="btn-save"
            :disabled="isBlocked"
            :class="{ 'btn-disabled': isBlocked }"
          >
            Salvar
          </button>
        </div>

      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useUserStore } from '@/stores/user'

const emit = defineEmits(['close', 'save'])
const userStore = useUserStore()

const props = defineProps({
  usersList: { type: Array, default: () => [] },
  equipmentList: { type: Array, default: () => [] },
  urgencyOptions: { type: Array, default: () => [] },
})

/* =====================================================
   🔥 CORREÇÃO DEFINITIVA DO PROBLEMA:
   Aceita "tecnico", "Técnico", "TECNICO", etc.
====================================================== */
const technicianUsers = computed(() =>
  props.usersList.filter((u: any) =>
    Array.isArray(u.groups) &&
    u.groups.some(g =>
      g
        .normalize("NFD")                // remove acentos
        .replace(/[\u0300-\u036f]/g, "") // normaliza
        .trim()
        .toLowerCase() === "tecnico"     // compara corretamente
    )
  )
);


/* 🔒 Técnico não pode criar chamados */
const isBlocked = computed(() => !userStore.isAdmin && !userStore.isCliente)

/* Status */
const statusOptions = [
  { value: 'OPEN', label: '🟢 Aberto' },
  { value: 'WAITING_RESPONSIBLE', label: '🟡 Aguardando Responsável' },
  { value: 'ONGOING', label: '🔵 Em Andamento' },
  { value: 'DONE', label: '🟣 Concluído' },
  { value: 'FINISHED', label: '⚪ Finalizado' },
  { value: 'CANCELLED', label: '🔴 Cancelado' },
]

/* Formulário */
const form = ref({
  name: '',
  description: '',
  urgency_level: '',
  status: 'OPEN',
  responsibles_FK: [],
  equipments_FK: [],
  creation_date: new Date().toLocaleDateString(),
})

/* Se selecionar técnico → muda status automaticamente */
watch(() => form.value.responsibles_FK, (newVal) => {
  if (newVal.length > 0 && form.value.status === 'OPEN') {
    form.value.status = 'ONGOING'
  }
})

/* Urgência formatada */
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
  if (isBlocked.value) {
    alert("Você não tem permissão para criar chamados.")
    return
  }
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
}

.modal-header {
  display: flex;
  justify-content: space-between;
}

.modal-body {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

select, input, textarea {
  padding: 10px;
  border-radius: 6px;
  border: 1px solid #1e293b;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.btn-save {
  background: #1e293b;
  color: white;
}

.btn-disabled {
  background: #9ca3af;
  cursor: not-allowed;
}
</style>
