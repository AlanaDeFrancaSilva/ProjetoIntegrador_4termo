<template>
  <div class="dashboard-container">

    <!-- Main Content -->
    <main class="main-content">
      <div class="cards-grid">
        <!-- Sales Card -->
        <div class="card sales-card">
          <h3>Sales Activity</h3>
          <p class="value">$8954.57</p>
          <p class="change">↑ 15%</p>
        </div>

        <!-- Map Widget -->
        <div class="card map-card">
         <img src="@/assets/images/map.png" alt="Mapa de estatísticas" />
        </div>

        <!-- Promo Banner -->
        <div class="card promo-card">
          <div class="text">
            <h2>SUA CENTRAL DE CHAMADOS <span>RÁPIDA</span> E ORGANIZADA</h2>
          </div>
          <div class="phone">
            <img src="@/assets/images/Home.png" alt="App Cage Systems" />
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">

definePageMeta({
  layout: 'dashboard-layout'
})

</script>

<style scoped lang="scss">
.dashboard-container {
  display:flex;
  min-height: 100vh;
  background-color: #ffffff;
  color: #fff;
}

/* Sidebar */
.sidebar {
  width: 250px;
  background-color: #0d1323;
  display: flex;
  flex-direction: column;
  justify-content: flex-start; // alinha tudo para cima
  padding: 30px 0;

  .logo img {
    width: 150px;
    margin-bottom: 25px; // pode reduzir
  }

  .menu ul {
    list-style: none;
    padding: 0;

    li {
      padding: 12px 0;
      font-weight: 500;
      cursor: pointer;
      color: #b3b3b3;
      transition: color 0.3s;

      &.active,
      &:hover {
        color: #1e40af;
      }
    }
  }

  .user-box {
    margin-top: auto; // empurra o usuário para baixo, mas sem exagero
    font-size: 0.9rem;

    .user-name {
      font-weight: 600;
    }

    .user-email {
      color: #888;
    }
  }
}

.map-card {
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #111833;
  border-radius: 20px;

  img {
    max-width: 100%;
    height: auto;
  }
}

/* Main */
.main-content {
  flex: 1;
  padding: 40px;
  display: flex;
  flex-direction: column;

  .cards-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 24px;
  }

  .card {
    background-color: #111833;
    border-radius: 20px;
    padding: 20px;
  }

  .sales-card {
    background: linear-gradient(135deg, #1e3a8a, #1e40af);
    color: white;

    h3 {
      font-size: 1rem;
      color: #cbd5e1;
    }
    .value {
      font-size: 2rem;
      font-weight: 700;
      margin: 10px 0;
    }
    .change {
      color: #4ade80;
    }
  }

  .map-card {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
    color: #94a3b8;
  }

.promo-card {
  grid-column: span 2;
  display: flex;
  align-items: center;
  position: relative; // necessário para o absolute da imagem
  background-color: #001122;
  padding: 20px;
  bottom: -50px;

  .text {
    padding-left: 40px;

    h2 {
      font-size: 1.8rem;
      font-weight: 600;

      span {
        color: #1e40af;
      }
    }
  }

  .phone img {
    position: relative; // tira do fluxo do flex
    right: -1px;        // distancia da direita do card
    bottom:-50px;       // distancia da base do card
    height: 450px;
  }
}
}

@media (max-width: 900px) {
  .main-content .cards-grid {
    grid-template-columns: 1fr;
  }

  .promo-card {
    flex-direction: column;
    align-items: center;
    text-align: center;
    padding: 200px 10px;

    .text {
      padding-left: 0;
    }

    .phone img {
      position: relative; // volta ao fluxo
      bottom: 0;
      right: 0;
      margin-top: 20px;
      height: 350px; // ajusta o tamanho para telas menores
    }
  }
}
</style>
