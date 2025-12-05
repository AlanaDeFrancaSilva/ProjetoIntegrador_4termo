<script setup lang="ts">
definePageMeta({ layout: 'dashboard-layout' })

import { ref, watch, onMounted } from 'vue'
import { getTasks, createTask, updateTask } from '~/services/task.services'
import { getUsers } from '~/services/user.service'
import { getEquipments } from '~/services/equipment.services'
import { getUrgencyLevels } from '~/services/urgency.services'
import NewTaskModal from '~/components/NewTaskModal.vue'
import TaskDetailsModal from '~/components/TaskDetailsModal.vue'

// 🔥 Store de usuário
import { useUserStore } from '@/stores/user'
const userStore = useUserStore()

const tasks = ref<any[]>([])
const searchQuery = ref('')
const urgencyFilter = ref('')
const isLoading = ref(false)
const showNewTaskModal = ref(false)

const usersList = ref<any[]>([])
const equipmentList = ref<any[]>([])
const urgencyOptions = ref<any[]>([])

const selectedTask = ref<any | null>(null)
const showTaskDetailsModal = ref(false)

// =========================
// FORMATADORES
// =========================
const formatStatus = (status: string) => {
  const map: Record<string, string> = {
    OPEN: 'Aberto',
    WAITING_RESPONSIBLE: 'Aguardando Responsável',
    ONGOING: 'Em Andamento',
    DONE: 'Concluído',
    FINISHED: 'Finalizado',
    CANCELLED: 'Cancelado'
  }
  return map[status] || status
}

const formatUrgency = (level: string) => {
  const map: Record<string, string> = {
    LOW: 'Baixa',
    MEDIUM: 'Média',
    HIGH: 'Alta',
    EXTRA_HIGH: 'Extra Alta'
  }
  return map[level] || level
}

// =========================
// FETCH USERS (TÉCNICOS)
// =========================
// =========================
// FETCH USERS (TÉCNICOS)
// =========================
const fetchUsers = async () => {
  try {
    console.log("🚀 Chamando backend GET /users/?role=tecnico ...");

    const data = await getUsers({ role: "tecnico" });

    console.log("🔥 RESPOSTA COMPLETA DO BACKEND (USERS):", data);

    // Trata formatos possíveis
    if (data?.results) {
      console.log("📌 USANDO data.results:", data.results);
      usersList.value = data.results;
    } 
    else if (Array.isArray(data)) {
      console.log("📌 USANDO array direto:", data);
      usersList.value = data;
    } 
    else if (data?.data?.results) {
      console.log("📌 USANDO data.data.results:", data.data.results);
      usersList.value = data.data.results;
    }
    else {
      console.warn("⚠️ FORMATO NÃO RECONHECIDO:", data);
      usersList.value = [];
    }

    console.log("✅ USERS FINAL NO FRONT:", usersList.value);

  } catch (err) {
    console.error("❌ Erro ao buscar usuários:", err);
    usersList.value = [];
  }
};

// =========================
// FETCH EQUIPAMENTOS / URGÊNCIA
// =========================
const fetchEquipments = async () => {
  equipmentList.value = await getEquipments()
}

const fetchUrgencyLevels = async () => {
  const data = await getUrgencyLevels()
  const urgencyData = Array.isArray(data) ? data : data.results || []
  urgencyOptions.value = urgencyData.map((item: any) => ({
    value: item.value,
    label: formatUrgency(item.value)
  }))
}

// =========================
// ÚLTIMO STATUS
// =========================
const getLatestStatus = (task: any) =>
  task.TaskStatus_task_FK?.at(-1)?.status || 'Sem Status'


// =========================
// FETCH TASKS (CHAMADOS)
// =========================
const fetchTasks = async () => {
  try {
    isLoading.value = true
    const params: Record<string, any> = {}

    if (searchQuery.value) params.name = searchQuery.value
    if (urgencyFilter.value) params.urgency_level = urgencyFilter.value

    const { data } = await getTasks(params)

    tasks.value =
      data?.value?.results ||
      data?.results ||
      data ||
      []
  } catch (err) {
    console.error('Erro ao buscar tasks:', err)
  } finally {
    isLoading.value = false
  }
}

// =========================
// ABRIR MODAL DETALHES
// =========================
const openTaskDetails = async (task: any) => {
  await fetchUrgencyLevels()
  await fetchUsers()
  await fetchEquipments()
  selectedTask.value = { ...task }
  showTaskDetailsModal.value = true
}

// =========================
// CRUD → CREATE / UPDATE
// =========================
const handleSave = async (newData: any) => {
  if (!userStore.isAdmin && !userStore.isCliente) {
    alert('Você não tem permissão para criar chamados.')
    return
  }

  await createTask(newData)
  await fetchTasks()
  showNewTaskModal.value = false
}

const handleUpdate = async (updatedData: any) => {
  await updateTask(updatedData.id, updatedData)
  await fetchTasks()
  showTaskDetailsModal.value = false
}

// =========================
// QUANDO ABRE MODAL DE CRIAÇÃO
// =========================
watch(showNewTaskModal, async (isOpen) => {
  if (isOpen) {
    await fetchUsers()
    await fetchEquipments()
    await fetchUrgencyLevels()
  }
})

// =========================
// ON MOUNTED → AQUI ESTÁ A CORREÇÃO!
// =========================
onMounted(async () => {
  await fetchTasks()

  // 🔥 CORREÇÃO: Cliente & Admin carregam técnicos automaticamente
  if (userStore.isCliente || userStore.isAdmin) {
    await fetchUsers()
    await fetchEquipments()
    await fetchUrgencyLevels()
  }
})

watch(searchQuery, fetchTasks)
watch(urgencyFilter, fetchTasks)
</script>

<template>
  <div class="page-container">
    <div class="header">
      <h1>Chamados</h1>
      <p>Gerencie ordens de serviço com controle completo</p>
    </div>

    <!-- Ações -->
    <div class="actions-bar">
      <div class="search-box">
        <span class="icon-search">🔍</span>
        <input v-model="searchQuery" type="text" placeholder="Buscar por título" />
      </div>

      <div class="actions-buttons">
        <button
          v-if="userStore.isAdmin || userStore.isCliente"
          class="btn-primary"
          @click="showNewTaskModal = true"
        >
          + Novo Chamado
        </button>

        <select v-model="urgencyFilter" @change="fetchTasks" class="select-filter">
          <option value="">Todas as Urgências</option>
          <option value="LOW">Baixa</option>
          <option value="MEDIUM">Média</option>
          <option value="HIGH">Alta</option>
          <option value="EXTRA_HIGH">Extra Alta</option>
        </select>
      </div>

      <NewTaskModal
        v-if="showNewTaskModal"
        @close="showNewTaskModal = false"
        @save="handleSave"
        :usersList="usersList"
        :equipmentList="equipmentList"
        :urgencyOptions="urgencyOptions"
      />
    </div>

    <!-- Tabela -->
    <div v-if="!isLoading" class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Solicitante</th>
            <th>Título</th>
            <th>Data de Abertura</th>
            <th>Status</th>
            <th>Urgência</th>
          </tr>
        </thead>

        <tbody>
          <tr
            v-for="task in tasks"
            :key="task.id"
            class="clickable-row"
            @click="openTaskDetails(task)"
          >
            <td>{{ task.id }}</td>
            <td>{{ task.creator_FK?.name }}</td>
            <td>{{ task.name }}</td>
            <td>{{ new Date(task.creation_date).toLocaleDateString('pt-BR') }}</td>

            <td>
              <span :class="'status-badge ' + getLatestStatus(task)">
                {{ formatStatus(getLatestStatus(task)) }}
              </span>
            </td>

            <td>
              <span :class="'urgency-badge ' + task.urgency_level">
                {{ formatUrgency(task.urgency_level) }}
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <TaskDetailsModal
      v-if="showTaskDetailsModal"
      :task="selectedTask"
      :urgencyOptions="urgencyOptions"
      :usersList="usersList"
      @close="showTaskDetailsModal = false"
      @update="handleUpdate"
    />

    <div v-else class="loading">
      <span>⏳</span> Carregando chamados...
    </div>
  </div>
</template>

<style scoped lang="scss">
.page-container {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.header h1 {
  font-size: 28px;
  font-weight: 600;
  color: #1f2937;
}

.header p {
  color: #6b7280;
  font-size: 14px;
}

/* 📌 CONTAINER PRINCIPAL DE AÇÕES */
.actions-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 10px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
}

/* 🔎 Campo de busca */
.search-box {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 14px;
  flex: 1;
  max-width: 650px;
  background: #f9fafb;
  border: 1px solid #ced4da;
  border-radius: 30px;
  transition: all 0.3s ease;
}

.search-box:hover,
.search-box:focus-within {
  border-color: #1e293b;
  box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2);
}

.search-box input {
  width: 100%;
  border: none;
  background: transparent;
  outline: none;
  font-size: 14px;
  color: #333;
}

.icon-search {
  color: #9ca3af;
  font-size: 14px;
}

/* 🎯 Botões e filtro */
.actions-buttons {
  display: flex;
  align-items: center;
  gap: 10px;
}

.btn-primary {
  padding: 8px 16px;
  background-color: #1e293b;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
  transition: background 0.3s ease;
}

.btn-primary:hover {
  background-color: #172554;
}

.select-filter {
  appearance: none;
  background-color: #ffffff !important;
  color: #333;
  border: 1px solid #1e293b;
  border-radius: 6px;
  padding: 8px 16px;
  font-size: 14px;
  cursor: pointer;
}

.select-filter:focus {
  outline: none;
  border-color: #1e293b;
  box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.25);
}

select option {
  background-color: #ffffff !important;
  color: #333;
}

.select-filter:hover,
.select-filter:focus {
  border-color: #1e293b;
}

/* 📋 Tabela */
.table-container {
  overflow-x: auto;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  background-color: #fff;
}

.data-table thead {
  background-color: #f3f4f6;
  color: #374151;
}

.data-table th,
.data-table td {
  padding: 14px 16px;
  border-bottom: 1px solid #e5e7eb;
  text-align: left;
  font-size: 14px;
}

/* 🔵 Badges */
.status-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.85rem;
  display: inline-block;
  text-align: center;
}

.clickable-row {
  cursor: pointer;
  transition: background-color 0.2s;
}

.clickable-row:hover {
  background-color: #f3f4f6;
}

/* Urgência */
.urgency-badge {
  display: inline-block;
  padding: 6px 14px;
  border-radius: 18px;
  font-weight: 600;
  font-size: 0.85rem;
  text-transform: capitalize;
}

.urgency-badge.LOW {
  background-color: #e8f5e9;
  color: #1b5e20;
  border: 1px solid #1b5e20;
}

.urgency-badge.MEDIUM {
  background-color: #fff9c4;
  color: #795548;
  border: 1px solid #795548;
}

.urgency-badge.HIGH {
  background-color: #ffe0b2;
  color: #e65100;
  border: 1px solid #e65100;
}

.urgency-badge.EXTRA_HIGH {
  background-color: #ffebee;
  color: #b71c1c;
  border: 1px solid #b71c1c;
}

/* Status cores (se quiser manter) */
.status-badge.OPEN {
  background-color: #e0f2fe;
  color: #0369a1;
  border: 1px solid #0369a1;
}

.status-badge.WAITING_RESPONSIBLE {
  background-color: #fef9c3;
  color: #854d0e;
  border: 1px solid #854d0e;
}

.status-badge.ONGOING {
  background-color: #ffedd5;
  color: #b45309;
  border: 1px solid #b45309;
}

.status-badge.FINISHED {
  background-color: #dbeafe;
  color: #1e40af;
  border: 1px solid #1e40af;
}

.status-badge.CANCELLED {
  background-color: #fee2e2;
  color: #b91c1c;
  border: 1px solid #b91c1c;
}

.status-badge.DONE {
  background-color: #e8f5e9;
  color: #1b5e20;
  border: 1px solid #1b5e20;
}

/* Loading */
.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  color: #6b7280;
}
</style>
