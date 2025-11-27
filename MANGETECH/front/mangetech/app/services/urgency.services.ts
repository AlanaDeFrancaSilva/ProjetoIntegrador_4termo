export const getUrgencyLevels = async () => {
  const { $authFetch } = useNuxtApp()
  return await $authFetch('http://127.0.0.1:8001/api/urgency-levels/')
}

