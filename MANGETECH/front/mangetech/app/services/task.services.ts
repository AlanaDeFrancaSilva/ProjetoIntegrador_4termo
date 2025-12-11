import type { Page } from '~/models/page.model'
import type { Task } from '~/models/task.model'
import { useUserStore } from '@/stores/user'

const API_URL = 'https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net'



export const getTasks = (params?: Record<string, any>) => {
  const { $authFetch } = useNuxtApp()
  const query = new URLSearchParams(params || {}).toString()
  return $authFetch<Page<Task>>(`${API_URL}/api/task/?${query}`)
}



export const getTaskById = (id: string) => {
  const { $authFetch } = useNuxtApp()
  return $authFetch<Task>(`${API_URL}/api/task/${id}/`)
}



export const createTask = async (data: any) => {
  const { $authFetch } = useNuxtApp()
  const user = useUserStore()


  if (!user.isAdmin && !user.isCliente) {
    throw new Error("Usuário sem permissão para criar chamados.")
  }

  return $authFetch<Task>(`${API_URL}/api/task/`, {
    method: 'POST',
    body: data,
  })
}



export const updateTask = (id: number, data: any) => {
  const { $authFetch } = useNuxtApp()

  return $authFetch(`${API_URL}/api/task/${id}/`, {
    method: 'PUT',
    body: {
      name: data.name,
      description: data.description,
      urgency_level: data.urgency_level,


      status: data.status,

      responsibles_FK: data.responsibles_FK?.map((r: any) => r.id || r) || [],
      equipments_FK: data.equipments_FK?.map((e: any) => e.id || e) || [],

      progress_notes: data.progress_notes || "",
    },
  })
}



export const deleteTaskById = (id: string) => {
  const { $authFetch } = useNuxtApp()
  return $authFetch(`${API_URL}/api/task/${id}/`, {
    method: 'DELETE'
  })
}
