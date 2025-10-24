interface LoginResponse {
  auth_token: string
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
