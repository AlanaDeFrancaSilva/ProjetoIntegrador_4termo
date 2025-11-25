<template>
  <div class="dashboard-container">
    <main class="main-content">
      <div class="cards-grid">

        <!-- Card de Sales -->
        <div class="card sales-card">
          <h3>Sales Activity</h3>
          <p class="value">$8954.57</p>
          <p class="change">↑ 15%</p>
        </div>

        <!-- Card do Mapa -->
        <div class="card map-card">
          <img src="@/assets/images/map.png" alt="Mapa de estatísticas" />
        </div>

        <!-- Banner Promocional -->
        <div class="card promo-card">
          <div class="text">
            <h2>
              SUA CENTRAL DE CHAMADOS <span>RÁPIDA</span> E ORGANIZADA
            </h2>
          </div>
          <div class="phone">
            <img src="@/assets/images/telateste1.png" alt="App Cage Systems" />
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
/* ========= LAYOUT GLOBAL ========= */
.dashboard-container {
  display: flex;
  min-height: 100vh;
  background-color: #f4f6f9;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 2.5rem 3.5rem;
}

/* ======== GRID DOS CARDS ======== */
.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 28px;
  margin-top: 10px;
  align-content: flex-start;
}

/* ======== CARD PADRÃO ======== */
.card {
  background: rgba(15, 23, 42, 0.85);
  backdrop-filter: blur(6px);
  border-radius: 22px;
  padding: 26px;
  min-height: 220px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  color: #f9fafb;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.25);
  transition: transform 0.35s ease, box-shadow 0.35s ease;
}

.card:hover {
  transform: translateY(-5px);
  box-shadow: 0 14px 45px rgba(0, 0, 0, 0.5);
}

/* ======== SALES CARD ======== */
.sales-card {
  background: linear-gradient(135deg, #2f3cb4, #1d286b, #182245);
}

.sales-card .value {
  font-size: 2.4rem;
  font-weight: 800;
}

.sales-card .change {
  font-size: 0.9rem;
  color: #22c55e;
  font-weight: 600;
}

/* ======== MAP CARD ======== */
.map-card {
  display: flex;
  justify-content: center;
  align-items: center;
}

.map-card img {
  max-width: 100%;
  max-height: 210px;
  object-fit: contain;
  filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.6));
}

/* ======== PROMO BANNER ======== */
.promo-card {
  grid-column: span 2;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: linear-gradient(120deg, #020617, #0e1529, #111827);
  border-radius: 20px;
  padding: 36px 48px;
  min-height: 230px; /* 🔥 antes estava 330px */
  overflow: hidden;
}
/* Texto compacto e alinhado */
.promo-card .text h2 {
  font-size: 1.8rem; /* 🔥 Reduzi para não ficar exagerado */
  font-weight: 700;
  line-height: 1.3;
  color: #f9fafb;
  max-width: 450px;
}

.promo-card .text span {
  color: #4f7df3;
}

/* Mockup do celular ajustado e alinhado elegante */
.promo-card .phone {
  flex: 1;
  display: flex;
  justify-content: flex-end;
  align-items: flex-end;
}

.promo-card .phone img {
  max-width: 360px; /* 🔥 antes estava 480px */
  width: 100%;
  transform: translateY(10px);
  filter: drop-shadow(0 10px 28px rgba(0,0,0,0.6));
  transition: transform 0.3s ease;
}

.promo-card .phone img:hover {
  transform: translateY(10px) scale(1.02);
}

/* ======== RESPONSIVIDADE ======== */
@media (max-width: 900px) {
  .promo-card {
    flex-direction: column;
    text-align: center;
    padding: 28px;
    min-height: 200px;
  }

  .promo-card .phone img {
    max-width: 220px;
    transform: translateY(0);
  }

  .promo-card .text h2 {
    font-size: 1.5rem;
  }
}
</style>
