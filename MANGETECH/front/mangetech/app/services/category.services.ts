// services/category.services.ts
import api from './api'

export const getCategories = async () => {
  return await api.get('/categories/')
}
