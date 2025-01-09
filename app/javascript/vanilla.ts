document.addEventListener('turbo:load', () => {

  document.querySelectorAll('.navbar-burger').forEach(function(element: Element) {
    element.addEventListener('click', () => {
      const target = (element as HTMLElement).dataset.target;
      element.classList.toggle('is-active');
      if (target) document.getElementById(target)?.classList.toggle('is-active');
    });
  });

  document.querySelectorAll('.delete').forEach(function(element: Element) {
    element.addEventListener('click', () => {
      const notificationElement = element.closest(".notification");
      notificationElement?.remove();
    });
  });

});