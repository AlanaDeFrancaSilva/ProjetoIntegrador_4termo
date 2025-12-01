<template>
  <div v-if="show" class="modal-overlay" @click.self="close">
    <div class="modal-card">

      <!-- Cabeçalho -->
      <div class="modal-header">
        <h2>{{ isEdit ? 'Editar Ambiente' : 'Novo Ambiente' }}</h2>
        <button class="close-btn" @click="close">✕</button>
      </div>

      <!-- Formulário -->
      <form @submit.prevent="submit" class="modal-body">

        <label>Nome do Ambiente</label>
        <input
          v-model="localForm.name"
          type="text"
          required
          placeholder="Ex: Laboratório 1"
        />

        <label>Responsável</label>
        <select v-model="localForm.user_FK">
          <option disabled value="">Selecione um responsável</option>
          <option v-for="user in usersList" :key="user.id" :value="user.id">
            {{ user.name }} ({{ user.email }})
          </option>
        </select>

        <label>Descrição</label>
        <textarea
          v-model="localForm.description"
          rows="3"
          placeholder="Descrição breve do ambiente"
        ></textarea>

        <div v-if="isEdit">
          <label>Status</label>
          <select v-model="localForm.is_active">
            <option :value="true">Ativo</option>
            <option :value="false">Inativo</option>
          </select>
        </div>

        <!-- Rodapé -->
        <div class="modal-footer">
          <button type="button" class="btn-cancel" @click="close">Cancelar</button>
          <button type="submit" class="btn-save">
            {{ isEdit ? 'Salvar Alterações' : 'Criar Ambiente' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  show: Boolean,
  modelValue: Object,
  usersList: Array,
  isEdit: Boolean
})

const emit = defineEmits(['close', 'submit'])

const localForm = ref({
  id: null,
  name: '',
  user_FK: '',
  description: '',
  is_active: true
})

// sempre que o ambiente vier do pai, atualiza o form
watch(
  () => props.modelValue,
  (val) => {
    if (!val) return
    localForm.value = {
      id: val.id ?? null,
      name: val.name ?? '',
      // user_FK pode vir como objeto ou id
      user_FK: val.user_FK?.id ?? val.user_FK ?? '',
      description: val.description ?? '',
      is_active: val.is_active ?? true
    }
  },
  { immediate: true, deep: true }
)

const close = () => emit('close')

const submit = () => {
  // devolve o form pro pai
  emit('submit', { ...localForm.value })
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-card {
  background: white;
  width: 500px;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 6px 16px rgba(0,0,0,0.15);
}
.modal-header {
  display: flex;
  justify-content: space-between;
  padding-bottom: 10px;
  margin-bottom: 18px;
  border-bottom: 1px solid #e5e7eb;
}
.close-btn {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
}
input, select, textarea {
  width: 100%;
  padding: 10px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  margin-bottom: 14px;
}
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
.btn-cancel {
  padding: 8px 14px;
  background: #e5e7eb;
  border-radius: 6px;
  cursor: pointer;
}
.btn-save {
  padding: 8px 14px;
  background: #1e293b;
  color: white;
  border-radius: 6px;
  cursor: pointer;
}
</style>
