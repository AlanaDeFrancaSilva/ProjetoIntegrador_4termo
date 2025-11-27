<template>
  <form @submit.prevent="submit" class="form-card">

    <div class="form-group">
      <label>Nome Completo</label>
      <input v-model="localForm.name" type="text" required placeholder="Digite o nome" />
    </div>

    <div class="form-group">
      <label>Email</label>
      <input v-model="localForm.email" type="email" required placeholder="cliente@email.com" />
    </div>

    <div class="form-group">
      <label>CPF/CNPJ</label>
      <input
        v-model="localForm.nif"
  type="text"
  placeholder="Digite o CPF/CNPJ"
  @input="localForm.nif = localForm.nif.replace(/[^0-9]/g, '')" />
    </div>

    <div v-if="!isEdit" class="form-group">
      <label>Senha</label>
      <input v-model="localForm.password" type="password" required placeholder="Crie uma senha" />
    </div>

    <div class="form-group">
      <label>Status</label>
      <select v-model="localForm.is_active">
        <option :value="true">Ativo</option>
        <option :value="false">Inativo</option>
      </select>
    </div>

    <div class="form-buttons">
      <button type="button" class="btn-secondary" @click="$emit('cancel')">Cancelar</button>
      <button type="submit" class="btn-primary">
        {{ isEdit ? 'Salvar Alterações' : 'Criar Cliente' }}
      </button>
    </div>
  </form>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

const props = defineProps({
  modelValue: Object,
  isEdit: Boolean
})

const emit = defineEmits(['submit', 'cancel', 'update:modelValue'])

const localForm = ref({ ...props.modelValue })

watch(localForm, (val) => {
  emit('update:modelValue', val)
}, { deep: true })

const submit = () => {
  emit('submit', localForm.value)
}
</script>

<style scoped lang="scss">
.form-card {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-group input,
.form-group select {
  padding: 10px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  outline: none;
}

.form-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.btn-primary {
  background-color: #1e293b;
  color: white;
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
}

.btn-secondary {
  background-color: #f3f4f6;
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
}
</style>
