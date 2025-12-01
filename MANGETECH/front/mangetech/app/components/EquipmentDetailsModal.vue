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
        <select v-model="form.category_FK" required>
          <option disabled value="">Selecione...</option>
          <option v-for="c in props.categoriesList" :key="c.id" :value="c.id">
            {{ c.name }}
          </option>
        </select>

        <label>Ambiente</label>
        <select v-model="form.environment_FK" required>
          <option disabled value="">Selecione...</option>
          <option v-for="env in props.environmentsList" :key="env.id" :value="env.id">
            {{ env.name }}
          </option>
        </select>

        <label>Descrição</label>
        <textarea v-model="form.description" rows="3" required></textarea>

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
import { ref, watch } from 'vue'

const emit = defineEmits(['close', 'update'])

const props = defineProps({
  equipment: { type: Object, required: true },
  categoriesList: { type: Array, default: () => [] },
  environmentsList: { type: Array, default: () => [] }
})

/* ======================================================
   FORM NORMALIZADO — IDs sempre corretos
====================================================== */
const form = ref({
  ...props.equipment,
  category_FK: props.equipment.category_FK?.id || "",
  environment_FK: props.equipment.environment_FK?.id || "",
  description: props.equipment.description || ""
})

watch(() => props.equipment, (eq) => {
  form.value = {
    ...eq,
    category_FK: eq.category_FK?.id || "",
    environment_FK: eq.environment_FK?.id || "",
    description: eq.description || ""
  }
})

const close = () => emit("close")

/* ======================================================
   ENVIO FINAL — tudo pronto para o backend aceitar
====================================================== */
const submitForm = () => {
  emit("update", {
    id: form.value.id,
    name: form.value.name,
    code: form.value.code,
    description: form.value.description,
    category_FK: form.value.category_FK,
    environment_FK: form.value.environment_FK
  })
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
  padding: 8px 14px;
  border-radius: 6px;
}

.btn-cancel {
  background: #dedede;
  padding: 8px 14px;
  border-radius: 6px;
}
</style>
