import { defineNuxtPlugin } from '#app'

export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.provide('authFetch', async (url: string, options: any = {}) => {
    const isClient = typeof window !== 'undefined'
    const token = isClient ? localStorage.getItem('auth_token') : null
    const headers = options.headers || {}
    if (token) headers['Authorization'] = `Token ${token}`
    return await useFetch(url, { ...options, headers })
  })
})
