<template>
  <section class="ativos-page">

    <!-- CABEÇALHO -->
    <div class="header-bar">
      <div>
        <h1>Equipamentos</h1>
        <p>Gerencie seus ativos e acompanhe seus registros</p>
      </div>

    </div>

    <!-- BARRA DE PESQUISA -->
    <div class="actions-bar">
      <div class="search-box">
        <span class="icon-search">🔍</span>
        <input
          type="text"
          v-model="filtro"
          placeholder="Buscar equipamento..."
        />
      </div>

      <button class="btn-primary" @click="novoEquipamento">
        + Novo Equipamento
      </button>
    </div>

    <!-- TABELA -->
    <div class="table-container" v-if="equipamentosFiltrados.length">
      <table class="data-table">
        <thead>
          <tr>
            <th>Nome</th>
            <th>Código</th>
            <th>Descrição</th>
            <th>Data de Criação</th>
            <th>Categoria</th>
            <th>Ambiente</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(equip, index) in equipamentosFiltrados" :key="index">
            <td>{{ equip.name }}</td>
            <td>{{ equip.code }}</td>
            <td>{{ equip.description }}</td>
            <td>{{ new Date(equip.creation_date).toLocaleDateString() }}</td>
            <td>{{ equip.category_FK || '—' }}</td>
            <td>{{ equip.environment_FK?.name || '—' }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <p v-else class="empty-message">Nenhum equipamento encontrado.</p>

  </section>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard-layout' })

import { ref, computed, onMounted } from 'vue'
import { getEquipments } from '@/services/equipment.services'

const equipamentos = ref([])
const filtro = ref('')

const equipamentosFiltrados = computed(() => {
  const f = filtro.value.toLowerCase()
  return equipamentos.value.filter(e =>
    e.name?.toLowerCase().includes(f) ||
    e.code?.toLowerCase().includes(f)
  )
})

const novoEquipamento = () => {
  navigateTo('/equipamentos/novo')
}

onMounted(async () => {
  try {
    const { data, error } = await getEquipments()
    if (error.value) console.error(error.value)
    equipamentos.value = data.value?.results || []
  } catch (err) {
    console.error('Erro ao buscar equipamentos:', err)
  }
})
</script>

<style scoped lang="scss">
.ativos-page {
  display: flex;
  flex-direction: column;
  gap: 24px;
  padding: 24px;
  font-family: 'Inter', sans-serif;
}

/* ===== CABEÇALHO ===== */
.header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;

  h1 {
    font-size: 1.9rem;
    font-weight: 600;
    color: #1e293b;
  }

  p {
    font-size: 0.95rem;
    color: #6b7280;
  }
}

/* ===== BOTÃO PADRÃO ===== */
.btn-primary {
  background-color: #1e293b;
  color: #fff;
  padding: 10px 22px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;

  &:hover {
    background-color: #172554;
    box-shadow: 0 6px 14px rgba(0, 0, 0, 0.15);
    transform: translateY(-2px);
  }

  &:active {
    transform: scale(0.98);
  }
}

/* ===== ACTIONS BAR (Filtro + Botão) ===== */
.actions-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background-color: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 14px;
  box-shadow: 0 3px 10px rgba(0, 0, 0, 0.06);
}

/* ===== CAMPO DE BUSCA ===== */
.search-box {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
  max-width: 600px;
  padding: 10px 16px;
  background-color: #f9fafb;
  border: 1px solid #d1d5db;
  border-radius: 30px;
  transition: all 0.3s ease;

  &:focus-within {
    border-color: #1e293b;
    box-shadow: 0 0 0 3px rgba(30, 41, 59, 0.25);
  }

  .icon-search {
    color: #6b7280;
    font-size: 15px;
  }

  input {
    border: none;
    outline: none;
    background: transparent;
    width: 100%;
    font-size: 14px;
    color: #374151;
  }
}

/* ===== TABELA ===== */
.table-container {
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  overflow-x: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  background-color: #fff;

  th {
    background-color: #f3f4f6;
    padding: 14px;
    text-align: left;
    font-weight: 600;
    color: #374151;
    font-size: 0.9rem;
  }

  td {
    padding: 14px;
    font-size: 0.95rem;
    color: #374151;
    border-bottom: 1px solid #e5e7eb;
  }

  tbody tr:hover {
    background-color: #f9fafb;
    transition: all 0.3s ease;
  }
}

/* ===== EMPTY ===== */
.empty-message {
  text-align: center;
  color: #6b7280;
  font-style: italic;
  padding: 20px;
}

/* ===== RESPONSIVO ===== */
@media (max-width: 900px) {
  .actions-bar {
    flex-direction: column;
    align-items: stretch;
  }

  .btn-primary {
    width: 100%;
  }
}
</style>
