(() => {
  const notice = document.getElementById('language-notice');
  if (!notice) return;

  let prefersEnglish = false;
  try {
    prefersEnglish = localStorage.getItem('sackam-language') === 'en';
  } catch {
    // Language selection still works when browser storage is unavailable.
  }

  const languages = navigator.languages?.length ? navigator.languages : [navigator.language || ''];
  if (!prefersEnglish && languages.some(language => /^ja(?:-|$)/i.test(language))) {
    notice.hidden = false;
  }

  document.getElementById('keep-english').addEventListener('click', () => {
    notice.hidden = true;
    try {
      localStorage.setItem('sackam-language', 'en');
    } catch {
      // Dismiss the notice for this page even without persistent storage.
    }
    document.querySelector('.header .brand').focus();
  });
})();
