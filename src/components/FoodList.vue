<script setup lang="ts">
import { useToastStore } from '@/stores/toast'
import { supabase } from '@/supabase'
import { ref, watchEffect } from 'vue'
import type { Ref } from 'vue'
import type { FoodItem } from '@/custom_types/FoodItem.type'

const toastStore = useToastStore()

const emit = defineEmits(['foodItemClicked'])

const foods: Ref<FoodItem[]> = ref([])
const search: Ref<String> = ref('')
const categoryFilter: Ref<String> = ref('all')

watchEffect(async () => {
  let query = supabase
    .from('food_items')
    .select()
    .limit(20)
    .order('last_used_at', { ascending: false })
    .order('created_at', { ascending: false })

  if (search.value.length) {
    query = query.ilike('name', `%${search.value}%`)
  }

  if (categoryFilter.value != 'all') {
    query = query.eq('category', categoryFilter.value)
  }

  const { data, error } = await query

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  foods.value = data as FoodItem[]
})
</script>

<template>
  <div class="m-2 mb-4 grid grid-cols-1 md:grid-cols-2">
    <div class="md:mr-2">
      <input
        type="search"
        class="form-input"
        placeholder="Search"
        @search="(e: Event) => (search = (e.target as HTMLInputElement).value.trim())"
      />
    </div>
    <div>
      <div class="mb-4 mt-6 text-left md:ml-3 md:mt-0">
        <label class="centered block flex text-gray-700">
          <b>Category</b>
          <select required class="form-select ml-2 text-lg" v-model="categoryFilter">
            <option value="all">all</option>
            <option v-for="(item, index) in $foodCategories">
              {{ item }}
            </option>
          </select>
        </label>
      </div>
    </div>
  </div>

  <h4 class="my-8 text-center" v-if="!foods.length">No Results</h4>
  <div v-else class="grid grid-cols-2 text-left sm:grid-cols-3 md:grid-cols-4">
    <div
      v-for="(item, index) in foods"
      class="m-2 mb-4 cursor-pointer border p-2"
      @click="$emit('foodItemClicked', item)"
    >
      <h4>
        <b class="block text-lg">{{ item.name }}</b
        ><span>{{ item.category }}</span>
      </h4>
    </div>
  </div>
</template>
