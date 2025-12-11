// app/services/environment.services.ts
import { useNuxtApp } from '#app'

const API_URL = 'https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net'

// 🔹 Buscar todos os ambientes
export const getEnvironments = async () => {
  const { $authFetch } = useNuxtApp()
  const { data } = await $authFetch(`${API_URL}/api/environment/`)
  return data.value?.results || data.value || []
}

// 🔹 Buscar ambiente por ID
export const getEnvironmentById = async (id: string | number) => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch(`${API_URL}/api/environment/${id}/`)
}

// 🔹 Criar novo ambiente
export const createEnvironment = async (payload: any) => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch(`${API_URL}/api/environment/`, {
    method: 'POST',
    body: payload,
  })
}

// 🔹 Atualizar ambiente existente
export const updateEnvironment = async (id: string | number, payload: any) => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch(`${API_URL}/api/environment/${id}/`, {
    method: 'PATCH',
    body: payload,
  })
}
