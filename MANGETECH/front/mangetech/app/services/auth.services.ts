interface LoginResponse {
  auth_token: string
}

interface User {
  id: number
  email: string
  username: string
  first_name: string
  last_name: string
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

  const { data, error } = await useFetch<User>('http://localhost:8001/api/auth/users/me/', {
    headers: { Authorization: `Token ${token}` },
  })

  if (error.value) {
    throw new Error('Erro ao buscar usuário atual: ' + error.value.message)
  }

  if (!data.value) {
    throw new Error('Usuário não encontrado.')
  }

  return data.value
}


export const updateCurrentUser = async (data: any) => {
  const token = localStorage.getItem('auth_token')

  return useFetch('http://localhost:8001/api/auth/users/me/', {
    method: 'PATCH',
    headers: { Authorization: `Token ${token}` },
    body: data,
  })
}

