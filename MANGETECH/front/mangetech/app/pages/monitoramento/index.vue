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
        <p class="title">Chamados em Aberto</p>
        <h2>{{ chamadosAbertos }}</h2>
      </div>

      <div class="info-card">
        <p class="title">Mensagens</p>
        <h2>{{ mensagens }}</h2>
      </div>

      <div class="info-card">
        <p class="title">Total de Clientes</p>
        <h2>{{ totalClientes }}</h2>
      </div>
    </div>

    <!-- GRAFICOS + AGENDA -->
    <div class="grid-main">
      <div class="chart-card">
        <h3>Distribuição de Chamados por Status</h3>
        <canvas id="statusChart"></canvas>
      </div>

      <div class="agenda-card">
        <div class="agenda-header">
          <h3>Agenda</h3>
          <div class="calendar-nav">
            <button type="button" @click="prevMonth">‹</button>
            <span>{{ monthLabel }}</span>
            <button type="button" @click="nextMonth">›</button>
          </div>
        </div>

        <div class="calendar">
          <div class="calendar-weekdays">
            <span v-for="day in weekdays" :key="day">{{ day }}</span>
          </div>

          <div class="calendar-grid">
            <button
              v-for="(day, index) in calendarDays || []"
              :key="index"
              type="button"
              class="calendar-day"
              :class="{
                'other-month': !day.isCurrentMonth,
                'has-agenda': day.items?.length,
                'selected': selectedDate && sameDay(day.date, selectedDate)
              }"
              @click="selectDay(day)"
            >
              <span class="day-number">{{ day.date.getDate() }}</span>
              <span v-if="day.items?.length" class="dot"></span>
            </button>
          </div>
        </div>

        <div v-if="selectedItems?.length" class="agenda-details">
          <h4>Compromissos de {{ selectedDateFormatted }}</h4>
          <ul>
            <li v-for="item in selectedItems" :key="item.id">{{ item.tarefa }}</li>
          </ul>
        </div>

        <p v-else class="agenda-empty">Nenhum compromisso para o dia selecionado.</p>
      </div>
    </div>

  </section>
</template>

<script setup>
definePageMeta({ layout: 'dashboard-layout' })

import { ref, computed, onMounted, onUnmounted } from 'vue'
import { getCurrentUser } from '~/services/auth.services'
import { getTasks } from '~/services/task.services'
import { getUsers } from '~/services/user.service'
import { Chart, registerables } from 'chart.js'
Chart.register(...registerables)

// STATES
const user = ref(null)
const chamadosAbertos = ref(0)
const mensagens = ref(0)
const totalClientes = ref(0)
const chamados = ref([])

// Função robusta para status
const getLatestStatus = (task) => {
  return (
    task?.TaskStatus_task_FK?.at(-1)?.status ||
    task?.latest_status ||
    task?.status ||
    ''
  )?.toString().trim().toUpperCase()
}

// Normalizar texto
const normalize = (str) =>
  str?.toString().toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "") || ''

// FETCH DATA
onMounted(async () => {
  try {
    user.value = await getCurrentUser()

    const tasksData = await getTasks()
    chamados.value = tasksData?.data?.value?.results || tasksData?.data?.results || tasksData || []

    console.log("📝 Status real de cada chamado:", chamados.value.map(t => ({
      id: t.id,
      status: getLatestStatus(t)
    })))

    // Agora só conta OPEN e ONGOING
    chamadosAbertos.value = chamados.value.filter(t => {
  const status = getLatestStatus(t)

  return (
    status === 'OPEN' ||     // Aberto
    status === 'WAITING_RESPONSIBLE' || // Aguardando responsável
    status === 'ONGOING'    // Em andamento
  )
}).length
    mensagens.value = chamados.value.filter(t => normalize(t.type) === 'mensagem').length

    const users = await getUsers()
    totalClientes.value = users.results ? users.results.length : users.length

    renderCharts()
  } catch (error) {
    console.error('Erro ao carregar dados:', error)
  }
})

/* ==================== GRÁFICO ==================== */
let statusChartInstance = null

function renderCharts() {
  const statusCounts = chamados.value.reduce((acc, item) => {
    const status = getLatestStatus(item) || 'NÃO INFORMADO'
    acc[status] = (acc[status] || 0) + 1
    return acc
  }, {})

  const ctx1 = document.getElementById('statusChart')

  if (statusChartInstance) {
    statusChartInstance.destroy()
    statusChartInstance = null
  }

  if (ctx1) {
    statusChartInstance = new Chart(ctx1, {
      type: 'pie',
      data: {
        labels: Object.keys(statusCounts),
        datasets: [{ data: Object.values(statusCounts) }]
      },
      options: {
        plugins: { legend: { position: 'bottom' } },
        maintainAspectRatio: false,
        responsive: true
      }
    })
  }
}

// Limpa gráfico ao sair da página
onUnmounted(() => {
  if (statusChartInstance) statusChartInstance.destroy()
})

/* ==================== CALENDÁRIO ==================== */
const currentMonth = ref(new Date())
const selectedDate = ref(new Date())

const weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
const monthNames = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
]

const monthLabel = computed(() =>
  `${monthNames[currentMonth.value.getMonth()]} de ${currentMonth.value.getFullYear()}`
)

const agenda = [
  { id: 1, dia: 'Segunda', tarefa: 'Revisar chamados pendentes' },
  { id: 2, dia: 'Terça', tarefa: 'Visita técnica' },
  { id: 3, dia: 'Quarta', tarefa: 'Instalação de equipamentos' },
  { id: 4, dia: 'Quinta', tarefa: 'Treinamento' },
  { id: 5, dia: 'Sexta', tarefa: 'Revisão final' }
]

const weekdayMap = {
  0: 'Domingo', 1: 'Segunda', 2: 'Terça',
  3: 'Quarta', 4: 'Quinta', 5: 'Sexta', 6: 'Sábado'
}

const getAgendaItemsForDate = (date) =>
  agenda.filter(a => a.dia === weekdayMap[date.getDay()])

const calendarDays = computed(() => {
  const year = currentMonth.value.getFullYear()
  const month = currentMonth.value.getMonth()
  const days = []

  const firstDayOfMonth = new Date(year, month, 1)
  const firstWeekday = firstDayOfMonth.getDay()
  const daysInMonth = new Date(year, month + 1, 0).getDate()
  const daysInPrevMonth = new Date(year, month, 0).getDate()

  for (let i = firstWeekday - 1; i >= 0; i--) {
    const date = new Date(year, month - 1, daysInPrevMonth - i)
    days.push({ date, isCurrentMonth: false, items: getAgendaItemsForDate(date) })
  }

  for (let d = 1; d <= daysInMonth; d++) {
    const date = new Date(year, month, d)
    days.push({ date, isCurrentMonth: true, items: getAgendaItemsForDate(date) })
  }

  let nextDay = 1
  while (days.length % 7 !== 0) {
    const date = new Date(year, month + 1, nextDay++)
    days.push({ date, isCurrentMonth: false, items: getAgendaItemsForDate(date) })
  }

  return days
})

const sameDay = (d1, d2) =>
  d1?.getFullYear() === d2?.getFullYear() &&
  d1?.getMonth() === d2?.getMonth() &&
  d1?.getDate() === d2?.getDate()

const selectedItems = computed(() =>
  selectedDate.value ? getAgendaItemsForDate(selectedDate.value) : []
)

const selectedDateFormatted = computed(() =>
  selectedDate.value ? selectedDate.value.toLocaleDateString() : ''
)

const prevMonth = () => {
  const d = new Date(currentMonth.value)
  d.setMonth(d.getMonth() - 1)
  currentMonth.value = d
}

const nextMonth = () => {
  const d = new Date(currentMonth.value)
  d.setMonth(d.getMonth() + 1)
  currentMonth.value = d
}

const selectDay = (day) => {
  selectedDate.value = day.date
}
</script>


<style scoped lang="scss">
.monitoramento {
  display: flex;
  flex-direction: column;
  gap: 32px;
  padding: 28px;
  font-family: 'Inter', sans-serif;
  color: #1e293b;
  background-color: #f8fafc;
}

/* ====== HEADER ====== */
.header-card {
  background: linear-gradient(90deg, #1e293b, #1e3a8a);
  padding: 36px;
  border-radius: 16px;
  color: #ffffff;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;

  h2 {
    font-size: 1.8rem;
    font-weight: 600;
    margin-bottom: 6px;
  }

  p {
    font-size: 0.95rem;
    opacity: 0.9;
  }
}

/* ====== CARDS SUPERIORES ====== */
.cards-row {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
}

.info-card {
  flex: 1;
  min-width: 260px;
  background: #ffffff;
  border-radius: 14px;
  padding: 24px 28px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  border: 1px solid #e2e8f0;
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 10px 22px rgba(0, 0, 0, 0.08);
  }

  .title {
    font-size: 0.85rem;
    color: #6b7280;
    font-weight: 500;
    letter-spacing: 0.3px;
  }

  h2 {
    font-size: 2rem;
    font-weight: 700;
    color: #1e293b;
  }
}

/* ====== GRID PRINCIPAL ====== */
.grid-main {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 28px;

  @media (max-width: 900px) {
    grid-template-columns: 1fr;
  }
}

/* ====== CARD DE GRÁFICO ====== */
.chart-card {
  background: #ffffff;
  padding: 24px;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  text-align: center;
}

.chart-card canvas {
  width: 100% !important;
  max-width: 500px;
  height: 280px !important;
  margin: 0 auto;
}
/* ====== CARD AGENDA ====== */
.agenda-card {
  background: #ffffff;
  padding: 20px 22px 24px;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.agenda-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;

  h3 {
    font-size: 1rem;
    font-weight: 600;
    color: #1e293b;
  }
}

.calendar-nav {
  display: flex;
  align-items: center;
  gap: 8px;

  span {
    font-size: 0.9rem;
    font-weight: 500;
    color: #374151;
  }

  button {
    border: none;
    background: #e5e7eb;
    border-radius: 999px;
    width: 24px;
    height: 24px;
    cursor: pointer;
    font-size: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background-color 0.2s ease;

    &:hover {
      background: #d1d5db;
    }
  }
}

/* ====== CALENDÁRIO ====== */
.calendar {
  margin-top: 8px;
}

.calendar-weekdays {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  margin-bottom: 4px;
  font-size: 0.75rem;
  text-align: center;
  color: #6b7280;
}

.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
}

.calendar-day {
  position: relative;
  border: none;
  background: transparent;
  border-radius: 8px;
  padding: 6px 0;
  cursor: pointer;
  font-size: 0.8rem;
  color: #111827;
  transition: background-color 0.2s ease, color 0.2s ease;
}

.calendar-day .day-number {
  display: block;
}

.calendar-day.other-month {
  color: #9ca3af;
}

.calendar-day.has-agenda .day-number {
  font-weight: 600;
}

.calendar-day.selected {
  background: #1e3a8a;
  color: #ffffff;
}

.calendar-day.selected .dot {
  background: #22c55e;
}

.dot {
  position: absolute;
  bottom: 4px;
  left: 50%;
  transform: translateX(-50%);
  width: 6px;
  height: 6px;
  border-radius: 999px;
  background: #1e3a8a;
}

/* ====== DETALHES DA AGENDA ====== */
.agenda-details {
  margin-top: 14px;
  padding-top: 10px;
  border-top: 1px solid #e5e7eb;

  h4 {
    font-size: 0.9rem;
    font-weight: 600;
    margin-bottom: 6px;
    color: #1e293b;
  }

  ul {
    list-style: none;
    padding: 0;
    margin: 0;

    li {
      font-size: 0.85rem;
      padding: 6px 0;
      color: #374151;
    }
  }
}

.agenda-empty {
  margin-top: 12px;
  font-size: 0.85rem;
  color: #6b7280;
  font-style: italic;
}

/* ====== RESPONSIVO EXTRA ====== */
@media (max-width: 768px) {
  .monitoramento {
    padding: 18px;
  }

  .info-card {
    min-width: 100%;
  }

  .header-card {
    padding: 26px;
  }
}

</style>
