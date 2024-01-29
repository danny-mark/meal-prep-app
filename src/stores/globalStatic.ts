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
  const foodCategoryColorMap: Map<string, string> = new Map([
    ['protein', '#3498db'], // Blue
    ['carb', '#f39c12'], // Orange
    ['fat', '#f1c40f'], // Yellow
    ['veggie', '#2ecc71'], // Green
    ['fruit', '#e74c3c'], // Red
    ['supplement', '#ecf0f1'], // White
    ['snack', '#9b59b6'], // Purple
    ['desert', '#000'],
    ['complete meal', 'darkgray']
  ])

  return { macros, foodCategories, foodCategoryColorMap }
})
