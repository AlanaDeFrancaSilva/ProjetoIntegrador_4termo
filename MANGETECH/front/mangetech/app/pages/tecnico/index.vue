<template>
  <section class="tecnicos-page">
    <h1>Técnicos</h1>
    <h4>Membros Ativos</h4>    

    <table v-if="tecnicos.length > 0">
      <thead>
        <tr>
          <th>Nome</th>
          <th>Função</th>
          <th>Telefone</th>
          <th>Email</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(tec, index) in tecnicos" :key="index">
          <td>{{ tec.name }}</td>
          <td>{{ tec.groups?.[0] || '—' }}</td>
          <td>{{ tec.phone || '—' }}</td>
          <td>{{ tec.email }}</td>
          <td>
            <span
              :class="{
                ativo: tec.is_active,
                inativo: !tec.is_active
              }"
            >
              {{ tec.is_active ? 'Ativo' : 'Inativo' }}
            </span>
          </td>
        </tr>
      </tbody>
    </table>

    <p v-else>Nenhum técnico encontrado.</p>
  </section>
</template>


<script setup lang="ts">
definePageMeta({
  layout: 'dashboard-layout'
})

import { ref, onMounted } from 'vue'
import { getUsers } from '~/services/user.service'

const tecnicos = ref([])

onMounted(async () => {
  try {
    const data = await getUsers()

    console.log("Dados brutos:", data)
    console.log("Usuários:", data.results)

    const users = data.results || []

    tecnicos.value = users.filter((user: any) =>
      user.groups?.some(
        (g: string) =>
          g.toLowerCase() === 'técnico' || g.toLowerCase() === 'tecnico'
      )
    )

    console.log("Técnicos filtrados:", tecnicos.value)
  } catch (error) {
    console.error('Erro ao buscar técnicos:', error)
  }
})

//console
onMounted(async () => {
  try {
    const data = await getUsers()
    console.log('Usuários retornados:', data)

    console.log('Usuários retornados:', data)
    tecnicos.value = data.filter((user: any) =>
      user.groups?.some(
        (g: string) => g.toLowerCase() === 'técnico' || g.toLowerCase() === 'tecnico'
      )
    )
    console.log('Técnicos filtrados:', tecnicos.value)
  } catch (error) {
    console.error('Erro ao buscar técnicos:', error)
  }
})




</script>



<style scoped lang="scss">
.tecnicos-page {
  h1 {
    font-size: 1.8rem;
    margin-bottom: 10px;
    color: #1e293b;
  }

  h4 {
    color: #475569;
    margin-bottom: 20px;
  }
}

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

/* Status visuais */
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

/* Responsividade */
@media (max-width: 900px) {
  table, thead, tbody, th, td, tr {
    display: block;
  }

  thead {
    display: none;
  }

  tbody tr {
    margin-bottom: 16px;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 12px;
  }

  tbody td {
    display: flex;
    justify-content: space-between;
    padding: 6px 12px;

    &::before {
      content: attr(data-label);
      font-weight: 600;
      color: #6b7280;
    }
  }
}
</style>
