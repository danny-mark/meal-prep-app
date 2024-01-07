<script setup lang="ts">
import { ref } from 'vue'
import VueDatePicker from '@vuepic/vue-datepicker'
import { useDateStore } from '@/stores/date'
const dateStore = useDateStore()
</script>

<template>
  <!-- TODO: prev / next arrows for easier switching -->

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
</template>
