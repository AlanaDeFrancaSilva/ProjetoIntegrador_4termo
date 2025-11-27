<template>
  <div class="page-container">
    <div class="header">
      <h1>Novo Cliente</h1>
      <p>Cadastre um novo cliente no sistema</p>
    </div>

    <ClienteForm
      v-model="form"
      @submit="salvarCliente"
      @cancel="voltar"
    />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard-layout' })

import { ref } from "vue"
import ClienteForm from '~/components/ClienteModel.vue'
import {createUser } from '~/services/user.service'
import { navigateTo } from "#app"

const form = ref({
  name: "",
  email: "",
  nif: "",
  password: "",
  is_active: true,
})

const salvarCliente = async (payload: any) => {
  try {
    await createUser({ ...payload, groups: ['cliente'] })
    alert("Cliente criado com sucesso!")
    navigateTo("/clientes")
  } catch (error) {
    alert("Erro ao salvar cliente")
    console.error(error)
  }
}

const voltar = () => {
  navigateTo("/clientes")
}
</script>
