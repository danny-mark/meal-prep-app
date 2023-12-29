<script setup lang="ts">
import { useSessionStore } from '@/stores/session'

const session = useSessionStore()
</script>

<template>
  <h2>Diary</h2>
  {{ session.user.email }}
</template>
