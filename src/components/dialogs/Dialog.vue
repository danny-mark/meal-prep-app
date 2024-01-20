<script setup lang="ts">
import { ref, watch } from 'vue'
import type { Ref } from 'vue'

const props = defineProps<{
  isOpen: boolean
}>()

const dialog: Ref<HTMLDialogElement | null> = ref(null)
const autoFocusPrevention: Ref<boolean> = ref(false)

watch(
  () => props.isOpen,
  (isOpen) => {
    if (!dialog.value) return
    if (isOpen) {
      dialog.value.showModal()
      autoFocusPrevention.value = true
      setTimeout(() => {
        autoFocusPrevention.value = false
      }, 100)
    } else {
      dialog.value.close()
    }
  }
)
</script>

<!-- TODO SIZES -->

<template>
  <dialog
    class="m-2 w-[calc(100%-1rem)] max-w-3xl rounded p-4 md:m-auto md:w-full md:p-8"
    ref="dialog"
    @close="$emit('dialogClosedEvent')"
    :inert="autoFocusPrevention"
  >
    <div class="mb-8 flex items-center justify-between">
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
