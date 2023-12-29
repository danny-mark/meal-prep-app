<script setup lang="ts">
import { ref, watch } from 'vue'
import type { Ref } from 'vue'

const props = defineProps<{
  isOpen: boolean
}>()

const dialog: Ref<HTMLDialogElement | null> = ref(null)

watch(
  () => props.isOpen,
  (isOpen) => {
    if (!dialog.value) return
    if (isOpen) {
      dialog.value.showModal()
    } else {
      dialog.value.close()
    }
  }
)
</script>

<template>
  <dialog class="w-full max-w-lg rounded p-8" ref="dialog" @close="$emit('dialogClosedEvent')">
    <div class="mb-10 flex items-center justify-between">
      <slot name="title"></slot>
      <span
        class="h-6 w-6 cursor-pointer rounded-full bg-gray-400 text-2xl leading-none text-white"
        @click="$emit('dialogClosedEvent')"
        >×</span
      >
    </div>

    <slot name="body"></slot>
  </dialog>
</template>
