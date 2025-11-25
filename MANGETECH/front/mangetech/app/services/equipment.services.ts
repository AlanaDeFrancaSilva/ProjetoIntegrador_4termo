import type { Page } from '~/models/page.model'
import type { Equipment } from '~/models/equipment.model'

export const getEquipments = (params?: Record<string, any>) => {
  const { $authFetch } = useNuxtApp()
  const query = new URLSearchParams(params || {}).toString()
  return $authFetch<Page<Equipment>>(`http://localhost:8001/api/equipment/?${query}`)
}

export const getEquipmentById = (id: string) => {
  const { $authFetch } = useNuxtApp()
  return $authFetch<Equipment>(`http://localhost:8001/api/equipment/${id}/`)
}
