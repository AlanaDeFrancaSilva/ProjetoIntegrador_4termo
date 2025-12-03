import { defineStore } from 'pinia'
import { getCurrentUser } from '@/services/auth.services'

export const useUserStore = defineStore('user', {
  state: () => ({
    user: null as any | null
  }),

  getters: {
    isAdmin: (state) => state.user?.groups?.includes("ADMIN"),
    isTecnico: (state) => state.user?.groups?.includes("Técnico"),
    isCliente: (state) => state.user?.groups?.includes("Cliente"),
  },

  actions: {
    async fetchUser() {
      this.user = await getCurrentUser()
    },

    setUser(data: any) {
      this.user = data
    }
  }
})
