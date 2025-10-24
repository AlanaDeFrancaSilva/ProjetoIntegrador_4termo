<template>
  <div class="signup-container">
    <div class="signup-image"></div>

    <div class="signup-form-container">
      <div class="logo">
        <img src="@/assets/images/logoAzul.png" alt="Logo" />
      </div>

      <div class="signup-box">
        <h2>Crie sua conta</h2>
        <p>Informe seu nome, e-mail e senha</p>

        <form @submit.prevent="signup">
          <input
            type="text"
            v-model="name"
            placeholder="NOME COMPLETO"
            required
            aria-label="Nome"
          />
          <input
            type="email"
            v-model="email"
            placeholder="E-MAIL"
            required
            aria-label="Email"
          />
          <input
            type="text"
            v-model="nif"
            placeholder="nif"
            required
            aria-label="NIF"
          />
          <input
            type="tel"
            v-model="phone"
            placeholder="TELEFONE (opcional)"
            aria-label="Telefone"
          />
          <input
            type="password"
            v-model="password"
            placeholder="SENHA"
            required
            aria-label="Senha"
          />
          <button type="submit" class="btn-submit">Cadastrar</button>
        </form>
      </div>

      <div class="login-box">
        <p>Já tem uma conta?</p>
        <NuxtLink to="/login" class="btn-login-link">Acessar conta</NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'login-layout',
})

import { ref } from 'vue'

const name = ref('')
const email = ref('')
const nif = ref('')
const phone = ref('')
const password = ref('')

async function signup() {
  const userData = {
    name: name.value,
    email: email.value,
    password: password.value,
    nif: nif.value,
    phone: phone.value || null
  }

  console.log('Cadastro:', userData)
  // TODO: enviar para o backend Django (ex: via Axios ou $fetch)
  // await $fetch('/api/register', { method: 'POST', body: userData })
}
</script>


<style scoped lang="scss">
.signup-container {
  display: flex;
  min-height: 100vh;

  .signup-image {
    flex: 1;
    background-color: #0883ff;
    background-image: url('~/assets/images/fundo.png');
    background-size: cover;
    background-position: center;
  }

  .signup-form-container {
    flex: 0.45;
    background-color: white;
    padding: 30px;
    border-radius: 10px;
    box-shadow: 0 4px 6px rgba(255, 0, 0, 0.1);
    margin-top: 100px;
    display: flex;
    flex-direction: column;
    align-items: center;

    .logo img {
      width: 260px;
      margin-bottom: 20px;
    }

    .signup-box,
    .login-box {
      width: 100%;
      margin-bottom: 20px;
    }

    .signup-box {
      background-color: #f9f9f9;
      padding: 20px;
      border-radius: 10px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);

      h2 {
        font-size: 1.5rem;
        margin-bottom: 10px;
      }

      p {
        font-size: 1rem;
        color: #727272;
        margin-bottom: 15px;
      }

      input {
        width: 100%;
        padding: 12px;
        margin-bottom: 20px;
        border: 1px solid #e2e7ef;
        border-radius: 8px;
        font-size: 1rem;
      }

      .btn-submit {
        width: 100%;
        padding: 12px;
        background-color: #000000;
        color: white;
        border: none;
        border-radius: 8px;
        font-size: 1rem;
        font-weight: 600;
        cursor: pointer;
        transition: background-color 0.3s;

        &:hover {
          background-color: #00076d;
        }
      }
    }

    .login-box {
      text-align: center;

      p {
        font-size: 0.95rem;
        color: #727272;
        margin-bottom: 10px;
      }

      .btn-login-link {
        display: inline-block;
        width: 100%;
        padding: 12px;
        background-color: #000000;
        color: white;
        border: none;
        border-radius: 8px;
        font-size: 1rem;
        font-weight: 600;
        text-decoration: none;
        cursor: pointer;
        transition: background-color 0.3s;

        &:hover {
          background-color: #00076d;
        }
      }
    }
  }
}

@media (max-width: 768px) {
  .signup-container {
    flex-direction: column;

    .signup-image {
      display: none;
    }

    .signup-form-container {
      width: 100%;
      margin-top: 20px;
    }
  }
}
</style>
