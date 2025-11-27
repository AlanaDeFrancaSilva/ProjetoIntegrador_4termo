import type { Page } from '~/models/page.model'
import type { Equipment } from '~/models/equipment.model'

export const getEquipments = async (params?: Record<string, any>) => {
  const { $authFetch } = useNuxtApp()
  const query = new URLSearchParams(params || {}).toString()
  const { data } = await $authFetch(`http://localhost:8001/api/equipment/?${query}`)
  return data.value?.results || []
}



export const getEquipmentById = (id: string) => {
  const { $authFetch } = useNuxtApp()
  return $authFetch<Equipment>(`http://localhost:8001/api/equipment/${id}/`)
}
