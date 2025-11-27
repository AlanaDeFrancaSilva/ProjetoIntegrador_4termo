import api from './api'

export const getEnvironments = async () => {
  const { $authFetch } = useNuxtApp()
  const { data } = await $authFetch('http://localhost:8001/api/environment/')
  return data.value?.results || data.value || []
}

export const getEnvironmentById = async (id: string | number) => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch(`http://localhost:8001/api/environment/${id}/`)
}
