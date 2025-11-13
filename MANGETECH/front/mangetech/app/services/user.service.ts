export const getCurrentUser = async () => {
  const token = localStorage.getItem('auth_token')

  if (!token) throw new Error('Token não encontrado')

  const response = await fetch('http://localhost:8001/api/auth/users/me/', {
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Token ${token}`,
    },
  })

  if (!response.ok) throw new Error('Erro ao buscar usuário logado')

  return await response.json()
}

export const getUsers = async () => {
  const token = localStorage.getItem('auth_token')

  if (!token) throw new Error('Token não encontrado')

  const response = await fetch('http://localhost:8001/api/auth/users/', {
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Token ${token}`,
    },
  })

  if (!response.ok) throw new Error('Erro ao buscar usuários')

  return await response.json()
}