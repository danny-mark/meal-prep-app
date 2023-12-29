import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import type { Session } from '@supabase/gotrue-js/src/lib/types'

export const useSessionStore = defineStore('session', () => {
  const user = ref()

  const setUser = (supabaseSession: Session | null) => {
    user.value = supabaseSession?.user || null
  }

  return { user, setUser }
})
