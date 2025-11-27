<template>
  <div class="modal-overlay" @click.self="close">
    <div class="modal">

      <div class="modal-header">
        <h2>Detalhes do Chamado</h2>
        <button class="close-btn" @click="close">✕</button>
      </div>

      <!-- 🔹 Navigation Tabs -->
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

      <form @submit.prevent="submitForm" class="modal-body">

        <!-- 🟦 TAB 1: INFORMAÇÕES -->
        <div v-if="activeTab === 'Informações'">
          <label>Título</label>
          <input v-model="form.name" type="text" placeholder="Digite o título" />

          <label>Descrição</label>
          <textarea v-model="form.description" rows="3" placeholder="Descreva o chamado"></textarea>

          <label>Urgência</label>
          <select v-model="form.urgency_level">
            <option v-for="level in formattedUrgencyOptions" :key="level.value" :value="level.value">
              {{ level.label }}
            </option>
          </select>

          <label>Data de Abertura</label>
          <input type="text" :value="formattedDate" disabled />
        </div>

        <!-- 🟨 TAB 2: RESPONSÁVEIS -->
        <div v-if="activeTab === 'Responsáveis'">
          <label>Responsáveis</label>
          <select v-model="form.responsibles_FK" multiple>
            <option v-for="user in usersList" :key="user.id" :value="user.id">
              {{ user.name }}
            </option>
          </select>
        </div>

        <!-- 🟩 TAB 3: ANDAMENTO -->
        <div v-if="activeTab === 'Andamento'">
          <label>Anexo (Imagem/Documento)</label>
          <input type="file" @change="handleFileUpload" />

          <div v-if="attachedFileName" class="file-preview">
            📎 {{ attachedFileName }}
          </div>

          <label>Observações</label>
          <textarea v-model="form.progress_notes" placeholder="Descreva o andamento..." rows="4"></textarea>
        </div>

        <!-- ⚙️ Footer de ações -->
        <div class="modal-footer">
          <button type="button" class="btn-delete" @click="deleteTask">Excluir</button>
          <button type="button" class="btn-cancel" @click="close">Cancelar</button>
          <button type="submit" class="btn-save">Salvar Alterações</button>
        </div>

      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { updateTask, deleteTaskById } from '~/services/task.services'

const emit = defineEmits(['close', 'update'])
const props = defineProps({
  task: { type: Object, required: true },
  urgencyOptions: { type: Array, default: () => [] },
  usersList: { type: Array, default: () => [] },
})

const form = ref({ ...props.task })
const activeTab = ref('Informações')
const tabs = ['Informações', 'Responsáveis', 'Andamento']

const attachedFile = ref<File | null>(null)
const attachedFileName = ref<string | null>(null)

const handleFileUpload = (event: any) => {
  attachedFile.value = event.target.files[0]
  attachedFileName.value = attachedFile.value?.name || null
}

const formattedDate = computed(() =>
  new Date(form.value.creation_date).toLocaleDateString('pt-BR')
)

const formattedUrgencyOptions = computed(() => {
  const labelMap: Record<string, string> = {
    LOW: '🟢 Baixa',
    MEDIUM: '🟡 Média',
    HIGH: '🟠 Alta',
    EXTRA_HIGH: '🔴 Extra Alta',
  }
  return props.urgencyOptions.map((item: any) => ({
    value: item.value,
    label: labelMap[item.value] || item.label
  }))
})

const close = () => emit('close')

const submitForm = async () => {
  emit('update', form.value) // retorno para index.vue
}

const deleteTask = () => {
  if (confirm('Tem certeza que deseja excluir este chamado?')) {
    deleteTaskById(form.value.id)
    emit('close')
  }
}
</script>

<style scoped>
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
  width: 520px;
  padding: 20px;
  border-radius: 12px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 15px;
}

/* ⚫ Tabs */
.tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 10px;
}

.tab-button {
  flex: 1;
  padding: 8px;
  border: 1px solid #ccc;
  background: white;
  cursor: pointer;
}

.tab-button.active {
  background: #1e293b;
  color: white;
}

/* 📝 Inputs estilizados */
input,
textarea,
select {
  width: 100%;
  padding: 10px 14px;
  border: 1px solid #cfd8e3;
  border-radius: 10px;
  font-size: 14px;
  background: #f9fafb;
  transition: all 0.25s ease-in-out;
}

input:focus,
textarea:focus,
select:focus {
  outline: none;
  border-color: #1e293b;
  background: white;
  box-shadow: 0 0 6px rgba(30, 41, 59, 0.45);
}

/* 🎨 Footer e botões */
.modal-footer {
  display: flex;
  justify-content: space-between;
  margin-top: 15px;
}

.btn-delete {
  background: #dc2626;
  color: white;
  padding: 8px 14px;
  border-radius: 6px;
}

.btn-cancel {
  padding: 8px 14px;
  border: 1px solid #ddd;
  border-radius: 6px;
}

.btn-save {
  background: #1e293b;
  color: white;
  padding: 8px 14px;
  border-radius: 6px;
}

/* 📎 Pré-visualização do arquivo */
.file-preview {
  margin-top: 8px;
  padding: 8px;
  background-color: #f3f4f6;
  border-radius: 6px;
  font-size: 14px;
}
</style>
