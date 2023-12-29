import { ref, computed } from 'vue'
import type { Ref } from 'vue'
import { defineStore } from 'pinia'

export const useToastStore = defineStore('toast', () => {
  const isShown: Ref<boolean> = ref(false)
  const title: Ref<string> = ref('')
  const message: Ref<string | undefined> = ref()
  const style: Ref<string> = ref('primary')

  const showToast = (options: {
    title: string
    message?: string
    style?: string
    timeout?: number | null
  }) => {
    isShown.value = true
    title.value = options.title
    message.value = options.message
    style.value = options.style || 'primary'

    const timeout = options.timeout === undefined ? 3000 : options.timeout

    if (timeout) {
      setTimeout(() => {
        isShown.value = false
      }, timeout)
    }
  }

  const showErrorToast = (message: string) => {
    showToast({
      title: 'Error',
      style: 'danger',
      message
    })
  }

  return { title, message, style, isShown, showToast, showErrorToast }
})
