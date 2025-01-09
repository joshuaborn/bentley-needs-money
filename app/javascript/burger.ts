document.addEventListener('DOMContentLoaded', () => {

  // Get all "navbar-burger" elements
  const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);

  // Add a click event on each of them
  $navbarBurgers.forEach(function(element: HTMLElement) {
    element.addEventListener('click', () => {
      const target = element.dataset.target;
      element.classList.toggle('is-active');
      if (target) document.getElementById(target)?.classList.toggle('is-active');
    });
  });

});