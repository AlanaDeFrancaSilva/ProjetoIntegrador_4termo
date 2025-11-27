import type { Page } from '~/models/page.model'
import type { Task } from '~/models/task.model'

export const getTasks = (params?: Record<string, any>) => {
  const { $authFetch } = useNuxtApp()
  const query = new URLSearchParams(params || {}).toString()
  return $authFetch<Page<Task>>(`http://localhost:8001/api/task/?${query}`)
}

export const getTaskById = (id: string) => {
  const { $authFetch } = useNuxtApp()
  return $authFetch<Task>(`http://localhost:8001/api/task/${id}/`)
}

export const createTask = (data: any) => {
  const { $authFetch } = useNuxtApp()
  return $authFetch<Task>('http://localhost:8001/api/task/', {
    method: 'POST',
    body: data,
  })
}
