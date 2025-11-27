<script setup lang="ts">
definePageMeta({
  layout: 'dashboard-layout'
})

import { ref, watch, onMounted } from 'vue'
import { getTasks, createTask } from '~/services/task.services'
import { getUsers } from '~/services/user.service'
import NewTaskModal from '~/components/NewTaskModal.vue'
import { getEquipments } from '~/services/equipment.services'
import { getUrgencyLevels } from '~/services/urgency.services'

const tasks = ref<any[]>([])
const searchQuery = ref('')
const statusFilter = ref('')
const isLoading = ref(false)
const showNewTaskModal = ref(false)

const usersList = ref<any[]>([])
const equipmentList = ref<any[]>([])
const urgencyOptions = ref<any[]>([])

const fetchUsers = async () => {
  const data = await getUsers()
  console.log('Usuários recebidos:', data)
  usersList.value = data.results || data || []
}

const fetchEquipments = async () => {
  equipmentList.value = await getEquipments()
  console.log('Equipamentos recebidos:', equipmentList.value)
}

const fetchUrgencyLevels = async () => {
  const data = await getUrgencyLevels()
  console.log('Urgências recebidas:', data)

  urgencyOptions.value = data.map((item: any) => ({
    value: item.value,
    label: item.label.toUpperCase().replace('_', ' ')
  }))
}



const fetchTasks = async () => {
  try {
    isLoading.value = true
    const params: Record<string, any> = {}

    if (searchQuery.value) params.name = searchQuery.value

    if (statusFilter.value && statusFilter.value !== 'Todos') {
      const urgencyMapRev: Record<string, string> = {
        Baixa: 'LOW',
        Média: 'MEDIUM',
        Alta: 'HIGH',
        ExtraAlta: 'EXTRA_HIGH',
      }
      params.urgency_level = urgencyMapRev[statusFilter.value]
    }

    const { data } = await getTasks(params)
    tasks.value = data.value?.results || []
  } catch (err) {
    console.error('Erro ao buscar tasks:', err)
  } finally {
    isLoading.value = false
  }
}

// 🔹 FUNÇÃO PRINCIPAL PARA SALVAR UMA NOVA TASK
const handleSave = async (newTaskData: any) => {
  try {
    await createTask(newTaskData) // Envia para o backend
    await fetchTasks()            // Atualiza a lista automaticamente
    showNewTaskModal.value = false // Fecha o modal
  } catch (err) {
    console.error('Erro ao criar a task:', err)
  }
}

onMounted(fetchTasks)
watch(searchQuery, fetchTasks)

watch(showNewTaskModal, async (isOpen) => {
  if (isOpen) {
    await fetchUsers()
    await fetchEquipments()
    await fetchUrgencyLevels()
    showNewTaskModal.value = true   
  }
})

</script>


<template>
  <div class="page-container">

    <!-- Cabeçalho -->
    <div class="header">
      <h1>Chamados</h1>
      <p>Gerencie ordens de serviço com controle completo</p>
    </div>

    <!-- 🔎 Barra de Pesquisa, Novo Chamado e Filtro -->
    <div class="actions-bar">
      <div class="search-box">
        <span class="icon-search">🔍</span>
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Buscar por título"
        />
      </div>

      <div class="actions-buttons">
        <button class="btn-primary" @click="showNewTaskModal = true">
          + Novo Chamado
        </button>
        


        <select v-model="statusFilter" @change="fetchTasks" class="select-filter">
          <option value="Todos">Todas as Urgências</option>
          <option value="Baixa">Baixa</option>
          <option value="Média">Média</option>
          <option value="Alta">Alta</option>
          <option value="ExtraAlta">Extra Alta</option>
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
            <th>Descrição</th>
            <th>Data de Abertura</th>
            <th>Urgência</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(task, index) in tasks" :key="index">
            <td>{{ task.id }}</td>
            <td>{{ task.creator_FK?.name || '—' }}</td>
            <td>{{ task.name }}</td>
            <td>{{ task.description }}</td>
            <td>{{ task.creation_date }}</td>
            <td>{{ task.urgency_level_label || task.urgency_level }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Loading -->
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

/* 🔵 Badges de urgência */
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
</style>
