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

    <!-- GRAFICO + AGENDA -->
    <div class="grid-main">
      <div class="chart-card">
        <h3>Análise de Chamados</h3>
        <div class="chart-placeholder">
          📊 Gráfico em construção
        </div>
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

        <!-- CALENDÁRIO -->
        <div class="calendar">
          <div class="calendar-weekdays">
            <span v-for="day in weekdays" :key="day">{{ day }}</span>
          </div>

          <div class="calendar-grid">
            <button
              v-for="(day, index) in calendarDays"
              :key="index"
              type="button"
              class="calendar-day"
              :class="{
                'other-month': !day.isCurrentMonth,
                'has-agenda': day.items.length,
                'selected': selectedDate && sameDay(day.date, selectedDate)
              }"
              @click="selectDay(day)"
            >
              <span class="day-number">{{ day.date.getDate() }}</span>
              <span v-if="day.items.length" class="dot"></span>
            </button>
          </div>
        </div>

        <!-- DETALHES DO DIA -->
        <div v-if="selectedItems.length" class="agenda-details">
          <h4>Compromissos de {{ selectedDateFormatted }}</h4>
          <ul>
            <li v-for="item in selectedItems" :key="item.id">
              {{ item.tarefa }}
            </li>
          </ul>
        </div>
        <p v-else class="agenda-empty">
          Nenhum compromisso para o dia selecionado.
        </p>
      </div>
    </div>

  </section>
</template>

<script setup>
definePageMeta({
  layout: 'dashboard-layout'
})

import { ref, computed, onMounted } from 'vue'
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

// Agenda fixa (por dia da semana)
const agenda = [
  { id: 1, dia: 'Segunda', tarefa: 'Revisar chamados pendentes' },
  { id: 2, dia: 'Terça', tarefa: 'Visita técnica' },
  { id: 3, dia: 'Quarta', tarefa: 'Instalação de equipamentos' },
  { id: 4, dia: 'Quinta', tarefa: 'Treinamento' },
  { id: 5, dia: 'Sexta', tarefa: 'Revisão final' }
]

// ----------------------------------------
// 📆 LÓGICA DO CALENDÁRIO
// ----------------------------------------
const currentMonth = ref(new Date())       // referência do mês atual
const selectedDate = ref(new Date())

const weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
const monthNames = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
]

const monthLabel = computed(() => {
  const d = currentMonth.value
  return `${monthNames[d.getMonth()]} de ${d.getFullYear()}`
})

const weekdayMap = {
  0: 'Domingo',
  1: 'Segunda',
  2: 'Terça',
  3: 'Quarta',
  4: 'Quinta',
  5: 'Sexta',
  6: 'Sábado'
}

const getAgendaItemsForDate = (date) => {
  const weekdayName = weekdayMap[date.getDay()]
  return agenda.filter(a => a.dia === weekdayName)
}

const calendarDays = computed(() => {
  const year = currentMonth.value.getFullYear()
  const month = currentMonth.value.getMonth()

  const firstDayOfMonth = new Date(year, month, 1)
  const firstWeekday = firstDayOfMonth.getDay() // 0-6
  const daysInMonth = new Date(year, month + 1, 0).getDate()
  const daysInPrevMonth = new Date(year, month, 0).getDate()

  const days = []

  // Dias do mês anterior para preencher o início (se a semana não começa em domingo)
  for (let i = firstWeekday - 1; i >= 0; i--) {
    const date = new Date(year, month - 1, daysInPrevMonth - i)
    days.push({
      date,
      isCurrentMonth: false,
      items: getAgendaItemsForDate(date)
    })
  }

  // Dias do mês atual
  for (let d = 1; d <= daysInMonth; d++) {
    const date = new Date(year, month, d)
    days.push({
      date,
      isCurrentMonth: true,
      items: getAgendaItemsForDate(date)
    })
  }

  // Completar com dias do próximo mês para fechar a grade (múltiplo de 7)
  let nextDay = 1
  while (days.length % 7 !== 0) {
    const date = new Date(year, month + 1, nextDay++)
    days.push({
      date,
      isCurrentMonth: false,
      items: getAgendaItemsForDate(date)
    })
  }

  return days
})

const sameDay = (d1, d2) => {
  return (
    d1.getFullYear() === d2.getFullYear() &&
    d1.getMonth() === d2.getMonth() &&
    d1.getDate() === d2.getDate()
  )
}

const selectedItems = computed(() => {
  if (!selectedDate.value) return []
  return getAgendaItemsForDate(selectedDate.value)
})

const selectedDateFormatted = computed(() => {
  if (!selectedDate.value) return ''
  return selectedDate.value.toLocaleDateString()
})

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

// ----------------------------------------
// 📌 FETCH DOS DADOS REAIS
// ----------------------------------------
onMounted(async () => {
  try {
    user.value = await getCurrentUser()

    const tasks = await getTasks()
    chamadosAbertos.value = tasks.results.filter(t => t.status === 'aberto').length
    mensagens.value = tasks.results.filter(t => t.type === 'mensagem').length

    const users = await getUsers()
    totalClientes.value = users.length
  } catch (error) {
    console.error('Erro ao carregar dados:', error)
  }
})
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

  h3 {
    font-size: 1rem;
    font-weight: 600;
    margin-bottom: 14px;
    color: #1e293b;
  }
}

.chart-placeholder {
  height: 260px;
  border-radius: 12px;
  background: #f1f5f9;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #636e75;
  font-size: 15px;
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
