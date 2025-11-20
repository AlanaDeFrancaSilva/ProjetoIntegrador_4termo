<template>
  <div
    class="fixed inset-0 bg-black bg-opacity-40 backdrop-blur-sm flex items-center justify-center z-50"
    @click.self="$emit('close')"
  >
    <div class="bg-white rounded-lg shadow-xl w-full max-w-lg p-6 relative animate-fadeIn">

      <button
        class="absolute top-3 right-3 text-gray-500 hover:text-gray-700 text-xl"
        @click="$emit('close')"
      >
        ✕
      </button>

      <h2 class="text-xl font-bold mb-4">Novo Chamado</h2>

      <div class="flex flex-col gap-3">
        <input type="text" placeholder="Título" class="border px-3 py-2 rounded-md" />
        <textarea rows="4" placeholder="Descrição" class="border px-3 py-2 rounded-md"></textarea>

        <select class="border px-3 py-2 rounded-md">
          <option value="">Urgência</option>
          <option value="LOW">Baixa</option>
          <option value="MEDIUM">Média</option>
          <option value="HIGH">Alta</option>
          <option value="EXTRA_HIGH">Extra Alta</option>
        </select>
      </div>

      <div class="flex justify-end gap-4 mt-6">
        <button @click="$emit('close')" class="px-4 py-2 bg-gray-300 hover:bg-gray-400 rounded-md">
          Cancelar
        </button>

        <button class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md">
          Salvar
        </button>
      </div>

    </div>
  </div>
</template>

<style scoped>
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-6px) scale(0.98); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}
.animate-fadeIn {
  animation: fadeIn 0.2s ease-out;
}
</style>
