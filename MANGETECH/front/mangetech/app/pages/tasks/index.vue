<script setup lang="ts">
definePageMeta({
  layout: 'dashboard-layout'
})

import { ref, watch, onMounted } from 'vue'
import { getTasks } from '~/services/task.services'
import NewTaskModal from '~/components/NewTaskModal.vue'

// Estado reativo
const tasks = ref<any[]>([])
const searchQuery = ref('')
const statusFilter = ref('') // Todos, Alta, Média, Baixa
const isLoading = ref(false)

const showNewTaskModal = ref(false)

// Mapeamento dos valores de urgência para português
const urgencyMap = {
  LOW: 'Baixa',
  MEDIUM: 'Média',
  HIGH: 'Alta',
  EXTRA_HIGH: 'Extra Alta',  // Se você tiver esse nível extra de urgência
}

// Função de busca
const fetchTasks = async () => {
  try {
    isLoading.value = true
    const params: Record<string, any> = {}

    if (searchQuery.value) {
      // Busca por nome
      params.name = searchQuery.value
    }

    if (statusFilter.value && statusFilter.value !== 'Todos') {
      const urgencyMapRev: Record<string, string> = {
        Baixa: 'LOW',
        Média: 'MEDIUM',
        Alta: 'HIGH',
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

// Busca inicial
onMounted(fetchTasks)

// Recarregar ao digitar
watch(searchQuery, () => {
  fetchTasks()
})
</script>

<template>
  <div>
    <h1>Chamados</h1>
    <h3>Gerencie ordens de serviço com controle completo</h3>

    <!-- Barra de ações -->
    <div class="flex flex-wrap items-center gap-4 mb-6 mt-4">
      <!-- Botão Novo Chamado -->
      <button
        class="bg-blue-600 hover:bg-blue-700 text-white font-semibold px-4 py-2 rounded-md transition"
        @click="showNewTaskModal = true"
      >
        + Novo Chamado
      </button>

      <NewTaskModal
        v-if="showNewTaskModal"
        @close="showNewTaskModal = false"
      />

      <!-- Campo de busca -->
      <div
        class="flex items-center border border-gray-300 rounded-md overflow-hidden w-full max-w-sm"
      >
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Pesquisar..."
          class="flex-1 px-3 py-2 outline-none"
        />
        <button
          class="bg-gray-100 px-3 hover:bg-gray-200 transition"
          @click="fetchTasks"
        >
          🔍
        </button>
      </div>

      <!-- Botão de Status -->
      <div class="relative">
        <select
          v-model="statusFilter"
          @change="fetchTasks"
          class="border border-gray-300 px-4 py-2 rounded-md text-gray-700"
        >
          <option value="Todos">Todos os Status</option>
          <option value="Baixa">Baixa</option>
          <option value="Média">Média</option>
          <option value="Alta">Alta</option>
        </select>
      </div>
    </div>

    <!-- Tabela -->
    <table v-if="!isLoading">
      <thead>
        <tr>
          <th>ID Chamado</th>
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
          <td>{{ task.creator_FK.name }}</td>
          <td>{{ task.name }}</td>
          <td>{{ task.description }}</td>
          <td>{{ task.creation_date }}</td>
          <td :class="{
            'Baixa': task.urgency_level === 'LOW',
            'Média': task.urgency_level === 'MEDIUM',
            'Alta': task.urgency_level === 'HIGH',
            'ExtraAlta': task.urgency_level === 'EXTRA_HIGH'
          }">
            {{ urgencyMap[task.urgency_level] || task.urgency_level }}
          </td>
        </tr>
      </tbody>
    </table>

    <div v-else class="text-gray-500 mt-4">Carregando...</div>
  </div>
</template>

<style scoped lang="scss">
table {
  width: 100%;
  border-collapse: collapse;
  background-color: #ffffff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);

  thead {
    background-color: #f3f4f6;
    
    th {
      text-align: left;
      padding: 12px 16px;
      font-weight: 600;
      color: #1f2937;
      font-size: 0.95rem;
    }
  }

  tbody {
    tr {
      border-bottom: 1px solid #e5e7eb;

      &:last-child {
        border-bottom: none;
      }

      td {
        padding: 12px 16px;
        color: #374151;
        font-size: 0.95rem;

        &:nth-child(6) { // coluna de Urgência
          font-weight: 600;
          text-align: center;

          &.Baixa {
            background-color: #d1fae5;
            color: #065f46;
            border-radius: 6px;
            padding: 4px 8px;
          }

          &.Média {
            background-color: #fef3c7;
            color: #78350f;
            border-radius: 6px;
            padding: 4px 8px;
          }

          &.Alta {
            background-color: #fee2e2;
            color: #991b1b;
            border-radius: 6px;
            padding: 4px 8px;
          }

          &.ExtraAlta { 
            background-color: #fef2f2; 
            color: #990000;              
            border-radius: 6px; 
            padding: 4px 8px; 
          }
        }
      }
    }

    tr:hover {
      background-color: #f9fafb;
    }
  }
}

/* Responsividade */
@media (max-width: 900px) {
  table, thead, tbody, th, td, tr {
    display: block;
  }

  thead {
    display: none;
  }

  tbody tr {
    margin-bottom: 16px;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 12px;
  }

  tbody td {
    display: flex;
    justify-content: space-between;
    padding: 6px 12px;

    &::before {
      content: attr(data-label);
      font-weight: 600;
      color: #6b7280;
    }

    &:nth-child(6) {
      justify-content: flex-start;
    }
  }
}
</style>
