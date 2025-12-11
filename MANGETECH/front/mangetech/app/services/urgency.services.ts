export const getUrgencyLevels = async () => {
  return await $fetch('https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/urgency-levels/', {
    method: 'GET'
  })
}
