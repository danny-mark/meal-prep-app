import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import VueDatePicker from '@vuepic/vue-datepicker'
import '@vuepic/vue-datepicker/dist/main.css'

const app = createApp(App)

app.config.globalProperties.$foodCategories = [
  // hardcoded food categories for now
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
app.config.globalProperties.$macros = ['calories', 'protein', 'fat', 'carbs', 'fiber']

app.use(createPinia())
app.component('VueDatePicker', VueDatePicker)

app.mount('#app')
