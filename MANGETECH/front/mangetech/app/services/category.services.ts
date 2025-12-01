// app/services/category.services.ts
import { useNuxtApp } from '#app'

export const getCategories = async () => {
  const { $authFetch } = useNuxtApp()
  const data = await $fetch('http://localhost:8001/api/category/')
  return data?.results || data || []
}


export const getCategoryById = async (id: string | number) => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch(`http://localhost:8001/api/category/${id}/`)
}
