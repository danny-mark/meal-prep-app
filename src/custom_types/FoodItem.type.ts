export interface Macros {
  protein: number
  carbs: number
  fat: number
  fiber: number
  calories: number
  fodmap: number
}

export interface FoodItem {
  id?: number
  name: string
  note: string
  category: string
  created_at: Date
  last_used_at: Date
  is_favorite: boolean
  macros: Macros
}
