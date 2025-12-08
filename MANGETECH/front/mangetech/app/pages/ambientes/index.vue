<template>
  <section class="ambientes-page">

    <!-- CABEÇALHO -->
    <div class="header-bar">
      <div>
        <h1>Ambientes</h1>
        <p>Gerencie seus ambientes cadastrados no sistema</p>
      </div>
    </div>

    <!-- AÇÕES (Busca + Botão) -->
    <div class="actions-bar">
      <div class="search-box">
        <span class="icon-search">🔍</span>
        <input
          type="text"
          v-model="filtro"
          placeholder="Buscar ambiente..."
        />
      </div>

      <!-- 🔒 BOTÃO SÓ APARECE SE NÃO FOR CLIENTE -->
      <button 
        v-if="canCreateEnvironment"
        class="btn-primary" 
        @click="abrirNovoAmbiente"
      >
        + Novo Ambiente
      </button>
    </div>

    <!-- LISTA DE AMBIENTES -->
    <div class="grid-container" v-if="ambientesFiltrados.length">
      <div
        class="ambiente-card"
        v-for="(amb, index) in ambientesFiltrados"
        :key="amb.id ?? index"
        @click="abrirEditarAmbiente(amb)"
        style="cursor:pointer"
      >
        <div class="ambiente-header">
          <h3>{{ amb.name }}</h3>
        </div>

        <div class="ambiente-info">
          <p><strong>Responsável:</strong> {{ amb.user_FK?.name || 'Não informado' }}</p>
          <p><strong>Email:</strong> {{ amb.user_FK?.email || 'sem email' }}</p>
        </div>
      </div>
    </div>

    <!-- EMPTY -->
    <p v-else class="empty-message">Nenhum ambiente encontrado.</p>

    <!-- MODAL -->
    <EnvironmentModal
      v-if="showModal"
      :show="showModal"
      :modelValue="selectedAmbiente"
      :usersList="usersList"
      :isEdit="isEdit"
      @close="showModal = false"
      @submit="handleSave"
    />
  </section>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard-layout' })

import { ref, computed, onMounted } from 'vue'
import {
  getEnvironments,
  createEnvironment,
  updateEnvironment
} from '@/services/environment.services'

import { getUsers } from '@/services/user.service'
import { getCurrentUser } from '@/services/user.service'  // ✔ IMPORTANTE

import EnvironmentModal from '@/components/NewEnvironmentModal.vue'

/* =======================================================
          ESTADOS
======================================================= */
const ambientes = ref<any[]>([])
const filtro = ref('')
const showModal = ref(false)
const usersList = ref<any[]>([])
const isEdit = ref(false)
const selectedAmbiente = ref<any | null>(null)
const currentUser = ref<any>(null)

/* =======================================================
          PERMISSÃO — CLIENTE NÃO PODE CRIAR AMBIENTE
======================================================= */
const canCreateEnvironment = computed(() => {
  if (!currentUser.value) return false

  return (
    currentUser.value.groups?.includes("ADMIN") ||
    currentUser.value.groups?.includes("tecnico") ||
    currentUser.value.groups?.includes("Administrador") ||
    currentUser.value.groups?.includes("Técnico")
  )
})

/* =======================================================
          FILTRO
======================================================= */
const ambientesFiltrados = computed(() => {
  const term = filtro.value.toLowerCase()
  return ambientes.value.filter(a =>
    a.name?.toLowerCase().includes(term)
  )
})

/* =======================================================
          ABRIR MODAL DE NOVO
======================================================= */
const abrirNovoAmbiente = () => {

  // 🔒 BLOQUEIO PARA CLIENTE
  if (!canCreateEnvironment.value) {
    alert("Você não tem permissão para criar ambientes.")
    return
  }

  isEdit.value = false
  selectedAmbiente.value = {
    id: null,
    name: '',
    user_FK: '',
    description: '',
    is_active: true
  }
  showModal.value = true
}

/* =======================================================
          ABRIR MODAL DE EDIÇÃO
======================================================= */
const abrirEditarAmbiente = (amb: any) => {
  isEdit.value = true
  selectedAmbiente.value = { ...amb }
  showModal.value = true
}

/* =======================================================
          SALVAR
======================================================= */
const handleSave = async (data: any) => {
  try {
    const payload = {
      ...data,
      user_FK: typeof data.user_FK === 'object' ? data.user_FK.id : data.user_FK
    }

    if (isEdit.value) {
      await updateEnvironment(payload.id, payload)
    } else {
      await createEnvironment(payload)
    }

    await fetchAmbientes()
    showModal.value = false

  } catch (err) {
    console.error("Erro ao salvar ambiente:", err)
    alert("Erro ao salvar ambiente.")
  }
}

/* =======================================================
          BUSCAS
======================================================= */
const fetchAmbientes = async () => {
  const data = await getEnvironments()
  ambientes.value = data || []
}

const fetchUsers = async () => {
  const data = await getUsers()
  usersList.value = data.results || data || []
}

onMounted(async () => {
  currentUser.value = await getCurrentUser()   // ✔ AGORA TEM USUÁRIO
  await fetchAmbientes()
  await fetchUsers()
})
</script>

<style lang="css">
/* ❗ Mantido exatamente igual ao seu arquivo original */
.ambientes-page {
  display: flex;
  flex-direction: column;
  gap: 24px;
  padding: 24px;
}
.header-bar h1 {
  font-size: 2rem;
  font-weight: 700;
  color: #0b1225;
}
.header-bar p {
  font-size: 0.95rem;
  color: #6b7280;
}
.btn-primary {
  background: linear-gradient(135deg, #1e3a5f, #2346a4);
  color: #fff;
  padding: 12px 26px;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
}
.btn-primary:hover {
  background: #1e3a5f;
  box-shadow: 0 6px 16px rgba(0,0,0,0.15);
  transform: translateY(-2px);
}
.actions-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding: 18px;
  background-color: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  box-shadow: 0 3px 12px rgba(0,0,0,0.06);
}
.search-box {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
  max-width: 600px;
  padding: 12px 18px;
  background-color: #f9fafb;
  border: 1px solid #d1d5db;
  border-radius: 30px;
}
.search-box input {
  border: none;
  outline: none;
  background: transparent;
  width: 100%;
  font-size: 14px;
}
.grid-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 22px;
}
.ambiente-card {
  padding: 22px;
  border-radius: 16px;
  background: #ffffff;
  box-shadow: 0 6px 16px rgba(0,0,0,0.05);
}
.ambiente-info p {
  margin-bottom: 6px;
  font-size: 0.92rem;
  color: #374151;
}
.empty-message {
  text-align: center;
  padding: 20px;
  color: #6b7280;
  font-style: italic;
}
</style>
