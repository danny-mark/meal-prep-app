<script setup lang="ts">
import { useSessionStore } from '@/stores/session'
import { useToastStore } from '@/stores/toast'
import { supabase } from '@/supabase'

const session = useSessionStore()
const toastStore = useToastStore()

async function signOut() {
  try {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  } catch (error: unknown) {
    if (error instanceof Error) {
      toastStore.showErrorToast(error.message)
    }
  }
}
</script>

<template>
  <h2 class="mb-10 text-2xl font-bold">Account</h2>

  <p><b>Email</b> {{ session.user.email }}</p>

  <div>
    <button class="btn btn-outline mt-8 w-40" @click="signOut">Sign Out</button>
  </div>
</template>
