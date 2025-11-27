<template>
  <div class="modal-overlay" @click.self="close">
    <div class="modal">
      <div class="modal-header">
        <h2>Detalhes do Ativo</h2>
        <button class="close-btn" @click="close">✕</button>
      </div>

      <form @submit.prevent="submitForm" class="modal-body">

        <label>Nome</label>
        <input v-model="form.name" type="text" required />

        <label>Código</label>
        <input v-model="form.code" type="text" required />

        <label>Categoria</label>
        <select v-model="form.category_FK">
          <option v-for="c in props.categoriesList" :key="c.id" :value="c.id">
            {{ c.name }}
          </option>
        </select>

        <label>Ambiente</label>
        <select v-model="form.environment_FK">
          <option v-for="env in props.environmentsList" :key="env.id" :value="env.id">
            {{ env.name }}
          </option>
        </select>

        <label>Descrição</label>
        <textarea v-model="form.description" rows="3"></textarea>

        <p><strong>Data de Criação: </strong>{{ new Date(form.creation_date).toLocaleString() }}</p>

        <div class="modal-footer">
          <button type="button" class="btn-cancel" @click="close">Fechar</button>
          <button type="submit" class="btn-save">Salvar Alterações</button>
        </div>

      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const emit = defineEmits(['close', 'update'])

const props = defineProps({
  equipment: { type: Object, required: true },
  categoriesList: { type: Array, default: () => [] },
  environmentsList: { type: Array, default: () => [] }
})

const form = ref({ ...props.equipment })

const close = () => emit('close')

const submitForm = () => {
  emit('update', form.value)
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
}

.modal {
  background: white;
  width: 500px;
  padding: 20px;
  border-radius: 10px;
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

.btn-save {
  background: #1e293b;
  color: white;
}
</style>
