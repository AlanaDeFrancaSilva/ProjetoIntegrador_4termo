<script setup lang="ts">
definePageMeta({ layout: 'dashboard-layout' })

import { ref, watch, onMounted } from 'vue'
import { getTasks, createTask, updateTask } from '~/services/task.services'
import { getUsers } from '~/services/user.service'
import { getEquipments } from '~/services/equipment.services'
import { getUrgencyLevels } from '~/services/urgency.services'
import NewTaskModal from '~/components/NewTaskModal.vue'
import TaskDetailsModal from '~/components/TaskDetailsModal.vue'

const tasks = ref<any[]>([])
const searchQuery = ref('')
const statusFilter = ref('')
const isLoading = ref(false)
const showNewTaskModal = ref(false)

const usersList = ref<any[]>([])
const equipmentList = ref<any[]>([])
const urgencyOptions = ref<any[]>([])

const selectedTask = ref<any | null>(null)
const showTaskDetailsModal = ref(false)

// 🔹 Mapa dos status
const formatStatus = (status: string) => {
  const map: Record<string, string> = {
    ABERTO: 'Aberto',
    EM_ANDAMENTO: 'Em Andamento',
    CONCLUIDO: 'Concluído',
    CANCELADO: 'Cancelado'
  }
  return map[status] || status || 'Sem Status'
}

// 🔹 Mapa das urgências
const formatUrgency = (level: string) => {
  const map: Record<string, string> = {
    LOW: 'Baixa',
    MEDIUM: 'Média',
    HIGH: 'Alta',
    EXTRA_HIGH: 'Extra Alta',
  }
  return map[level] || level
}

// 🔹 Buscar dados auxiliares
const fetchUsers = async () => {
  const data = await getUsers()
  usersList.value = data.results || data || []
}

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

// 🔹 Buscar chamados com filtro de status
const fetchTasks = async () => {
  try {
    isLoading.value = true
    const params: Record<string, any> = {}

    if (searchQuery.value) params.name = searchQuery.value
    if (statusFilter.value) params.task_status = statusFilter.value

    const { data } = await getTasks(params)
    tasks.value = data.value?.results || data.results || data || []
  } catch (err) {
    console.error('Erro ao buscar tasks:', err)
  } finally {
    isLoading.value = false
  }
}

// 🔹 Abrir modal de detalhes
const openTaskDetails = async (task: any) => {
  await fetchUrgencyLevels()
  await fetchUsers()
  await fetchEquipments()
  selectedTask.value = { ...task }
  showTaskDetailsModal.value = true
}

// 🔹 Criar e atualizar chamados
const handleSave = async (newData: any) => {
  await createTask(newData)
  await fetchTasks()
  showNewTaskModal.value = false
}

const handleUpdate = async (updatedData: any) => {
  await updateTask(updatedData.id, updatedData)
  await fetchTasks()
  showTaskDetailsModal.value = false
}

watch(showNewTaskModal, async (isOpen) => {
  if (isOpen) {
    await fetchUsers()
    await fetchEquipments()
    await fetchUrgencyLevels()
  }
})

onMounted(fetchTasks)
watch(searchQuery, fetchTasks)
</script>

<template>
  <div class="page-container">
    <div class="header">
      <h1>Chamados</h1>
      <p>Gerencie ordens de serviço com controle completo</p>
    </div>

    <!-- 🔎 Ações -->
    <div class="actions-bar">
      <div class="search-box">
        <span class="icon-search">🔍</span>
        <input v-model="searchQuery" type="text" placeholder="Buscar por título" />
      </div>

      <div class="actions-buttons">
        <button class="btn-primary" @click="showNewTaskModal = true">+ Novo Chamado</button>

        <!-- 📌 Filtro de Status -->
        <select v-model="statusFilter" @change="fetchTasks" class="select-filter">
          <option value="">Todos os Status</option>
          <option value="ABERTO">Aberto</option>
          <option value="EM_ANDAMENTO">Em Andamento</option>
          <option value="CONCLUIDO">Concluído</option>
          <option value="CANCELADO">Cancelado</option>
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

    <!-- 📋 Tabela de Chamados -->
    <div v-if="!isLoading" class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Solicitante</th>
            <th>Título</th>
            <th>Data de Abertura</th>
            <th>Urgência</th>
            <th>Status</th>
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
            <td>{{ task.creator_FK?.name || '—' }}</td>
            <td>{{ task.name }}</td>
            <td>{{ new Date(task.creation_date).toLocaleDateString('pt-BR') }}</td>
            <td>
              <span :class="'urgency-badge ' + task.urgency_level">
                {{ formatUrgency(task.urgency_level) }}
              </span>
            </td>
            <td>
              <span :class="'status-badge ' + task.task_status">
                {{ formatStatus(task.task_status) }}
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
  background-color:#1e293b;
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
  border-color:#1e293b;
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

/* 🔵 Badges de urgência (se quiser usar depois) */
.status-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.85rem;
  display: inline-block;
  text-align: center;
}

.Baixa { background-color: #d1fae5; color: #065f46; }
.Média { background-color: #fef3c7; color: #78350f; }
.Alta { background-color: #fee2e2; color: #991b1b; }
.ExtraAlta { background-color: #fecaca; color: #7f1d1d; }

/* 🌀 Loading */
.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  color: #6b7280;
}

.page-container {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* 🎯 Badges de Urgência — estilo dashboard */
.urgency-badge {
  display: inline-block;
  padding: 6px 14px;
  border-radius: 18px;
  font-weight: 600;
  font-size: 0.85rem;
  text-transform: capitalize;
}

/* 🟢 Baixa */
.urgency-badge.LOW {
  background-color: #e8f5e9;
  color: #1b5e20;
  border: 1px solid #1b5e20;
}

/* 🟡 Média */
.urgency-badge.MEDIUM {
  background-color: #fff9c4;
  color: #795548;
  border: 1px solid #795548;
}

/* 🟠 Alta */
.urgency-badge.HIGH {
  background-color: #ffe0b2;
  color: #e65100;
  border: 1px solid #e65100;
}

/* 🔴 Extra Alta */
.urgency-badge.EXTRA_HIGH {
  background-color: #ffebee;
  color: #b71c1c;
  border: 1px solid #b71c1c;
}

.clickable-row {
  cursor: pointer;
  transition: background-color 0.2s;
}

.clickable-row:hover {
  background-color: #f3f4f6;
}

.status-badge {
  display: inline-block;
  padding: 6px 14px;
  border-radius: 18px;
  font-weight: 600;
  font-size: 0.85rem;
  text-transform: capitalize;
}

.status-badge.ABERTO {
  background-color: #e0f2fe;
  color: #063970;
  border: 1px solid #063970;
}

.status-badge.EM_ANDAMENTO {
  background-color: #fff4e6;
  color: #b75e00;
  border: 1px solid #b75e00;
}

.status-badge.CONCLUIDO {
  background-color: #e8f5e9;
  color: #1b5e20;
  border: 1px solid #1b5e20;
}

.status-badge.CANCELADO {
  background-color: #ffebee;
  color: #b71c1c;
  border: 1px solid #b71c1c;
}
</style>
