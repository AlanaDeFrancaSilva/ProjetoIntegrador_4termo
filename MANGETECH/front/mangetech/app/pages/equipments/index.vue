<template>
  <section class="ativos-page">
    <h1>Equipamentos</h1>
    <h4>Equipamentos Ativos</h4>

    <table v-if="equipamentos.length > 0">
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
        <tr v-for="(equip, index) in equipamentos" :key="index">
          <td>{{ equip.name }}</td>
          <td>{{ equip.code }}</td>
          <td>{{ equip.description }}</td>
          <td>{{ new Date(equip.creation_date).toLocaleDateString() }}</td>
          <td>{{ equip.category_FK || '—' }}</td>
          <td>{{ equip.environment_FK?.name || '—' }}</td>
        </tr>
      </tbody>
    </table>

    <p v-else>Nenhum equipamento encontrado.</p>
  </section>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'dashboard-layout'
})

import { ref, onMounted } from 'vue'
import { getEquipments } from '@/services/equipment.services'

const equipamentos = ref([])

onMounted(async () => {
  try {
    const { data, error } = await getEquipments()
    
    if (error.value) {
      console.error('Erro na API:', error.value)
      return
    }

    console.log('Dados brutos da API:', data.value)

    equipamentos.value = data.value?.results || []
    console.log('Equipamentos carregados:', equipamentos.value)
  } catch (err) {
    console.error('Erro ao buscar equipamentos:', err)
  }
})
</script>

<style scoped lang="scss">
.ativos-page {
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
