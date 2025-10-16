<template>
  <div class="login-container">
    <div class="login-image">
      <!-- A imagem de fundo que você quer na lateral esquerda -->
      <!--<img src="~/assets/images/fundo.png" alt="Imagem do lado esquerdo">-->
    </div>
    <div class="login-form-container">
      <!-- Logo no topo -->
      <div class="logo">
        <img src="~/assets/images/logoAzul.png" alt="Logo" />
      </div>
      <!-- Primeira caixa: Login -->
      <div class="login-box">
        <h2>Acesse o portal</h2>
        <p>Entre usando seu e-mail e senha cadastrados.</p>
        <form @submit.prevent="login">
          <input type="email" v-model="email" placeholder="E-MAIL" required />
          <input type="password" v-model="password" placeholder="SENHA" required />
          <button type="submit" class="btn-login">Entrar</button>
        </form>
      </div>
      <!-- Segunda caixa: Cadastro -->
      <div class="signup-box">
        <p>Ainda não tem uma conta?</p>
        <p><a href="#">Cadastre agora mesmo</a></p>
        <button class="btn-signup">Criar conta</button>
      </div>
    </div>
  </div>
</template>

<script>

definePageMeta({
        layout: "login-layout"
    });

export default {
  data() {
    return {
      email: '',
      password: ''
    };
  },
  methods: {
    login() {
      // Lógica de login aqui
      console.log(this.email, this.password);
    }
  }
};
</script>

<style scoped lang="scss">
.login-container {
  display: flex;
  min-height: 100vh;

  /* Imagem na lateral esquerda */
  .login-image {
    flex: 1;
    background-color: #001122;  /* Pode colocar a cor de fundo aqui */
    background-image: url('~/assets/images/fundo.png');  /* Substitua pelo caminho da sua imagem */
    background-size: cover;
    background-position: center;
  }

  /* Container para os campos de login */
  .login-form-container {
    flex: 0.45;
    background-color: white;
    padding: 30px;
    border-radius: 10px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    margin-top: 100px;  /* Alinha ao centro da tela */
    display: flex;
    flex-direction: column;
    align-items: center;

    .logo img {
      width: 150px; /* Tamanho da logo */
      margin-bottom: 30px;
    }

    .login-box, .signup-box {
      width: 100%;
      margin-bottom: 20px;
    }

    .login-box {
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

      .btn-login {
        width: 100%;
        padding: 12px;
        background-color: #00076d;
        color: white;
        border: none;
        border-radius: 8px;
        font-size: 1rem;
        cursor: pointer;
        transition: background-color 0.3s;

        &:hover {
          background-color: #001122;
        }
      }
    }

    .signup-box {
      text-align: center;

      p {
        font-size: 0.9rem;
        color: #727272;
      }

      a {
        color: #16c098;
        text-decoration: none;
        font-weight: bold;
        transition: color 0.3s;

        &:hover {
          color: #00076d;
        }
      }

      .btn-signup {
        width: 100%;
        padding: 12px;
        background-color: #16c098;
        color: white;
        border: none;
        border-radius: 8px;
        font-size: 1rem;
        cursor: pointer;
        margin-top: 15px;

        &:hover {
          background-color: #00076d;
        }
      }
    }
  }
}

/* Responsividade para telas pequenas */
@media (max-width: 768px) {
  .login-container {
    flex-direction: column;

    .login-form-container {
      width: 100%;
      margin-top: 20px;
    }

    .login-image {
      display: none;  /* Esconde a imagem em telas pequenas */
    }
  }
}
</style>
