<script setup lang="ts">
import type { JournalFood } from '@/custom_types/JournalEntry.type'
import IconTrash from '@/components/icons/IconTrash.vue'
import IconPlusSquare from '@/components/icons/IconPlusSquare.vue'
import { useGlobalStore } from '@/stores/globalStatic'

const globals = useGlobalStore()

const emit = defineEmits(['foodClicked', 'trashClicked', 'addClicked'])

const props = defineProps<{
  foods: {
    name: string
    category: string
    amount: number
  }[]
}>()
</script>

<template>
  <div class="flex flex-wrap text-left">
    <div
      class="relative mb-2 mr-2 cursor-default rounded border-2 border-gray-400 p-2 pr-14 text-sm"
      v-for="(food, j) in foods"
      :key="j"
      @click="$emit('foodClicked', j)"
      :style="{ borderColor: globals.foodCategoryColorMap.get(food.category) }"
    >
      <b>{{ food.name }}</b>
      <p>{{ food.amount }} g</p>
      <div
        class="absolute right-0 top-0 cursor-pointer p-2 text-danger"
        @click.stop="$emit('trashClicked', j)"
      >
        <IconTrash />
      </div>
    </div>
    <button
      class="btn-outline border-none text-left text-3xl text-muted opacity-75"
      title="Add Food To Meal"
      type="button"
      @click.stop="$emit('addClicked')"
    >
      <IconPlusSquare />
    </button>
  </div>
</template>
