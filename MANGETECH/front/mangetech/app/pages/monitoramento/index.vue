<template>
  <section class="monitoramento">

    <!-- SAUDAÇÃO -->
    <div class="header-card">
      <div>
        <h2 v-if="user">Olá {{ user.name }}</h2>
        <p v-if="user">{{ user.email }}</p>
        <p v-else>Carregando...</p>
      </div>
    </div>

    <!-- CARDS SUPERIORES -->
    <div class="cards-row">

      <div class="info-card">
        <div class="icon blue">📞</div>
        <div>
          <p class="title">Chamados em aberto</p>
          <h2>{{ chamadosAbertos }}</h2>
        </div>
      </div>

      <div class="info-card">
        <div class="icon purple">💬</div>
        <div>
          <p class="title">Mensagens</p>
          <h2>{{ mensagens }}</h2>
        </div>
      </div>

      <div class="info-card">
        <div class="icon dark">👥</div>
        <div>
          <p class="title">Total de Clientes</p>
          <h2>{{ totalClientes }}</h2>
        </div>
      </div>

    </div>

    <!-- GRAFICO + AGENDA -->
    <div class="grid-main">
      <div class="chart-card">
        <h3>Análise de Chamados</h3>
        <div class="chart-placeholder">
          📊 Gráfico em construção
        </div>
      </div>

      <div class="agenda-card">
        <h3>Agenda da Semana</h3>

        <ul class="agenda-list">
          <li v-for="item in agenda" :key="item.id">
            <strong>{{ item.dia }}</strong>
            <span>{{ item.tarefa }}</span>
          </li>
        </ul>
      </div>
    </div>

  </section>
</template>

<script setup>
definePageMeta({
  layout: 'dashboard-layout'
})

// IMPORTANDO SERVICES
import { getCurrentUser } from '~/services/auth.services'
import { getTasks } from '~/services/task.services'
import { getUsers } from '~/services/user.service'

// ----------------------------------------
// 📌 STATES
// ----------------------------------------
const user = ref(null)

const chamadosAbertos = ref(0)
const mensagens = ref(0)
const totalClientes = ref(0)

// Agenda fixa (pode vir do backend depois)
const agenda = [
  { id: 1, dia: "Segunda", tarefa: "Revisar chamados pendentes" },
  { id: 2, dia: "Terça", tarefa: "Visita técnica" },
  { id: 3, dia: "Quarta", tarefa: "Instalação de equipamentos" },
  { id: 4, dia: "Quinta", tarefa: "Treinamento" },
  { id: 5, dia: "Sexta", tarefa: "Revisão final" },
]

// ----------------------------------------
// 📌 FETCH DOS DADOS REAIS
// ----------------------------------------

onMounted(async () => {
  try {
    // Usuário logado
    user.value = await getCurrentUser()

    // Chamados
    const tasks = await getTasks()
    chamadosAbertos.value = tasks.results.filter(t => t.status === "aberto").length

    // Mensagens (exemplo: tasks de tipo "mensagem")
    mensagens.value = tasks.results.filter(t => t.type === "mensagem").length

    // Total de clientes (você não enviou o service de clientes)
    // usando getUsers() até você me mandar o endpoint correto
    const users = await getUsers()
    totalClientes.value = users.length

  } catch (error) {
    console.error("Erro ao carregar dados:", error)
  }
})
</script>

<style scoped>
.monitoramento {
  padding: 25px 30px;
}

/* SAUDAÇÃO */
.header-card {
  background: linear-gradient(90deg, #1e3a8a, #1e40af, #1d4ed8);
  padding: 28px;
  border-radius: 18px;
  color: #fff;
  box-shadow: 0 4px 10px #0003;
}

/* CARDS */
.cards-row {
  margin-top: 25px;
  display: flex;
  gap: 18px;
}

.info-card {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px;
  background: #f8fafc;
  border-radius: 14px;
  box-shadow: 0 2px 10px #0001;
}

.icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
}

.blue { background: #dbeafe; color: #1e40af; }
.purple { background: #ede9fe; color: #6d28d9; }
.dark { background: #e2e8f0; color: #1e293b; }

/* GRID PRINCIPAL */
.grid-main {
  margin-top: 28px;
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
}

/* GRAFICO */
.chart-card {
  background: #fff;
  padding: 20px;
  border-radius: 14px;
  box-shadow: 0 2px 8px #0001;
}

.chart-placeholder {
  background: #f1f5f9;
  height: 250px;
  border-radius: 12px;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #64748b;
  font-size: 15px;
}

/* AGENDA */
.agenda-card {
  background: #fff;
  padding: 20px;
  border-radius: 14px;
  box-shadow: 0 2px 8px #0002;
}

.agenda-list {
  margin-top: 15px;
  list-style: none;
  padding: 0;
}

.agenda-list li {
  display: flex;
  justify-content: space-between;
  padding: 10px 12px;
  background: #f8fafc;
  border-radius: 10px;
  margin-bottom: 10px;
  font-size: 14px;
}
</style>
