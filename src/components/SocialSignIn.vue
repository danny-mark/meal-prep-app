<script setup lang="ts">
import { supabase } from '@/supabase'

const props = defineProps<{
  provider: 'google' | 'github'
}>()

const signInWithSocial = async () => {
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: props.provider,
    options: {
      redirectTo: 'http://localhost:5173'
    }
  })
}
</script>

<template>
  <button @click="signInWithSocial" class="btn btn-primary mb-4">
    Sign In With <span class="capitalize">{{ provider }}</span>
  </button>
</template>

<style scoped></style>
