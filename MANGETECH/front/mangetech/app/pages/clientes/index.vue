<template>
  <div class="page-container">

    <!-- Cabeçalho -->
    <div class="header">
      <h1>Clientes</h1>
      <p>Gerencie seus clientes e informações de contato</p>
    </div>

    <!-- Barra de ações -->
    <div class="actions-bar">
      <!-- Campo de busca -->
      <div class="search-box">
        <span class="icon-search">🔍</span>
        <input
          v-model="filtro"
          type="text"
          placeholder="Buscar cliente..."
        />
      </div>

      <!-- Botão -->
      <div class="actions-buttons">
        <button class="btn-primary" @click="novoCliente">
          + Novo Cliente
        </button>
      </div>
    </div>

    <!-- Cards resumo -->
    <div class="cards-container">
      <div class="card total">
        <h3>Total de Clientes</h3>
        <p>{{ totalClientes }}</p>
      </div>
      <div class="card ativos">
        <h3>Clientes Ativos</h3>
        <p>{{ clientesAtivos }}</p>
      </div>
      <div class="card inativos">
        <h3>Clientes Inativos</h3>
        <p>{{ clientesInativos }}</p>
      </div>
    </div>

    <!-- Tabela -->
    <div v-if="clientesFiltrados.length > 0" class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>Nome</th>
            <th>CPF/CNPJ</th>
            <th>Email</th>
            <th>Tasks Criadas</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(cli, index) in clientesFiltrados" :key="index">
            <td>{{ cli.name }}</td>
            <td>{{ cli.nif || '—' }}</td>
            <td>{{ cli.email }}</td>
            <td>{{ cli.tasks_created }}</td>
            <td>
              <span :class="cli.is_active ? 'ativo' : 'inativo'">
                {{ cli.is_active ? 'Ativo' : 'Inativo' }}
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <p v-else class="empty-message">Nenhum cliente encontrado.</p>
  </div>
</template>



<script setup lang="ts">
definePageMeta({
  layout: 'dashboard-layout'
})

import { ref, onMounted, computed } from 'vue'
import { getUsers } from '~/services/user.service'

const clientes = ref([])
const filtro = ref("")

const normalizar = (text: string) =>
  text?.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase()

// ░░░░░░ FILTRO EM TEMPO REAL ░░░░░░
const clientesFiltrados = computed(() => {
  const f = normalizar(filtro.value)
  if (!f) return clientes.value

  return clientes.value.filter((cli: any) => {
    const nome = normalizar(cli.name || "")
    return nome.includes(f)
  })
})


// ░░░░░░ BUSCA DOS CLIENTES ░░░░░░
onMounted(async () => {
  try {
    const data = await getUsers()
    const users = data.results || []

    clientes.value = users.filter((user: any) =>
      user.groups?.some((g: string) => normalizar(g) === "cliente")
    )

  } catch (error) {
    console.error("Erro ao buscar clientes:", error)
  }
})

// ░░░░░░ CARDS - TOTAL / ATIVOS / INATIVOS ░░░░░░
const totalClientes = computed(() => clientes.value.length)
const clientesAtivos = computed(() =>
  clientes.value.filter((c: any) => c.is_active).length
)
const clientesInativos = computed(() =>
  clientes.value.filter((c: any) => !c.is_active).length
)


// ░░░░░░ BOTÃO "NOVO CLIENTE" ░░░░░░
const novoCliente = () => {
  // Ajuste para sua rota real
  navigateTo("/clientes/novo")
}
</script>

<style scoped lang="scss">
/* ======= TÍTULOS ======= */
.page-container {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* ======= Cabeçalho ======= */
.header h1 {
  font-size: 28px;
  font-weight: 600;
  color: #1f2937;
}

.header p {
  color: #6b7280;
  font-size: 14px;
}

/* ======= Barra de ações ======= */
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

/* 🎯 Botão */
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

/* ======= Cards ======= */
.cards-container {
  display: flex;
  gap: 18px;
}

.card {
  flex: 1;
  background: #fff;
  padding: 20px 24px;
  border-radius: 12px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 14px rgba(0, 0, 0, 0.08);
}

.card h3 {
  font-size: 14px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 6px;
}

.card p {
  font-size: 26px;
  font-weight: bold;
  color: #1f2937;
}

.total   { border-left: 4px solid #1e293b; }
.ativos  { border-left: 4px solid #047857; }
.inativos{ border-left: 4px solid #b91c1c; }

/* ======= Tabela ======= */
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
}

.data-table th,
.data-table td {
  padding: 14px 16px;
  border-bottom: 1px solid #e5e7eb;
  text-align: left;
  font-size: 14px;
}

.data-table tr:hover {
  background-color: #f9fafb;
}

/* 🔵 Status */
span.ativo {
  background-color: #d1fae5;
  color: #065f46;
  padding: 6px 10px;
  border-radius: 6px;
  font-weight: 600;
}

span.inativo {
  background-color: #fee2e2;
  color: #991b1b;
  padding: 6px 10px;
  border-radius: 6px;
  font-weight: 600;
}

.empty-message {
  text-align: center;
  color: #6b7280;
  padding: 20px;
}


</style>
