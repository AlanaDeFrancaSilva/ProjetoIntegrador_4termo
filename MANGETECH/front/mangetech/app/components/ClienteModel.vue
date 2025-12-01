<template>
  <div v-if="show" class="modal-overlay" @click.self="close">
    <div class="modal-card">

      <!-- Cabeçalho -->
      <div class="modal-header">
        <h2>{{ isEdit ? 'Editar Cliente' : 'Novo Cliente' }}</h2>
        <button class="close-btn" @click="close">✕</button>
      </div>

      <!-- Abas -->
      <div class="tabs">
        <button
          v-for="tab in tabs"
          :key="tab"
          :class="['tab-button', { active: activeTab === tab }]"
          @click="activeTab = tab"
        >
          {{ tab }}
        </button>
      </div>

      <form @submit.prevent="submit" class="modal-body">

        <!-- 🟦 Aba 1: Informações -->
        <div v-if="activeTab === 'Informações'">
          <label>Nome</label>
          <input v-model="form.name" type="text" placeholder="Nome completo" />

          <label>Email</label>
          <input v-model="form.email" type="email" placeholder="email@exemplo.com" />

          <label>CPF/CNPJ</label>
          <input v-model="form.nif" type="text" placeholder="Digite CPF ou CNPJ" />
        </div>

        <!-- 🟨 Aba 2: Contato -->
        <div v-if="activeTab === 'Contato'">
          <label>Telefone</label>
          <input v-model="form.phone" type="text" placeholder="(00) 00000-0000" />

          <label>Cidade</label>
          <input v-model="form.city" type="text" placeholder="Digite a cidade" />

          <label>Empresa / Organização</label>
          <input v-model="form.company" type="text" placeholder="Nome da empresa" />
        </div>

        <!-- 🟩 Aba 3: Acesso -->
        <div v-if="activeTab === 'Acesso'">
          <label>Status</label>
          <select v-model="form.is_active">
            <option :value="true">Ativo</option>
            <option :value="false">Inativo</option>
          </select>

          <label>Senha (opcional)</label>
          <input
            v-model="form.password"
            type="password"
            placeholder="Preencha apenas para alterar"
          />
        </div>

        <!-- ⚙️ Rodapé -->
        <div class="modal-footer">
          <button type="button" class="btn-cancel" @click="close">Cancelar</button>
          <button type="submit" class="btn-save">{{ isEdit ? 'Salvar Alterações' : 'Criar Cliente' }}</button>
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
  isEdit: Boolean
})

const emit = defineEmits(['close', 'submit', 'update:modelValue'])

const form = ref({})     // Inicializa vazio
const activeTab = ref('Informações')
const tabs = ['Informações', 'Contato', 'Acesso']

// 🔹 Atualiza o form sempre que modelValue mudar (inclusive ao abrir modal)
watch(
  () => props.modelValue,
  (newVal) => {
    form.value = { ...newVal }
  },
  { deep: true, immediate: true }
)

// 🔹 Envia alterações para o componente pai
watch(form, (val) => emit('update:modelValue', val), { deep: true })

const close = () => emit('close')
const submit = () => emit('submit', form.value)
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
  width: 600px;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 8px 25px rgba(0,0,0,0.15);
}
.modal-header {
  display: flex;
  justify-content: space-between;
  border-bottom: 1px solid #e5e7eb;
  padding-bottom: 10px;
  margin-bottom: 18px;
}
.tabs {
  display: flex;
  gap: 6px;
  margin-bottom: 18px;
}
.tab-button {
  flex: 1;
  background: #f3f4f6;
  border: none;
  padding: 8px 12px;
  cursor: pointer;
  border-radius: 6px;
}
.tab-button.active {
  background: #1e293b;
  color: white;
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
}
.btn-save {
  padding: 8px 14px;
  background: #1e293b;
  color: white;
  border-radius: 6px;
}
</style>
