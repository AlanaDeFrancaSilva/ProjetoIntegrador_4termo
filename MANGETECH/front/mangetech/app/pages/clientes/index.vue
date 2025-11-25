<template>
  <section class="clientes-page">
    
    <!-- Cabeçalho -->
    <div class="header-bar">
      <div>
        <h1 class="page-title">Clientes</h1>
        <p class="page-subtitle">Gerencie seus clientes e informações de contato</p>
      </div>

      <button class="btn-novo" @click="novoCliente">+ Novo Cliente</button>
    </div>

    <!-- Barra de Pesquisa -->
    <div class="search-box">
      <span class="search-icon">🔍</span>
      <input
        type="text"
        v-model="filtro"
        placeholder="Pesquisar cliente..."
      />
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
    <table v-if="clientesFiltrados.length > 0" class="table-clientes">
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

    <p v-else class="empty-message">Nenhum cliente encontrado.</p>
  </section>
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
.page-title {
  font-size: 1.9rem;
  font-weight: 600;
  color: #1e3a8a;
  margin-bottom: 4px;
}

.page-subtitle {
  font-size: 0.95rem;
  color: #64748b;
}

/* ======= HEADER COM BOTÃO ======= */
.header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.btn-novo {
  background-color: #1e3a8a;
  color: white;
  padding: 10px 20px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  font-weight: 600;
  transition: 0.3s ease;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);

  &:hover {
    background-color: #16224f;
  }
}

/* ======= BARRA DE PESQUISA ======= */
.search-box {
  position: relative;
  margin-bottom: 25px;
}

.search-box input {
  width: 100%;
  padding: 12px 14px 12px 40px;
  border: 1px solid #dadce0;
  border-radius: 10px;
  font-size: 1rem;
  outline: none;
  transition: 0.3s;
}

.search-box input:focus {
  border-color: #1e3a8a;
  box-shadow: 0 0 0 2px rgba(30, 58, 138, 0.2);
}

.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #6b7280;
}

/* ======= CARDS RESUMO ======= */
.cards-container {
  display: flex;
  gap: 20px;
  margin-bottom: 25px;
}

.card {
  flex: 1;
  background: #fff;
  padding: 20px 24px;
  border-radius: 12px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.06);

  h3 {
    font-size: 0.9rem;
    color: #475569;
    margin-bottom: 6px;
  }

  p {
    font-size: 2rem;
    font-weight: 700;
    color: #0f172a;
  }

  &.total { border-left: 5px solid #1e3a8a; }
  &.ativos { border-left: 5px solid #047857; }
  &.inativos { border-left: 5px solid #b91c1c; }
}

/* ======= TABELA ======= */
.table-clientes {
  width: 100%;
  border-collapse: collapse;
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.table-clientes thead {
  background: #f8fafc;
}

.table-clientes th {
  padding: 14px;
  text-align: left;
  color: #475569;
  font-size: 14px;
  font-weight: 600;
}

.table-clientes td {
  padding: 14px;
  color: #374151;
  font-size: 14px;
  border-bottom: 1px solid #e5e7eb;
}

.table-clientes tr:hover {
  background-color: #f9fafb;
}

/* ======= BADGES DE STATUS ======= */
span.ativo {
  background: #d1fae5;
  color: #065f46;
  padding: 6px 10px;
  border-radius: 5px;
  font-weight: 600;
}

span.inativo {
  background: #fee2e2;
  color: #991b1b;
  padding: 6px 10px;
  border-radius: 5px;
  font-weight: 600;
}

/* ======= NENHUM CLIENTE ======= */
.empty-message {
  padding: 20px;
  text-align: center;
  color: #6b7280;
}

</style>
