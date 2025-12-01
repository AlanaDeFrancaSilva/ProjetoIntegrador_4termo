<script setup lang="ts">
definePageMeta({ layout: 'dashboard-layout' })

import { getEquipments, createEquipment, updateEquipment } from '~/services/equipment.services'
import { getCategories } from '~/services/category.services'
import { getEnvironments } from '~/services/environment.services'

import NewEquipmentModal from '~/components/NewEquipmentModal.vue'
import EquipmentDetailsModal from '~/components/EquipmentDetailsModal.vue'

const equipments = ref<any[]>([])
const searchQuery = ref('')
const isLoading = ref(false)

const showNewEquipmentModal = ref(false)
const showEquipmentDetailsModal = ref(false)
const selectedEquipment = ref<any | null>(null)

const categoriesList = ref<any[]>([])
const environmentsList = ref<any[]>([])

// 🔹 Buscar categorias e ambientes do backend
const fetchCategories = async () => {
  try {
    const data = await getCategories()
    console.log('🔎 Categorias recebidas da API:', data)
    categoriesList.value = Array.isArray(data) ? data : data.results ?? []
  } catch (e) {
    console.error('❌ Erro ao buscar categorias:', e)
  }
}



const fetchEnvironments = async () => {
  const data = await getEnvironments()
  environmentsList.value = data.results || data || []
}

// 🔹 Buscar equipamentos
const fetchEquipmentsData = async () => {
  try {
    isLoading.value = true
    const params: Record<string, any> = {}

    if (searchQuery.value) params.name = searchQuery.value

    const data = await getEquipments(params)  // Retorna a lista direta
    equipments.value = data                  // Já é um array
  } catch (err) {
    console.error('Erro ao buscar equipamentos:', err)
  } finally {
    isLoading.value = false
  }
}


// 🔹 Abrir modal de detalhes
const openEquipmentDetails = async (equipment: any) => {
  await fetchCategories()
  await fetchEnvironments()
  selectedEquipment.value = { ...equipment }
  showEquipmentDetailsModal.value = true
}

// 🔹 Criar novo equipamento
const handleSave = async (newData: any) => {
  await createEquipment(newData)
  await fetchEquipmentsData()
  showNewEquipmentModal.value = false
}

// 🔹 Atualizar equipamento
const handleUpdate = async (updatedData: any) => {
  await updateEquipment(updatedData.id, updatedData)
  await fetchEquipmentsData()
  showEquipmentDetailsModal.value = false
}

// 🔹 Watchers
watch(showNewEquipmentModal, async (isOpen) => {
  if (isOpen) {
    await fetchCategories()
    await fetchEnvironments()
  }
})

onMounted(fetchEquipmentsData)
watch(searchQuery, fetchEquipmentsData)
</script>

<template>
  <div class="page-container">
    <div class="header">
      <h1>Ativos</h1>
      <p>Gerencie os equipamentos cadastrados no sistema</p>
    </div>

    <!-- 🔎 Ações -->
    <div class="actions-bar">
      <div class="search-box">
        <span class="icon-search">🔍</span>
        <input v-model="searchQuery" type="text" placeholder="Buscar por nome ou código" />
      </div>

      <div class="actions-buttons">
        <button class="btn-primary" @click="showNewEquipmentModal = true">+ Novo Ativo</button>
      </div>

      <!-- Modal de criação -->
      <NewEquipmentModal
        v-if="showNewEquipmentModal"
        @close="showNewEquipmentModal = false"
        @save="handleSave"
        :categoriesList="categoriesList"
        :environmentsList="environmentsList"
      />
    </div>

    <!-- 📋 Tabela de Ativos -->
    <div v-if="!isLoading" class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Nome</th>
            <th>Código</th>
            <th>Categoria</th>
            <th>Ambiente</th>
            <th>Data de Criação</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="eq in equipments"
            :key="eq.id"
            class="clickable-row"
            @click="openEquipmentDetails(eq)"
          >
            <td>{{ eq.id }}</td>
            <td>{{ eq.name }}</td>
            <td>{{ eq.code }}</td>
            <td>{{ eq.category_FK?.name || '—' }}</td>
            <td>{{ eq.environment_FK?.name || '—' }}</td>
            <td>{{ new Date(eq.creation_date).toLocaleDateString('pt-BR') }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal de edição -->
    <EquipmentDetailsModal
      v-if="showEquipmentDetailsModal"
      :equipment="selectedEquipment"
      :categoriesList="categoriesList"
      :environmentsList="environmentsList"
      @close="showEquipmentDetailsModal = false"
      @update="handleUpdate"
    />

    <div v-else class="loading">
      <span>⏳</span> Carregando equipamentos...
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
