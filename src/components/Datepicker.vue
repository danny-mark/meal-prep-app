<script setup lang="ts">
import { ref } from 'vue'
import VueDatePicker from '@vuepic/vue-datepicker'
import { useDateStore } from '@/stores/date'
const dateStore = useDateStore()
</script>

<template>
  <div class="flex items-center gap-2">
    <button @click="dateStore.goToPreviousDay()" class="px-2 py-1 text-lg" title="Previous day">
      ←
    </button>

    <div style="max-width: 150px">
      <VueDatePicker
        v-model="dateStore.date"
        auto-apply
        :enable-time-picker="false"
        :clearable="false"
        position="right"
        locale="eu"
      />
    </div>

    <button @click="dateStore.goToNextDay()" class="px-2 py-1 text-lg" title="Next day">→</button>
  </div>
</template>
