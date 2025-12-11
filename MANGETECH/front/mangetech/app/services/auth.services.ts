interface LoginResponse {
  auth_token: string
}

interface User {
  id: number
  email: string
  name: string
  groups: string[]
}

const API_URL = 'https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net'



export const login = (email: string, password: string) => {
  return useFetch<LoginResponse>(`${API_URL}/api/auth/token/login/`, {
    method: 'POST',
    body: { email, password },
  })
}



export const logout = () => {
  const token = localStorage.getItem('auth_token')
  return useFetch(`${API_URL}/api/auth/token/logout/`, {
    method: 'POST',
    headers: { Authorization: `Token ${token}` },
  })
}


export const getCurrentUser = async (): Promise<User> => {
  const token = localStorage.getItem('auth_token')

  if (!token) {
    throw new Error('Token de autenticação não encontrado.')
  }

  return await $fetch<User>(`${API_URL}/api/auth/users/me/`, {
    headers: {
      Authorization: `Token ${token}`,
    },
  })
}



export const updateCurrentUser = async (data: any) => {
  const token = localStorage.getItem('auth_token')

  return useFetch(`${API_URL}/api/auth/users/me/`, {
    method: 'PATCH',
    headers: { Authorization: `Token ${token}` },
    body: data,
  })
}
