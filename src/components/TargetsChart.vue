<script setup lang="ts">
import type { Macros, MacroKey } from '@/custom_types/Macros.type'
import { useGlobalStore } from '@/stores/globalStatic'
const globals = useGlobalStore()

const props = defineProps<{
  targets: Macros
  consumed: Macros
}>()

const getPercentage = (item: MacroKey): number => {
  return Number(
    ((props.consumed[item as MacroKey] / props.targets[item as MacroKey]) * 100).toFixed()
  )
}
</script>

<template>
  <div class="m-auto w-full max-w-lg">
    <div v-for="(item, index) in globals.macros" class="mb-2">
      <div class="flex justify-between">
        <h5 class="text-left">
          <b class="capitalize">{{ item }}</b> - {{ consumed[item as MacroKey].toFixed(1) }} /
          {{ targets[item as MacroKey] }}
          {{ item == 'calories' ? 'kcal' : 'g' }}
        </h5>
        <span>{{ getPercentage(item) }}%</span>
      </div>

      <progress
        class="w-full text-xs"
        :class="getPercentage(item) > 100 ? 'over-limit' : ''"
        :value="getPercentage(item)"
        max="100"
      ></progress>
    </div>
  </div>
</template>

<style>
progress::-webkit-progress-bar {
  background-color: theme('colors.gray.200');
  border-radius: 8px 8px;
}
progress::-webkit-progress-value {
  background-color: theme('colors.primary');
  border-radius: 8px 0 0 8px;
}
progress.over-limit::-webkit-progress-value {
  background-color: theme('colors.danger');
  border-radius: 8px;
}
</style>
