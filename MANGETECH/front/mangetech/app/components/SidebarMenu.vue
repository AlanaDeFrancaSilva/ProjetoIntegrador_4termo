<template>
  <aside class="sidebar">
    <div class="logo">
      <img src="@/assets/images/logoHome.png" alt="Logo" />
    </div>

    <nav class="menu">
      <ul>
        <li class="active">Home</li>
        <li>Chamados</li>
        <li>Técnicos</li>
        <li>Clientes</li>
        <li>Monitoramento</li>
        <li>Alertas</li>
        <li>Ambientes</li>
        <li>Documentação</li>
      </ul>
    </nav>

    <div class="user-box">
      <p class="user-name">Usuário Adm</p>
      <p class="user-email">user@cagesystems.com</p>
    </div>
  </aside>
</template>

<style scoped lang="scss">
.sidebar {
  width: 250px;
  background-color: #0d1323;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  padding: 30px 0;

  .logo img {
    width: 150px;
    margin-bottom: 25px;
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
    margin-top: auto;
    font-size: 0.9rem;

    .user-name {
      font-weight: 600;
    }

    .user-email {
      color: #888;
    }
  }
}
</style>
