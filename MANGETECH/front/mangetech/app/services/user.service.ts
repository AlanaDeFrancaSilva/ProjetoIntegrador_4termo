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

// 🆕  Função para criar usuário
export const createUser = async (payload: any) => {
  const token = localStorage.getItem('auth_token')

  if (!token) throw new Error('Token não encontrado')

  const response = await fetch('http://localhost:8001/api/auth/users/', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Token ${token}`,
    },
    body: JSON.stringify(payload),
  })

  // 👉 Agora sim pode usar response
  if (!response.ok) {
    const errorData = await response.json()
    console.error("Erro do backend:", errorData)
    throw new Error(JSON.stringify(errorData))
  }

  return await response.json()
}

export const updateUser = async (id: number, payload: any) => {
  const token = localStorage.getItem('auth_token')

  const response = await fetch(`http://localhost:8001/api/auth/users/${id}/`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Token ${token}`,
    },
    body: JSON.stringify(payload),
  })

  if (!response.ok) {
    const errorData = await response.json()
    throw new Error(JSON.stringify(errorData))
  }

  return await response.json()
}
