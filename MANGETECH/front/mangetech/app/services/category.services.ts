import { useNuxtApp } from '#app'

const API_URL = 'https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net'

export const getCategories = async () => {
  const data = await $fetch(`${API_URL}/api/category/`)
  return data?.results || data || []
}

export const getCategoryById = async (id: string | number) => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch(`${API_URL}/api/category/${id}/`)
}
