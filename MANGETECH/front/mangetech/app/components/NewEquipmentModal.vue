<template>
  <div class="modal-overlay" @click.self="close">
    <div class="modal">
      <div class="modal-header">
        <h2>Novo Ativo</h2>
        <button class="close-btn" @click="close">✕</button>
      </div>

      <form @submit.prevent="submitForm" class="modal-body">

        <label>Nome</label>
        <input v-model="form.name" type="text" required />

        <label>Código</label>
        <input v-model="form.code" type="text" required />

        <label>Categoria</label>
        <select v-model="form.category_FK_id" required>
          <option disabled value="">Selecione uma categoria</option>
          <option v-for="c in props.categoriesList" :key="c.id" :value="c.id">
            {{ c.name }}
          </option>
        </select>

        <label>Ambiente</label>
        <select v-model="form.environment_FK_id" required>
          <option disabled value="">Selecione um ambiente</option>
          <option v-for="env in props.environmentsList" :key="env.id" :value="env.id">
            {{ env.name }}
          </option>
        </select>

        <label>Descrição</label>
        <textarea v-model="form.description" rows="3"></textarea>

        <div class="modal-footer">
          <button type="button" class="btn-cancel" @click="close">Cancelar</button>
          <button type="submit" class="btn-save">Salvar</button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const emit = defineEmits(['close', 'save'])

const props = defineProps({
  categoriesList: { type: Array, default: () => [] },
  environmentsList: { type: Array, default: () => [] }
})

const form = ref({
  name: '',
  code: '',
  description: '',
  category_FK_id: '',
  environment_FK_id: ''
})

const close = () => emit('close')

const submitForm = () => {
  emit('save', {
    ...form.value,
    category_FK_id: Number(form.value.category_FK_id),
    environment_FK_id: Number(form.value.environment_FK_id),
  })
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

.modal-body {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

input, textarea, select {
  padding: 10px;
  border: 1px solid #1e293b;
  border-radius: 4px;
  width: 100%;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.btn-cancel {
  background: #ccc;
}

.btn-save {
  background: #1e293b;
  color: white;
}
</style>
