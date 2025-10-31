//store guarda o estado global do usuário logado.

import { defineStore } from 'pinia'
import { getCurrentUser } from '@/services/auth.services'

export const useUserStore = defineStore('user', {
  state: () => ({
    user: null as any | null
  }),
  actions: {
    async fetchUser() {
      this.user = await getCurrentUser()
    },
    setUser(data: any) {
      this.user = data
    }
  }
})
