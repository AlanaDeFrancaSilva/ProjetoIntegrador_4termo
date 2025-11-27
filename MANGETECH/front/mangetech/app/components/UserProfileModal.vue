<template>
  <div class="backdrop" @click.self="$emit('close')">
    <div class="modal">
      <h2>Editar Perfil</h2>

      <form @submit.prevent="save">
        <label>Nome</label>
        <input v-model="form.name" type="text" />

        <label>Email (não editável)</label>
        <input v-model="form.email" type="email" disabled />

        <label>NIF (não editável)</label>
        <input v-model="form.nif" disabled />

        <label>Telefone</label>
        <input v-model="form.phone" type="text" placeholder="(99) 99999-9999"/>

        <button type="submit" class="save" :disabled="saving.loading">
          {{ saving.loading ? 'Salvando...' : 'Salvar' }}
        </button>
      </form>

      <div v-if="saving.error" style="color: red; margin-top: 8px;">
        {{ saving.error }}
      </div>

      <button class="close-btn" @click="$emit('close')">Fechar</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue'
import { updateCurrentUser } from '@/services/auth.services'
import { useUserStore } from '@/stores/user'

const props = defineProps({ user: Object })
const emit = defineEmits(['close'])
const userStore = useUserStore()

const form = reactive({
  name: props.user.name,
  email: props.user.email,
  nif: props.user.nif,
  phone: props.user.phone ?? '',
})

const saving = reactive({ loading: false, error: '' })

async function save() {
  saving.loading = true
  saving.error = ''

  try {
    const { error } = await updateCurrentUser({
      name: form.name,   // campo do serializer
      phone: form.phone, // campo do serializer
    })

    if (error?.value) {
      saving.error = 'Erro ao salvar: ' + error.value.message
      return
    }

    // Atualiza o store global do usuário
    userStore.setUser({
      ...userStore.user,
      name: form.name,
      phone: form.phone
    })

    emit('close') // fecha o modal
    alert('Perfil atualizado com sucesso!')

  } catch (err) {
    console.error(err)
    saving.error = 'Erro ao salvar dados.'
  } finally {
    saving.loading = false
  }
}
</script>


<style scoped>
/* Fundo escuro semitransparente por trás do modal */
.backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,.6); /* COR DO BACKDROP - altere aqui */
  display: flex;
  justify-content: center;
  align-items: center;

  /*z-index: 9999;  Garantindo que o modal fique por cima de tudo*/
}
.modal-overlay {
  z-index: 999999 !important;
}

.modal {
  z-index: 1000000 !important;
}

/* Caixa do modal */
.modal {
  background: #0d1323; /* COR DE FUNDO DO MODAL */
  color: white;        /* COR DO TEXTO DO MODAL */
  padding: 20px;
  border-radius: 10px;
  width: 380px;

  z-index: 10000;
  position: relative;
}

/* Campos de input */
input {
  width: 100%;
  margin: 6px 0 14px;
  padding: 6px;
  border-radius: 6px;
  border: none;
  background: #1e293b; /* COR DE FUNDO DO INPUT - opcional */
  color: white;        /* COR DO TEXTO DO INPUT */
}

/* Botão Salvar */
.save {
  background: #1e40af; /* COR DO BOTÃO SALVAR */
  padding: 6px 12px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  color: white;        /* COR DO TEXTO DO BOTÃO */
}

/* Botão Fechar */
.close-btn {
  margin-top: 10px;
  background: #dc2626; /* COR DO BOTÃO FECHAR */
  padding: 6px 12px;
  border-radius: 6px;
  color: white;        /* COR DO TEXTO DO BOTÃO FECHAR */
}
</style>
