(() => {
  const toggle = document.querySelector('.preview-toggle');
  const list = document.getElementById('project-list');
  if (!toggle || !list) return;

  const images = Array.from(list.querySelectorAll('img[data-screen]'), image => ({
    image,
    artwork: image.getAttribute('src'),
    description: image.alt,
  }));

  toggle.hidden = false;
  toggle.addEventListener('click', () => {
    const showScreens = toggle.getAttribute('aria-pressed') !== 'true';
    toggle.setAttribute('aria-pressed', String(showScreens));
    list.classList.toggle('show-screens', showScreens);
    for (const { image, artwork, description } of images) {
      image.src = showScreens ? image.dataset.screen : artwork;
      image.alt = showScreens ? image.dataset.screenAlt : description;
    }
  });
})();
