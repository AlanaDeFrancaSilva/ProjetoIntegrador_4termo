<template>
  <div class="page-container">

    <!-- Cabeçalho -->
    <div class="header">
      <h1>Clientes</h1>
      <p>Gerencie seus clientes e informações de contato</p>
    </div>

    <!-- Barra de ações -->
    <div class="actions-bar">
      <div class="search-box">
        <span class="icon-search">🔍</span>
        <input v-model="filtro" type="text" placeholder="Buscar cliente..." />
      </div>

      <div class="actions-buttons">
        <button class="btn-primary" @click="abrirNovoCliente">
          + Novo Cliente
        </button>
      </div>
    </div>

    <!-- Cards resumo -->
    <div class="cards-container">
      <div class="card total"><h3>Total</h3><p>{{ totalClientes }}</p></div>
      <div class="card ativos"><h3>Ativos</h3><p>{{ clientesAtivos }}</p></div>
      <div class="card inativos"><h3>Inativos</h3><p>{{ clientesInativos }}</p></div>
    </div>

    <!-- Tabela -->
    <div v-if="clientesFiltrados.length > 0" class="table-container">
      <table class="data-table">
  <thead>
    <tr>
      <th>Nome</th>
      <th>CPF/CNPJ</th>
      <th>Email</th>
      <th>Chamados</th>
      <th>Status</th>
    </tr>
  </thead>
  <tbody>
    <tr
      v-for="(cli, index) in clientesFiltrados"
      :key="index"
      @click="abrirEditarCliente(cli)"
      class="clickable-row"
    >
      <td>{{ cli.name }}</td>
      <td>{{ cli.nif || '—' }}</td>
      <td>{{ cli.email }}</td>
      <td>{{ cli.chamados || cli.tasks_created || 0 }}</td>
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

    <!-- Modal de Cliente -->
    <ClienteModal
      :show="exibirModal"
      v-model="formCliente"
      :isEdit="isEdit"
      @submit="salvarCliente"
      @close="fecharModal"
    />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard-layout' })

import { ref, onMounted, computed } from 'vue'
import { getUsers, createUser, updateUser } from '~/services/user.service'
import ClienteModal from '~/components/ClienteModel.vue'

const exibirModal = ref(false)
const isEdit = ref(false)

const clientes = ref([])
const filtro = ref("")

const formCliente = ref({
  id: null,
  name: "",
  email: "",
  nif: "",
  password: "",
  is_active: true,
})

const normalizar = (text: string) =>
  text?.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase()

// Filtro em tempo real
const clientesFiltrados = computed(() => {
  const f = normalizar(filtro.value)
  if (!f) return clientes.value

  return clientes.value.filter((cli: any) =>
    normalizar(cli.name).includes(f)
  )
})

// Buscar clientes
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

// Cards resumo
const totalClientes = computed(() => clientes.value.length)
const clientesAtivos = computed(() => clientes.value.filter(c => c.is_active).length)
const clientesInativos = computed(() => clientes.value.filter(c => !c.is_active).length)

// Ações para abrir modal
const abrirNovoCliente = () => {
  isEdit.value = false
  formCliente.value = { name: "", email: "", nif: "", is_active: true }
  exibirModal.value = true
}

const abrirEditarCliente = (cliente: any) => {
  isEdit.value = true
  formCliente.value = {
    id: cliente.id ?? cliente.pk ?? cliente.user?.id,
    name: cliente.name,
    email: cliente.email,
    nif: cliente.nif,
    is_active: cliente.is_active,
  }
  console.log("Cliente carregado para edição:", formCliente.value)
  exibirModal.value = true
}


const fecharModal = () => exibirModal.value = false

// Salvar cliente (criar ou editar)
const salvarCliente = async (data: any) => {
  try {
    if (isEdit.value) {
      // 🟢 Agora tem ID garantido
      const atualizado = await updateUser(data.id, data)

      const index = clientes.value.findIndex(c => c.id === data.id)
      if (index !== -1) clientes.value[index] = atualizado

      alert("Cliente atualizado com sucesso!")
    } else {
      const novoCliente = await createUser({ ...data, groups: ['cliente'] })
      clientes.value.push(novoCliente)
      alert("Cliente criado com sucesso!")
    }

    exibirModal.value = false
  } catch (err: any) {
  console.error("Erro ao criar cliente:", err)
  alert("Erro ao criar cliente: " + err.message)
}
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
.btn-edit {
  background: #e2e8f0;
  padding: 6px 12px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
}
.btn-edit:hover {
  background: #cbd5e1;
}


</style>
