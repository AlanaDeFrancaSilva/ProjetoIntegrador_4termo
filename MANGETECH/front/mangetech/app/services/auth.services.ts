interface LoginResponse {
  auth_token: string
}

interface User {
  id: number
  email: string
  name: string
  groups: string[]
}

export const login = (email: string, password: string) => {
  return useFetch<LoginResponse>('http://localhost:8001/api/auth/token/login/', {
    method: 'POST',
    body: { email, password },
  })
}

export const logout = () => {
  const token = localStorage.getItem('auth_token')
  return useFetch('http://localhost:8001/api/auth/token/logout/', {
    method: 'POST',
    headers: { Authorization: `Token ${token}` },
  })
}

export const getCurrentUser = async (): Promise<User> => {
  const token = localStorage.getItem('auth_token')

  if (!token) {
    throw new Error('Token de autenticação não encontrado.')
  }

  return await $fetch<User>('http://localhost:8001/api/auth/users/me/', {
    headers: {
      Authorization: `Token ${token}`,
    },
  })
}

export const updateCurrentUser = async (data: any) => {
  const token = localStorage.getItem('auth_token')

  return useFetch('http://localhost:8001/api/auth/users/me/', {
    method: 'PATCH',
    headers: { Authorization: `Token ${token}` },
    body: data,
  })
}
