<template>
  <div class="modal-overlay" @click.self="close">
    <div class="modal">

      <div class="modal-header">
        <h2>Detalhes do Chamado</h2>
        <button class="close-btn" @click="close">✕</button>
      </div>

      <!-- Tabs -->
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

        <!-- INFORMAÇÕES -->
        <div v-if="activeTab === 'Informações'">

          <label>Título</label>
          <input v-model="form.name" type="text" :disabled="isTecnico"/>

          <label>Descrição</label>
          <textarea v-model="form.description" rows="3" :disabled="isTecnico"></textarea>

          <label>Urgência</label>
          <select v-model="form.urgency_level" :disabled="isTecnico">
            <option v-for="level in formattedUrgencyOptions" :key="level.value" :value="level.value">
              {{ level.label }}
            </option>
          </select>

          <label>Status</label>
          <select v-model="form.status">
            <option v-for="st in statusOptions" :key="st.value" :value="st.value">
              {{ st.label }}
            </option>
          </select>

          <label>Data de Abertura</label>
          <input type="text" :value="formattedDate" disabled />
        </div>

        <!-- RESPONSÁVEIS -->
        <div v-if="activeTab === 'Responsáveis'">
          <label>Responsáveis</label>
          
          <select v-model="form.responsibles_FK" multiple :disabled="isTecnico">
            <option 
              v-for="user in technicianUsers" 
              :key="user.id" 
              :value="user.id"
            >
              {{ user.name }}
            </option>
          </select>

          <div class="selected-list" v-if="form.responsibles_FK.length">
            <p><strong>Selecionados:</strong></p>
            <ul>
              <li v-for="id in form.responsibles_FK" :key="id">
                {{ getUserName(id) }}
              </li>
            </ul>
          </div>
        </div>

        <!-- ANDAMENTO -->
        <div v-if="activeTab === 'Andamento'">
          <label>Anexo</label>
          <input type="file" @change="handleFileUpload"/>

          <div v-if="attachedFileName" class="file-preview">
            📎 {{ attachedFileName }}
          </div>

          <label>Observações</label>
          <textarea v-model="form.progress_notes" rows="4"></textarea>
        </div>

        <!-- FOOTER -->
        <div class="modal-footer">

          <button 
            v-if="!isTecnico" 
            type="button" 
            class="btn-delete" 
            @click="deleteTask"
          >
            Excluir
          </button>

          <button type="button" class="btn-cancel" @click="close">Cancelar</button>
          <button type="submit" class="btn-save">Salvar Alterações</button>

        </div>

      </form>
    </div>
  </div>
</template>



<script setup>
import { ref, watch, computed } from "vue";
import { deleteTaskById } from "~/services/task.services";
import { useUserStore } from "@/stores/user";   // 🔥 IMPORTANTE

const emit = defineEmits(["close", "update"]);
const userStore = useUserStore();               // 🔥 Agora sabemos o tipo do usuário

const props = defineProps({
  task: { type: Object, required: true },
  urgencyOptions: Array,
  usersList: Array
});

const isTecnico = computed(() => userStore.isTecnico);

const normalizeForm = (task) => ({
  ...task,
  responsibles_FK: task.responsibles_FK?.map(r => r.id) || [],
  progress_notes: task.progress_notes || ""
});

const form = ref(normalizeForm(props.task));

watch(() => props.task, (nt) => {
  form.value = normalizeForm(nt);
});

// 🔥 Filtrar apenas técnicos
const technicianUsers = computed(() =>
  props.usersList?.filter(u => u.groups?.includes("Técnico")) || []
);

const getUserName = (id) =>
  props.usersList.find((u) => u.id === id)?.name || "Desconhecido";

const activeTab = ref("Informações");
const tabs = ["Informações", "Responsáveis", "Andamento"];

const formattedDate = computed(() =>
  new Date(form.value.creation_date).toLocaleDateString("pt-BR")
);

const formattedUrgencyOptions = computed(() =>
  props.urgencyOptions.map(u => ({
    value: u.value,
    label: u.label
  }))
);

const statusOptions = [
  { value: "OPEN", label: "Aberto" },
  { value: "WAITING_RESPONSIBLE", label: "Aguardando Responsável" },
  { value: "ONGOING", label: "Em Andamento" },
  { value: "DONE", label: "Concluído" },
  { value: "FINISHED", label: "Finalizado" },
  { value: "CANCELLED", label: "Cancelado" }
];

const attachedFileName = ref(null);
const handleFileUpload = (e) => {
  const file = e.target.files[0];
  attachedFileName.value = file?.name || null;
};

/* 🔥🔥 CORREÇÃO PRINCIPAL — Payload diferente para técnico */
const submitForm = () => {
  let payload = {
    id: form.value.id,
    name: form.value.name,
    description: form.value.description,
    suggested_date: form.value.suggested_date,
    urgency_level: form.value.urgency_level,
    creation_date: form.value.creation_date,
    creator_FK: form.value.creator_FK?.id || form.value.creator_FK,
    equipments_FK: form.value.equipments_FK,
    responsibles_FK: form.value.responsibles_FK,
    status: form.value.status,
    progress_notes: form.value.progress_notes || ""
  };

  emit("update", payload);
};



const deleteTask = () => {
  if (confirm("Tem certeza que deseja excluir?")) {
    deleteTaskById(form.value.id);
    emit("close");
  }
};

const close = () => emit("close");
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

input,
textarea,
select {
  width: 100%;
  padding: 10px 14px;
  border: 1px solid #cfd8e3;
  border-radius: 10px;
  background: #f9fafb;
}

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
  border-radius: 6px;
  background: #ddd;
}

.btn-save {
  background: #1e293b;
  color: white;
  padding: 8px 14px;
  border-radius: 6px;
}

.file-preview {
  margin-top: 8px;
  padding: 8px;
  background: #f3f4f6;
  border-radius: 6px;
}
</style>
