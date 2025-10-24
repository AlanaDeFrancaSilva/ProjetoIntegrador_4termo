import { UseFetchReturn } from 'nuxt/app'

declare module '#app' {
  interface NuxtApp {
    $authFetch: <T>(url: string, options?: any) => Promise<UseFetchReturn<T>>
  }
}

declare module 'vue' {
  interface ComponentCustomProperties {
    $authFetch: <T>(url: string, options?: any) => Promise<UseFetchReturn<T>>
  }
}
