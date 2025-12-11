import type { Equipment } from '~/models/equipment.model'

const API_URL = 'https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net'

/** Normalizar retorno da API */
const norm = (data: any) =>
  data?.data?.value?.results ||
  data?.data?.results ||
  data?.results ||
  data ||
  []

/** Buscar equipamentos */
export const getEquipments = async (params?: Record<string, any>) => {
  const { $authFetch } = useNuxtApp()
  const query = new URLSearchParams(params || {}).toString()
  const { data } = await $authFetch(`${API_URL}/api/equipment/?${query}`)
  return norm(data.value)
}

/** Buscar por ID */
export const getEquipmentById = async (id: number | string) => {
  const { $authFetch } = useNuxtApp()
  const { data } = await $authFetch(`${API_URL}/api/equipment/${id}/`)
  return data.value
}

/** Criar equipamento */
export const createEquipment = async (equipmentData: any) => {
  const { $authFetch } = useNuxtApp()

  const payload = {
    name: equipmentData.name,
    code: equipmentData.code,
    description: equipmentData.description,
    category_id: Number(equipmentData.category_FK_id),
    environment_id: Number(equipmentData.environment_FK_id),
  }

  const { data } = await $authFetch(`${API_URL}/api/equipment/`, {
    method: 'POST',
    body: payload,
  })

  return data.value
}

/** Atualizar equipamento */
export const updateEquipment = async (id: number | string, data: any) => {
  const { $authFetch } = useNuxtApp()

  const payload = {
    name: data.name,
    code: data.code,
    description: data.description,
    category_id: Number(data.category_FK_id),
    environment_id: Number(data.environment_FK_id),
  }

  const response = await $authFetch(`${API_URL}/api/equipment/${id}/`, {
    method: 'PUT',
    body: payload,
  })

  return response.data?.value || response.data
}

/** Buscar Categorias */
export const getCategories = async () => {
  const { $authFetch } = useNuxtApp()
  const { data } = await $authFetch(`${API_URL}/api/category/`)
  return norm(data.value)
}

/** Buscar Ambientes */
export const getEnvironments = async () => {
  const { $authFetch } = useNuxtApp()
  const { data } = await $authFetch(`${API_URL}/api/environment/`)
  return norm(data.value)
}

/** Excluir equipamento */
export const deleteEquipment = async (id: number | string) => {
  const { $authFetch } = useNuxtApp()

  const response = await $authFetch(`${API_URL}/api/equipment/${id}/`, {
    method: 'DELETE',
  })

  return response
}
