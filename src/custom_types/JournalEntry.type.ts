import type { FoodItem } from './FoodItem.type'
import type { Macros } from './Macros.type'

export interface JournalEntry {
  id: number
  date: Date
  contents: JournalFood[]
  type: 'meal' | 'food'
  favorite_meals?: FavoriteMeal
}

export interface JournalFood {
  id: number
  name: string
  macros_per_100: Macros
  macros_calculated: Macros
  category: string
  note: string
  amount: number
}

export interface FavoriteMeal {
  id: number
  contents: JournalFood[]
  name: string
}
