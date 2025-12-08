<script setup lang="ts">
definePageMeta({ layout: 'dashboard-layout' })

import { ref, watch, onMounted, computed } from 'vue'
import { getEquipments, createEquipment, updateEquipment, deleteEquipment } from '~/services/equipment.services'
import { getCategories } from '~/services/category.services'
import { getEnvironments } from '~/services/environment.services'

import { getCurrentUser } from '~/services/user.service'

import NewEquipmentModal from '~/components/NewEquipmentModal.vue'
import EquipmentDetailsModal from '~/components/EquipmentDetailsModal.vue'

/* ===========================================================
        ESTADOS
=========================================================== */
const equipments = ref<any[]>([])
const searchQuery = ref('')
const isLoading = ref(false)

const showNewEquipmentModal = ref(false)
const showEquipmentDetailsModal = ref(false)
const selectedEquipment = ref<any | null>(null)

const categoriesList = ref<any[]>([])
const environmentsList = ref<any[]>([])
const currentUser = ref<any>(null)

/* ===========================================================
        NORMALIZADOR
=========================================================== */
const normalizeApiReturn = (data: any) => {
  if (!data) return []
  const d = data.data ?? data
  return d.results || (Array.isArray(d) ? d : []) || []
}

/* ===========================================================
        PERMISSÃO - CLIENTE NÃO PODE CRIAR ATIVO
=========================================================== */
const canCreateEquipment = computed(() => {
  if (!currentUser.value) return false

  return (
    currentUser.value.groups?.includes("ADMIN") ||
    currentUser.value.groups?.includes("admin") ||
    currentUser.value.groups?.includes("tecnico") ||
    currentUser.value.groups?.includes("Técnico")
  )
})

/* ===========================================================
        BUSCAR EQUIPAMENTOS (USANDO name=)
=========================================================== */
const fetchEquipmentsData = async () => {
  isLoading.value = true

  const params: Record<string, any> = {}

  if (searchQuery.value) {
    params.name = searchQuery.value   // 🔥 CORREÇÃO FINAL
  }

  const data = await getEquipments(params)
  equipments.value = normalizeApiReturn(data)

  isLoading.value = false
}

/* ===========================================================
        BUSCAS AUXILIARES
=========================================================== */
const fetchCategories = async () => {
  const data = await getCategories()
  categoriesList.value = normalizeApiReturn(data)
}

const fetchEnvironments = async () => {
  const data = await getEnvironments()
  environmentsList.value = normalizeApiReturn(data)
}

/* ===========================================================
        DETALHES DO EQUIPAMENTO
=========================================================== */
const openEquipmentDetails = async (equipment: any) => {
  await fetchCategories()
  await fetchEnvironments()
  selectedEquipment.value = { ...equipment }
  showEquipmentDetailsModal.value = true
}

/* ===========================================================
        CRIAR ATIVO
=========================================================== */
const openCreateModal = async () => {
  if (!canCreateEquipment.value) {
    alert("Você não tem permissão para criar ativos.")
    return
  }

  await fetchCategories()
  await fetchEnvironments()
  showNewEquipmentModal.value = true
}

const handleSave = async (newData: any) => {
  await createEquipment(newData)
  await fetchEquipmentsData()
  showNewEquipmentModal.value = false
}

/* ===========================================================
        EDITAR ATIVO
=========================================================== */
const handleUpdate = async (updatedData: any) => {
  await updateEquipment(updatedData.id, updatedData)
  await fetchEquipmentsData()
  showEquipmentDetailsModal.value = false
}

/* ===========================================================
        EXCLUIR ATIVO
=========================================================== */
const handleDelete = async (id: number) => {
  if (!confirm("Tem certeza que deseja excluir este ativo?")) return
  await deleteEquipment(id)
  await fetchEquipmentsData()
  showEquipmentDetailsModal.value = false
}

/* ===========================================================
        WATCHERS & MOUNT
=========================================================== */
watch(searchQuery, fetchEquipmentsData)

onMounted(async () => {
  currentUser.value = await getCurrentUser()
  await fetchEquipmentsData()
})
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
        <input v-model="searchQuery" type="text" placeholder="Buscar por nome" />
      </div>

      <div class="actions-buttons">
        <button 
          v-if="canCreateEquipment" 
          class="btn-primary" 
          @click="openCreateModal"
        >
          + Novo Ativo
        </button>
      </div>

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

    <EquipmentDetailsModal
      v-if="showEquipmentDetailsModal"
      :equipment="selectedEquipment"
      :categoriesList="categoriesList"
      :environmentsList="environmentsList"
      @close="showEquipmentDetailsModal = false"
      @update="handleUpdate"
      @delete="handleDelete"
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

.clickable-row {
  cursor: pointer;
  transition: background-color 0.2s;
}

.clickable-row:hover {
  background-color: #f3f4f6;
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
