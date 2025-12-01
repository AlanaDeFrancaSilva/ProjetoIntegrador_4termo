// app/services/environment.services.ts
import { useNuxtApp } from '#app'

export const getEnvironments = async () => {
  const { $authFetch } = useNuxtApp()
  const { data } = await $authFetch('http://localhost:8001/api/environment/')
  return data.value?.results || data.value || []
}

export const getEnvironmentById = async (id: string | number) => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch(`http://localhost:8001/api/environment/${id}/`)
}

// 🔹 Criar novo ambiente
export const createEnvironment = async (payload: any) => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch('http://localhost:8001/api/environment/', {
    method: 'POST',
    body: payload,
  })
}

// 🔹 Atualizar ambiente existente
export const updateEnvironment = async (id: string | number, payload: any) => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch(`http://localhost:8001/api/environment/${id}/`, {
    method: 'PATCH',
    body: payload,
  })
}
