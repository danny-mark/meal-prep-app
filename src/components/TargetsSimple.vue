<script setup lang="ts">
import type { Macros, MacroKey } from '@/custom_types/Macros.type'
import { useGlobalStore } from '@/stores/globalStatic'
const globals = useGlobalStore()

const props = defineProps<{
  targets: Macros
  consumed: Macros
}>()
</script>

<template>
  <div class="flex text-left">
    <div v-for="macro in globals.macros">
      <div v-if="targets[macro as MacroKey]" class="mr-4 text-sm">
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
