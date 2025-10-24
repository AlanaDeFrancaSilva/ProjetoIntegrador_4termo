<script setup lang="ts">
import { getTasks } from '~/services/task.services';

const { data: allTasks } = await getTasks();

</script>

<template>
    <h1>Tasks Page!</h1>    
    <table>
        <thead>
            <th>ID Chamado</th>
            <th>Solicitante</th>
            <th>Título</th>
            <th>Descrição</th>
            <th>Data de Abertura</th>
            <th>Urgência</th>
        </thead>
        <tbody>
            <tr v-for="(task, index) in allTasks?.results" :key="index">
                <td>{{ task.id }}</td>
                <td>{{ task.creator_FK.name }}</td>
                <td>{{ task.name }}</td>
                <td>{{ task.description }}</td>
                <td>{{ task.creation_date }}</td>
                <td>{{ task.urgency_level }}</td>
            </tr>
        </tbody>

    </table>

</template>

<style scoped lang="scss">
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

        &:nth-child(6) { // coluna de Urgência
          font-weight: 600;
          text-align: center;

          &.Baixa {
            background-color: #d1fae5;
            color: #065f46;
            border-radius: 6px;
            padding: 4px 8px;
          }

          &.Média {
            background-color: #fef3c7;
            color: #78350f;
            border-radius: 6px;
            padding: 4px 8px;
          }

          &.Alta {
            background-color: #fee2e2;
            color: #991b1b;
            border-radius: 6px;
            padding: 4px 8px;
          }
        }
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

    &:nth-child(6) {
      justify-content: flex-start;
    }
  }
}
</style>