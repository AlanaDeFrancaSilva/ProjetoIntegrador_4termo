import type { Page } from '~/models/page.model'
import type { Task } from '~/models/task.model'
import { useUserStore } from '@/stores/user'

/* ============================================================
    GET TASKS (com filtros)
============================================================ */
export const getTasks = (params?: Record<string, any>) => {
  const { $authFetch } = useNuxtApp()
  const query = new URLSearchParams(params || {}).toString()
  return $authFetch<Page<Task>>(`http://localhost:8001/api/task/?${query}`)
}

/* ============================================================
    GET POR ID
============================================================ */
export const getTaskById = (id: string) => {
  const { $authFetch } = useNuxtApp()
  return $authFetch<Task>(`http://localhost:8001/api/task/${id}/`)
}

/* ============================================================
    CRIAR TASK (somente admin ou cliente)
============================================================ */
export const createTask = async (data: any) => {
  const { $authFetch } = useNuxtApp()
  const user = useUserStore()

  // 🚫 Bloqueio frontal para técnico
  if (!user.isAdmin && !user.isCliente) {
    throw new Error("Usuário sem permissão para criar chamados.")
  }

  return $authFetch<Task>('http://localhost:8001/api/task/', {
    method: 'POST',
    body: data,
  })
}

/* ============================================================
    ATUALIZAR TASK — VERSÃO FINAL E CORRIGIDA
============================================================ */
export const updateTask = (id: number, data: any) => {
  const { $authFetch } = useNuxtApp()

  return $authFetch(`http://localhost:8001/api/task/${id}/`, {
    method: 'PUT',
    body: {
      name: data.name,
      description: data.description,
      urgency_level: data.urgency_level,

      // 🔥 Status sendo enviado corretamente
      status: data.status,

      // Arrays tratados — aceita tanto id quanto objetos
      responsibles_FK: data.responsibles_FK?.map((r: any) => r.id || r) || [],

      equipments_FK: data.equipments_FK?.map((e: any) => e.id || e) || [],

      // 🔥 Observações / Andamento
      progress_notes: data.progress_notes || "",
    },
  })
}

/* ============================================================
    DELETAR TASK
============================================================ */
export const deleteTaskById = (id: string) => {
  const { $authFetch } = useNuxtApp()
  return $authFetch(`http://localhost:8001/api/task/${id}/`, {
    method: 'DELETE'
  })
}
