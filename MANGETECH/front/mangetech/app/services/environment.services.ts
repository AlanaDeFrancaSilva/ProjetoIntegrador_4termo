// app/services/environment.services.ts
import { useNuxtApp } from '#app'

const API_URL = 'https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net'


export const getEnvironments = async () => {
  const { $authFetch } = useNuxtApp()
  const { data } = await $authFetch(`${API_URL}/api/environment/`)
  return data.value?.results || data.value || []
}


export const getEnvironmentById = async (id: string | number) => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch(`${API_URL}/api/environment/${id}/`)
}


export const createEnvironment = async (payload: any) => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch(`${API_URL}/api/environment/`, {
    method: 'POST',
    body: payload,
  })
}


export const updateEnvironment = async (id: string | number, payload: any) => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch(`${API_URL}/api/environment/${id}/`, {
    method: 'PATCH',
    body: payload,
  })
}
