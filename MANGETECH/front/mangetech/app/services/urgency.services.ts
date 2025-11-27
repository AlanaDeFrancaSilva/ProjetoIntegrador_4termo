export const getUrgencyLevels = async () => {
  return await $fetch('http://127.0.0.1:8001/api/urgency-levels/', {
    method: 'GET'
  })
}
