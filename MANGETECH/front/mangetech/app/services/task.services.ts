import type { Page } from '~/models/page.model'
import type { Task } from '~/models/task.model'

export const getTasks = () => {
  const { $authFetch } = useNuxtApp()
  return $authFetch<Page<Task>>('http://localhost:8001/api/task/')
}

export const getTaskById = (id: string) => {
  const { $authFetch } = useNuxtApp()
  return $authFetch<Task>(`http://localhost:8001/api/task/${id}/`)
}
