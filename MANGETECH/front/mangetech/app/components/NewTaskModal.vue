<template>
  <div class="modal-overlay" @click.self="close">
    <div class="modal">

      <!-- Cabeçalho -->
      <div class="modal-header">
        <h2>Novo Chamado</h2>
        <button class="close-btn" @click="close">✕</button>
      </div>

      <!-- Formulário -->
      <form @submit.prevent="submitForm" class="modal-body">

        <!-- NOME -->
        <label>Nome</label>
        <input v-model="form.name" type="text" required />

        <!-- DESCRIÇÃO -->
        <label>Descrição</label>
        <textarea v-model="form.description" rows="3" required></textarea>

        <div>{{ props.urgencyOptions }}</div>

        <!-- URGÊNCIA -->
        <label>Urgência</label>
        <select v-model="form.urgency_level" required>
          <option disabled value="">Selecione a urgência</option>
          <option v-for="level in urgencyOptions" 
                :key="level.value" 
                :value="level.value">
          {{ level.label }}
        </option>
        </select>

        <!-- USUÁRIOS RESPONSÁVEIS (ManyToMany) -->
        <label>Responsáveis</label>
        <select v-model="form.responsibles_FK" multiple>
          <option v-for="user in props.usersList" :key="user.id" :value="user.id">
            {{ user.name }}
          </option>
        </select>

        <!-- EQUIPAMENTOS (ManyToMany) -->
        <label>Equipamentos relacionados</label>
        <select v-model="form.equipments_FK" multiple>
          <option v-for="eq in props.equipmentList" :key="eq.id" :value="eq.id">
            {{ eq.name }}
          </option>
        </select>

        <!-- DATA DE CRIAÇÃO (somente leitura) -->
        <label>Data de Criação</label>
        <input v-model="form.creation_date" type="text" disabled />

        <!-- Botões -->
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

const form = ref({
  name: '',
  description: '',
  urgency_level: '',
  responsibles_FK: [],
  equipments_FK: []
})

const props = defineProps({
  usersList: { type: Array, default: () => [] },
  equipmentList: { type: Array, default: () => [] },
  urgencyOptions: { type: Array, default: () => [] }
})

const close = () => emit('close')

const submitForm = () => {
  emit('save', form.value)
  close()
}
</script>

<style scoped lang="scss">
/* 🔲 Fundo escurecido */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

/* 📦 Caixa do modal */
.modal {
  background: white;
  width: 450px;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
  animation: fadeIn 0.3s ease;
}

/* 📝 Cabeçalho */
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.modal-header h2 {
  font-size: 20px;
  font-weight: 600;
   color: #1e293b;
}

.close-btn {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
}

/* 📋 Formulário */
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
  border: 1px solid #1e293b; /* 🔵 azul padrão da paleta */
  border-radius: 6px;
  font-size: 14px;
  outline: none;
  color: #1f2937;
  background-color: #ffffff;
  transition: all 0.3s ease;
}


input:focus,
textarea:focus,
select:focus {
  border-color: #1e293b; /* azul vivo */
  box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.25);
}
/* 🎯 Botões */
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

.btn-cancel:hover {
  background: #d1d5db;
}

.btn-save {
  background:#1e293b;
  color: white;
}

.btn-save:hover {
  background: #172554;
}

/* ✨ Animação suave */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
