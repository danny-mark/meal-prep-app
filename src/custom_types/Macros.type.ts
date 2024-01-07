export interface Macros {
  protein: number
  carbs: number
  fat: number
  fiber: number
  calories: number
}

export type MacroKey = keyof Macros
