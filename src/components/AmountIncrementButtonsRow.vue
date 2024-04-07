<script setup lang="ts">
const props = defineProps<{
  amount: number
  setAmount: Function
}>()

const zeroOutFoodAmount = () => {
  props.setAmount(0)
}

const incrementFoodAmount = (increment: number) => {
  props.setAmount(props.amount + increment)
}
</script>

<template>
  <div class="mt-6 grid grid-cols-5 gap-3">
    <button class="btn btn-primary p-1" @click="zeroOutFoodAmount">0</button>
    <button class="btn btn-primary p-1" @click="() => incrementFoodAmount(10)">+10</button>
    <button class="btn btn-primary p-1" @click="() => incrementFoodAmount(25)">+25</button>
    <button class="btn btn-primary p-1" @click="() => incrementFoodAmount(50)">+50</button>
    <button class="btn btn-primary p-1" @click="() => incrementFoodAmount(100)">+100</button>
  </div>
</template>
