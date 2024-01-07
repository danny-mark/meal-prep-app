<script setup lang="ts">
import type { JournalEntry } from '@/custom_types/JournalEntry.type'
import IconTrash from '@/components/icons/IconTrash.vue'
import IconPlusSquare from '@/components/icons/IconPlusSquare.vue'

const emit = defineEmits(['foodClicked', 'trashClicked', 'addClicked'])

const props = defineProps<{
  entry: JournalEntry
}>()
</script>

<template>
  <div class="flex flex-wrap text-left">
    <div
      class="relative mb-2 mr-2 cursor-default rounded border border-gray-400 p-2 pr-14 text-sm"
      v-for="(mealFood, j) in entry.contents"
      :key="j"
      @click="$emit('foodClicked', entry, j)"
    >
      <b>{{ mealFood.name }}</b>
      <p>{{ mealFood.amount }} g</p>
      <div
        class="absolute right-0 top-0 cursor-pointer p-4 text-danger"
        @click.stop="$emit('trashClicked', entry, j)"
      >
        <IconTrash />
      </div>
    </div>
    <button
      class="btn-outline border-none text-left text-3xl text-muted opacity-75"
      title="Add Food To Meal"
      type="button"
      @click.stop="$emit('addClicked', entry)"
    >
      <IconPlusSquare />
    </button>
  </div>
</template>
