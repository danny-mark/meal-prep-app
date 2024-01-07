<script setup lang="ts">
import type { Macros, MacroKey } from '@/custom_types/Macros.type'

const props = defineProps<{
  targets: Macros
  consumed: Macros
}>()
</script>

<template>
  <div class="flex text-left">
    <div v-for="macro in $macros">
      <div v-if="targets[macro as MacroKey]" class="mr-6 text-sm">
        <span class="text-muted">{{ macro }}</span>
        <p>
          {{ consumed[macro as MacroKey].toFixed(0) }} /
          {{ targets[macro as MacroKey].toFixed(0) }}
          {{ macro == 'calories' ? 'kcal' : 'g' }}
        </p>
      </div>
    </div>
  </div>
</template>
