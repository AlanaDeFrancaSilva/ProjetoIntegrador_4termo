import type { Equipment } from '~/models/equipment.model'

/**
 * 🔹 Buscar lista de equipamentos com filtros
 * Suporta busca por nome, categoria, ambiente ou qualquer parâmetro aceito pela API
 */
export const getEquipments = async (params?: Record<string, any>) => {
  const { $authFetch } = useNuxtApp()
  const query = new URLSearchParams(params || {}).toString()
  const { data } = await $authFetch(`http://localhost:8001/api/equipment/?${query}`)
  return data.value?.results || data.value || []
}

/**
 * 🔹 Buscar equipamento por ID
 */
export const getEquipmentById = async (id: number | string) => {
  const { $authFetch } = useNuxtApp()
  const { data } = await $authFetch(`http://localhost:8001/api/equipment/${id}/`)
  return data.value
}

/**
 * 🔹 Criar novo equipamento
 */
export const createEquipment = async (equipmentData: Partial<Equipment>) => {
  const { $authFetch } = useNuxtApp()
  const { data } = await $authFetch(`http://localhost:8001/api/equipment/`, {
    method: 'POST',
    body: equipmentData,
  })
  return data.value
}

/**
 * 🔹 Atualizar equipamento
 */
export const updateEquipment = async (id: number | string, equipmentData: Partial<Equipment>) => {
  const { $authFetch } = useNuxtApp()
  const { data } = await $authFetch(`http://localhost:8001/api/equipment/${id}/`, {
    method: 'PUT',
    body: equipmentData,
  })
  return data.value
}

/**
 * 🔹 Deletar equipamento
 */
export const deleteEquipment = async (id: number | string) => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch(`http://localhost:8001/api/equipment/${id}/`, {
    method: 'DELETE',
  })
}

/**
 * 🔹 Buscar Categorias (para drop-down)
 */
export const getCategories = async () => {
  const { $authFetch } = useNuxtApp()
  const { data } = await $authFetch(`http://localhost:8001/api/category/`)
  return data.value?.results || data.value || []
}

/**
 * 🔹 Buscar Ambientes (para drop-down)
 */
export const getEnvironments = async () => {
  const { $authFetch } = useNuxtApp()
  const { data } = await $authFetch(`http://localhost:8001/api/environment/`)
  return data.value?.results || data.value || []
}
