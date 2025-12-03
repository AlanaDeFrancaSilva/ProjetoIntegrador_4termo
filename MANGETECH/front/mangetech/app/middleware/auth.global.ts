import { useUserStore } from "@/stores/user"

export default defineNuxtRouteMiddleware(async (to) => {
  const token = localStorage.getItem("auth_token")
  const userStore = useUserStore()

  // 1. Evitar loop infinito no /login
  if (to.path === "/login") {
    if (token) {
      try {
        await userStore.fetchUser()
        return navigateTo("/")   // já logado → manda para home
      } catch {
        return  // token inválido → permite ficar no login
      }
    }
    return  // sem token → pode acessar login normalmente
  }

  // 2. Se não tiver token → redireciona para login
  if (!token) return navigateTo("/login")

  // 3. Carregar o usuário se necessário
  if (!userStore.user) {
    try {
      await userStore.fetchUser()
    } catch {
      return navigateTo("/login")
    }
  }

  // 4. Proteção por nível
  if (to.path.startsWith("/admin") && !userStore.isAdmin) {
    return navigateTo("/")
  }

  if (to.path.startsWith("/tecnico") && !(userStore.isTecnico || userStore.isAdmin)) {
    return navigateTo("/")
  }

  if (to.path.startsWith("/cliente") && !(userStore.isCliente || userStore.isAdmin)) {
    return navigateTo("/")
  }
})
