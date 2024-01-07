import { defineStore } from 'pinia'
import { MacroKey } from '@/custom_types/Macros.type'

export const useGlobalStore = defineStore('globals', () => {
  const macros: MacroKey[] = ['calories', 'protein', 'fat', 'carbs', 'fiber']
  const foodCategories: string[] = [
    'protein',
    'carb',
    'fat',
    'complete meal',
    'veggie',
    'fruit',
    'supplement',
    'snack',
    'desert',
    'sauce'
  ]

  return { macros, foodCategories }
})
