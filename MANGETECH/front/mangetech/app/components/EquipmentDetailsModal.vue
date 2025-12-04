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
        <select v-model="form.category_FK_id" required>
          <option disabled value="">Selecione...</option>
          <option v-for="c in props.categoriesList" :key="c.id" :value="c.id">
            {{ c.name }}
          </option>
        </select>

        <label>Ambiente</label>
        <select v-model="form.environment_FK_id" required>
          <option disabled value="">Selecione...</option>
          <option v-for="env in props.environmentsList" :key="env.id" :value="env.id">
            {{ env.name }}
          </option>
        </select>

        <label>Descrição</label>
        <textarea v-model="form.description" rows="3" required></textarea>

        <p>
          <strong>Data de Criação: </strong>
          {{ new Date(form.creation_date).toLocaleString() }}
        </p>

        <div class="modal-footer">
          <button type="button" class="btn-cancel" @click="close">Fechar</button>
          <button type="button" class="btn-delete" @click="deleteItem">Excluir</button>
          <button type="submit" class="btn-save">Salvar Alterações</button>
        </div>

      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

const emit = defineEmits(['close', 'update', 'delete'])

const props = defineProps({
  equipment: { type: Object, required: true },
  categoriesList: { type: Array, default: () => [] },
  environmentsList: { type: Array, default: () => [] }
})

/* ======================================================
   FORM CORRETO — usando category_FK_id e environment_FK_id
====================================================== */
const form = ref({
  ...props.equipment,
  category_FK_id: props.equipment.category_FK?.id || "",
  environment_FK_id: props.equipment.environment_FK?.id || "",
  description: props.equipment.description || ""
})

/* Atualiza quando abrir outro ativo */
watch(() => props.equipment, (eq) => {
  form.value = {
    ...eq,
    category_FK_id: eq.category_FK?.id || "",
    environment_FK_id: eq.environment_FK?.id || "",
    description: eq.description || ""
  }
})

const close = () => emit("close")

/* ======================================================
   BOTÃO EXCLUIR — dispara evento para o componente pai
====================================================== */
const deleteItem = () => {
  if (confirm("Tem certeza que deseja excluir este ativo?")) {
    emit("delete", form.value.id)
  }
}

/* ======================================================
   BOTÃO SALVAR — envia os dados corretos para o backend
====================================================== */
const submitForm = () => {
  emit("update", {
    id: form.value.id,
    name: form.value.name,
    code: form.value.code,
    description: form.value.description,
    category_FK_id: Number(form.value.category_FK_id),
    environment_FK_id: Number(form.value.environment_FK_id)
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

.btn-delete {
  background: #dc2626;
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
