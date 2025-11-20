<template>
  <section class="clientes-page">
    <div class="header-bar">
      <div>
        <h1>Clientes</h1>
        <h4>Gerencie seus clientes e informações de contato</h4>
      </div>

      <button class="btn-novo" @click="novoCliente">
        + Novo Cliente
      </button>
    </div>

    <!-- Barra de Pesquisa -->
    <div class="search-box">
      <input
        type="text"
        v-model="filtro"
        placeholder="Pesquisar cliente..."
      />
    </div>

    <!-- Cards de resumo -->
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


    <table v-if="clientesFiltrados.length > 0">
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
            <span
              :class="{
                ativo: cli.is_active,
                inativo: !cli.is_active
              }"
            >
              {{ cli.is_active ? 'Ativo' : 'Inativo' }}
            </span>
          </td>
        </tr>
      </tbody>
    </table>

    <p v-else>Nenhum cliente encontrado.</p>
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
.clientes-page {
  h1 {
    font-size: 1.8rem;
    margin-bottom: 5px;
    color: #1e293b;
  }

  h4 {
    color: #64748b;
    margin-bottom: 20px;
  }
}

/* ---------- Header com botão ---------- */
.header-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

/* ---------- Botão "+ Novo Cliente" ---------- */
.btn-novo {
  background-color: #1e1b4b;
  color: white;
  padding: 10px 18px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  font-weight: 600;
  transition: 0.2s;

  &:hover {
    background-color: #312e81;
  }
}

/* ---------- Barra de pesquisa ---------- */
.search-box {
  margin: 20px 0;

  input {
    width: 100%;
    padding: 12px 14px;
    border-radius: 10px;
    border: 1px solid #d1d5db;
    font-size: 1rem;
  }
}

/* ---------- Cards de resumo ---------- */
.cards-container .card {
  height: 120px;
  display: flex;
  flex-direction: column;
  justify-content: center;   /* centraliza verticalmente */
  align-items: flex-start;   /* mantém alinhado à esquerda */
  padding-bottom: 10px;      /* opcional, para deixar mais bonito */
}


.cards-container {
  display: flex;
  gap: 20px;
  margin-bottom: 25px;

  .card {
    flex: 1;
    background: #fff;
    padding: 18px;
    border-radius: 12px;
    box-shadow: 0 2px 6px rgba(0,0,0,0.06);
    display: flex;
    flex-direction: column;
    gap: 5px;


    h3 {
      font-size: 1rem;
      font-weight: 600;
      color: #475569;
      margin-top: 8px;
    }

    p {
      font-size: 1.8rem;
      font-weight: bold;
      color: #0f172a;
    }
  }

  .total {
    border-left: 5px solid #1e3a8a;
  }

  .ativos {
    border-left: 5px solid #047857;
  }

  .inativos {
    border-left: 5px solid #b91c1c;
  }
}

/* ---------- Tabela ---------- */
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
      }
    }

    tr:hover {
      background-color: #f9fafb;
    }
  }
}

/* ---------- Status ---------- */
span.ativo {
  background-color: #d1fae5;
  color: #065f46;
  border-radius: 6px;
  padding: 4px 8px;
  font-weight: 600;
}
span.inativo {
  background-color: #fee2e2;
  color: #991b1b;
  border-radius: 6px;
  padding: 4px 8px;
  font-weight: 600;
}
</style>
